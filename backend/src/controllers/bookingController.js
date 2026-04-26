const pool = require('../config/db');
const { calculateCommission } = require('../utils/helpers');
const { sendPushNotification } = require('../utils/pushNotification');

/** Helper: get FCM token for a user */
const getUserFCM = async (userId) => {
  const r = await pool.query('SELECT fcm_token FROM users WHERE id = $1', [userId]);
  return r.rows[0]?.fcm_token;
};

/** POST /api/bookings */
const createBooking = async (req, res) => {
  const {
    workerId, serviceType, description, scheduledDate, scheduledTime,
    address, addressDistrict, latitude, longitude,
    paymentMethod = 'cash', amount,
  } = req.body;

  const jobPhotos = req.files ? req.files.map((f) => f.path) : [];

  // Check worker exists
  const workerResult = await pool.query(
    'SELECT w.id, u.name AS worker_name, u.id AS worker_user_id FROM workers w JOIN users u ON u.id = w.user_id WHERE w.id = $1',
    [workerId]
  );
  if (!workerResult.rows[0]) {
    return res.status(404).json({ message: 'कामदार फेला परेन।' });
  }

  const commission = amount ? calculateCommission(parseFloat(amount)) : null;

  const result = await pool.query(
    `INSERT INTO bookings
       (customer_id, worker_id, service_type, description, job_photos,
        scheduled_date, scheduled_time, address, address_district, latitude, longitude,
        payment_method, amount, commission)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
     RETURNING *`,
    [
      req.user.id, workerId, serviceType, description, jobPhotos,
      scheduledDate, scheduledTime, address, addressDistrict, latitude, longitude,
      paymentMethod, amount, commission,
    ]
  );

  const booking = result.rows[0];

  // Notify worker
  const workerFCM = await getUserFCM(workerResult.rows[0].worker_user_id);
  await sendPushNotification(
    workerFCM,
    'नयाँ काम अनुरोध!',
    `${serviceType} को लागि नयाँ बुकिङ आएको छ।`,
    { bookingId: booking.id, type: 'booking_request' }
  );

  res.status(201).json({ message: 'बुकिङ सिर्जना भयो।', booking });
};

/** GET /api/bookings */
const listBookings = async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  let whereClause, params;
  if (req.user.role === 'worker') {
    const workerResult = await pool.query('SELECT id FROM workers WHERE user_id = $1', [req.user.id]);
    if (!workerResult.rows[0]) return res.json({ bookings: [], total: 0 });
    params = [workerResult.rows[0].id];
    whereClause = 'WHERE b.worker_id = $1';
  } else {
    params = [req.user.id];
    whereClause = 'WHERE b.customer_id = $1';
  }

  if (status) {
    params.push(status);
    whereClause += ` AND b.status = $${params.length}`;
  }

  params.push(parseInt(limit), offset);

  const query = `
    SELECT b.*,
           cu.name AS customer_name, cu.phone AS customer_phone, cu.profile_photo AS customer_photo,
           wu.name AS worker_name, wu.phone AS worker_phone, wu.profile_photo AS worker_photo,
           w.skills, w.hourly_rate, w.fixed_rate
    FROM bookings b
    JOIN users cu ON cu.id = b.customer_id
    JOIN workers w ON w.id = b.worker_id
    JOIN users wu ON wu.id = w.user_id
    ${whereClause}
    ORDER BY b.created_at DESC
    LIMIT $${params.length - 1} OFFSET $${params.length}`;

  const result = await pool.query(query, params);
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM bookings b ${whereClause}`,
    params.slice(0, params.length - 2)
  );

  res.json({
    bookings: result.rows,
    total: parseInt(countResult.rows[0].count),
    page: parseInt(page),
    limit: parseInt(limit),
  });
};

/** GET /api/bookings/:id */
const getBooking = async (req, res) => {
  const result = await pool.query(
    `SELECT b.*,
            cu.name AS customer_name, cu.phone AS customer_phone, cu.profile_photo AS customer_photo,
            wu.name AS worker_name, wu.phone AS worker_phone, wu.profile_photo AS worker_photo,
            w.id AS worker_profile_id, w.skills, w.hourly_rate, w.fixed_rate, w.rating_avg
     FROM bookings b
     JOIN users cu ON cu.id = b.customer_id
     JOIN workers w ON w.id = b.worker_id
     JOIN users wu ON wu.id = w.user_id
     WHERE b.id = $1`,
    [req.params.id]
  );
  if (!result.rows[0]) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });

  const b = result.rows[0];
  // Only customer or the assigned worker can view
  const workerUserResult = await pool.query('SELECT user_id FROM workers WHERE id = $1', [b.worker_id]);
  const isParty = b.customer_id === req.user.id || workerUserResult.rows[0]?.user_id === req.user.id;
  if (!isParty && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'यो बुकिङ हेर्ने अनुमति छैन।' });
  }

  res.json(b);
};

/** Generic status-change helper */
const changeStatus = async (bookingId, newStatus, userId, extraUpdate = '') => {
  const result = await pool.query(
    `UPDATE bookings SET status = $1, updated_at = NOW() ${extraUpdate}
     WHERE id = $2 RETURNING *, customer_id`,
    [newStatus, bookingId]
  );
  return result.rows[0];
};

/** PUT /api/bookings/:id/accept */
const acceptBooking = async (req, res) => {
  const booking = await changeStatus(req.params.id, 'accepted', req.user.id);
  if (!booking) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });

  const fcm = await getUserFCM(booking.customer_id);
  await sendPushNotification(fcm, 'बुकिङ स्वीकृत!', 'कामदारले तपाईंको बुकिङ स्वीकार गर्नुभयो।', {
    bookingId: booking.id, type: 'booking_accepted',
  });

  res.json({ message: 'बुकिङ स्वीकार गरियो।', booking });
};

/** PUT /api/bookings/:id/decline */
const declineBooking = async (req, res) => {
  const booking = await changeStatus(req.params.id, 'declined', req.user.id);
  if (!booking) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });

  const fcm = await getUserFCM(booking.customer_id);
  await sendPushNotification(fcm, 'बुकिङ अस्वीकृत', 'कामदारले बुकिङ अस्वीकार गर्नुभयो।', {
    bookingId: booking.id, type: 'booking_declined',
  });

  res.json({ message: 'बुकिङ अस्वीकार गरियो।', booking });
};

/** PUT /api/bookings/:id/start */
const startBooking = async (req, res) => {
  const booking = await changeStatus(req.params.id, 'in_progress', req.user.id);
  if (!booking) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });
  res.json({ message: 'काम सुरु भयो।', booking });
};

/** PUT /api/bookings/:id/complete */
const completeBooking = async (req, res) => {
  const result = await pool.query(
    `UPDATE bookings SET status = 'completed', payment_status = CASE WHEN payment_method = 'cash' THEN 'paid' ELSE payment_status END, updated_at = NOW()
     WHERE id = $1 RETURNING *`,
    [req.params.id]
  );
  if (!result.rows[0]) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });

  const booking = result.rows[0];

  // Update worker total_jobs and total_earnings
  if (booking.amount) {
    const net = parseFloat(booking.amount) - (parseFloat(booking.commission) || 0);
    await pool.query(
      'UPDATE workers SET total_jobs = total_jobs + 1, total_earnings = total_earnings + $1 WHERE id = $2',
      [net, booking.worker_id]
    );
  }

  const fcm = await getUserFCM(booking.customer_id);
  await sendPushNotification(fcm, 'काम सम्पन्न!', 'कामदारले काम पूरा गर्नुभयो। रिभ्यु दिनुहोस्।', {
    bookingId: booking.id, type: 'booking_completed',
  });

  res.json({ message: 'बुकिङ सम्पन्न भयो।', booking });
};

/** PUT /api/bookings/:id/cancel */
const cancelBooking = async (req, res) => {
  const { reason } = req.body;
  const result = await pool.query(
    `UPDATE bookings SET status = 'cancelled', cancellation_reason = $1, updated_at = NOW()
     WHERE id = $2 AND status IN ('pending','accepted') RETURNING *`,
    [reason, req.params.id]
  );
  if (!result.rows[0]) {
    return res.status(400).json({ message: 'बुकिङ रद्द गर्न सकिँदैन।' });
  }
  res.json({ message: 'बुकिङ रद्द गरियो।', booking: result.rows[0] });
};

module.exports = {
  createBooking, listBookings, getBooking,
  acceptBooking, declineBooking, startBooking, completeBooking, cancelBooking,
};
