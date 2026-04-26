const pool = require('../config/db');
const { sendPushNotification } = require('../utils/pushNotification');

/** POST /api/reviews */
const createReview = async (req, res) => {
  const { bookingId, rating, punctuality, quality, behavior, comment } = req.body;

  // Verify booking is completed and belongs to reviewer
  const bookingResult = await pool.query(
    `SELECT b.*, w.user_id AS worker_user_id
     FROM bookings b JOIN workers w ON w.id = b.worker_id
     WHERE b.id = $1 AND b.status = 'completed'`,
    [bookingId]
  );
  const booking = bookingResult.rows[0];
  if (!booking) {
    return res.status(400).json({ message: 'बुकिङ फेला परेन वा सम्पन्न भएको छैन।' });
  }
  if (booking.customer_id !== req.user.id) {
    return res.status(403).json({ message: 'यो रिभ्यु दिने अनुमति छैन।' });
  }

  const reviewResult = await pool.query(
    `INSERT INTO reviews (booking_id, reviewer_id, reviewed_id, rating, punctuality, quality, behavior, comment)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
     ON CONFLICT (booking_id) DO NOTHING
     RETURNING *`,
    [bookingId, req.user.id, booking.worker_user_id, rating, punctuality, quality, behavior, comment]
  );

  if (!reviewResult.rows[0]) {
    return res.status(400).json({ message: 'यो बुकिङको रिभ्यु पहिले नै दिइएको छ।' });
  }

  // Update worker rating averages
  await pool.query(
    `UPDATE workers SET
       rating_avg = (SELECT AVG(rating) FROM reviews WHERE reviewed_id = $1),
       rating_punctuality = (SELECT AVG(punctuality) FROM reviews WHERE reviewed_id = $1),
       rating_quality = (SELECT AVG(quality) FROM reviews WHERE reviewed_id = $1),
       rating_behavior = (SELECT AVG(behavior) FROM reviews WHERE reviewed_id = $1),
       updated_at = NOW()
     WHERE user_id = $1`,
    [booking.worker_user_id]
  );

  // Notify worker
  const fcmResult = await pool.query('SELECT fcm_token FROM users WHERE id = $1', [booking.worker_user_id]);
  await sendPushNotification(
    fcmResult.rows[0]?.fcm_token,
    'नयाँ रिभ्यु!',
    `तपाईंलाई ${rating} तारा रेटिङ दिइएको छ।`,
    { bookingId, type: 'review' }
  );

  res.status(201).json({ message: 'रिभ्यु सबमिट भयो।', review: reviewResult.rows[0] });
};

/** GET /api/reviews/worker/:workerId */
const getWorkerReviews = async (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  const workerResult = await pool.query('SELECT user_id FROM workers WHERE id = $1', [req.params.workerId]);
  if (!workerResult.rows[0]) return res.status(404).json({ message: 'कामदार फेला परेन।' });

  const result = await pool.query(
    `SELECT r.*, u.name AS reviewer_name, u.profile_photo AS reviewer_photo,
            b.service_type
     FROM reviews r
     JOIN users u ON u.id = r.reviewer_id
     JOIN bookings b ON b.id = r.booking_id
     WHERE r.reviewed_id = $1
     ORDER BY r.created_at DESC
     LIMIT $2 OFFSET $3`,
    [workerResult.rows[0].user_id, parseInt(limit), offset]
  );

  const countResult = await pool.query(
    'SELECT COUNT(*) FROM reviews WHERE reviewed_id = $1',
    [workerResult.rows[0].user_id]
  );

  res.json({
    reviews: result.rows,
    total: parseInt(countResult.rows[0].count),
    page: parseInt(page),
    limit: parseInt(limit),
  });
};

module.exports = { createReview, getWorkerReviews };
