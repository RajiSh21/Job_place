const pool = require('../config/db');
const { calculateDistance } = require('../utils/helpers');

const VALID_SKILLS = [
  'plumber','electrician','tutor','carpenter','painter',
  'tailor','cleaner','driver','cook','mason','mechanic','gardener','other',
];

/** POST /api/workers/register */
const registerWorker = async (req, res) => {
  const {
    name, skills, bio, hourlyRate, fixedRate,
    availabilityDays, availabilityStartTime, availabilityEndTime,
    nidNumber, locationDistrict, locationCity, locationMunicipality,
    locationWard, latitude, longitude,
  } = req.body;

  // Update user name and location
  await pool.query(
    `UPDATE users SET name = COALESCE($1, name), role = 'worker',
     location_district = COALESCE($2, location_district),
     location_city = COALESCE($3, location_city),
     location_municipality = COALESCE($4, location_municipality),
     location_ward = COALESCE($5, location_ward),
     updated_at = NOW() WHERE id = $6`,
    [name, locationDistrict, locationCity, locationMunicipality, locationWard, req.user.id]
  );

  // Validate skills
  const validatedSkills = (skills || []).filter((s) => VALID_SKILLS.includes(s));

  const result = await pool.query(
    `INSERT INTO workers
       (user_id, skills, bio, hourly_rate, fixed_rate, availability_days,
        availability_start_time, availability_end_time, nid_number, latitude, longitude)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
     ON CONFLICT (user_id) DO UPDATE SET
       skills = EXCLUDED.skills, bio = EXCLUDED.bio,
       hourly_rate = EXCLUDED.hourly_rate, fixed_rate = EXCLUDED.fixed_rate,
       availability_days = EXCLUDED.availability_days,
       availability_start_time = EXCLUDED.availability_start_time,
       availability_end_time = EXCLUDED.availability_end_time,
       nid_number = EXCLUDED.nid_number,
       latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude,
       updated_at = NOW()
     RETURNING *`,
    [
      req.user.id, validatedSkills, bio, hourlyRate, fixedRate,
      availabilityDays || [], availabilityStartTime, availabilityEndTime,
      nidNumber, latitude, longitude,
    ]
  );

  res.status(201).json({ message: 'कामदार प्रोफाइल सिर्जना भयो।', worker: result.rows[0] });
};

/** GET /api/workers */
const listWorkers = async (req, res) => {
  const {
    category, district, priceMin, priceMax, ratingMin,
    availableToday, sortBy = 'rating', page = 1, limit = 20,
    lat, lng,
  } = req.query;

  const params = [];
  const conditions = ['u.is_active = true'];
  let paramIndex = 1;

  if (category) {
    conditions.push(`$${paramIndex} = ANY(w.skills)`);
    params.push(category);
    paramIndex++;
  }
  if (district) {
    conditions.push(`u.location_district ILIKE $${paramIndex}`);
    params.push(`%${district}%`);
    paramIndex++;
  }
  if (priceMin) {
    conditions.push(`(w.hourly_rate >= $${paramIndex} OR w.fixed_rate >= $${paramIndex})`);
    params.push(parseFloat(priceMin));
    paramIndex++;
  }
  if (priceMax) {
    conditions.push(`(w.hourly_rate <= $${paramIndex} OR w.fixed_rate <= $${paramIndex})`);
    params.push(parseFloat(priceMax));
    paramIndex++;
  }
  if (ratingMin) {
    conditions.push(`w.rating_avg >= $${paramIndex}`);
    params.push(parseFloat(ratingMin));
    paramIndex++;
  }

  const today = new Date().toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();
  if (availableToday === 'true') {
    conditions.push(`$${paramIndex} = ANY(w.availability_days)`);
    params.push(today);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  let orderClause;
  switch (sortBy) {
    case 'price_asc': orderClause = 'ORDER BY COALESCE(w.hourly_rate, w.fixed_rate) ASC NULLS LAST'; break;
    case 'price_desc': orderClause = 'ORDER BY COALESCE(w.hourly_rate, w.fixed_rate) DESC NULLS LAST'; break;
    case 'most_booked': orderClause = 'ORDER BY w.total_jobs DESC'; break;
    default: orderClause = 'ORDER BY w.is_featured DESC, w.rating_avg DESC NULLS LAST';
  }

  const offset = (parseInt(page) - 1) * parseInt(limit);
  params.push(parseInt(limit), offset);

  const query = `
    SELECT w.id, u.id AS user_id, u.name, u.profile_photo,
           u.location_district, u.location_city,
           w.skills, w.bio, w.hourly_rate, w.fixed_rate,
           w.rating_avg, w.total_jobs, w.is_verified, w.is_featured,
           w.availability_days, w.latitude, w.longitude
    FROM workers w
    JOIN users u ON u.id = w.user_id
    ${whereClause}
    ${orderClause}
    LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;

  const countQuery = `SELECT COUNT(*) FROM workers w JOIN users u ON u.id = w.user_id ${whereClause}`;

  const [workers, countResult] = await Promise.all([
    pool.query(query, params),
    pool.query(countQuery, params.slice(0, paramIndex - 1)),
  ]);

  // Add distance if coordinates provided
  let rows = workers.rows;
  if (lat && lng) {
    rows = rows.map((w) => ({
      ...w,
      distance: w.latitude && w.longitude
        ? parseFloat(calculateDistance(parseFloat(lat), parseFloat(lng), w.latitude, w.longitude).toFixed(1))
        : null,
    }));
    if (sortBy === 'nearest') {
      rows.sort((a, b) => (a.distance ?? 9999) - (b.distance ?? 9999));
    }
  }

  res.json({
    workers: rows,
    total: parseInt(countResult.rows[0].count),
    page: parseInt(page),
    limit: parseInt(limit),
  });
};

/** GET /api/workers/:id */
const getWorker = async (req, res) => {
  const result = await pool.query(
    `SELECT w.id, u.id AS user_id, u.name, u.phone, u.profile_photo,
            u.location_district, u.location_city, u.location_municipality, u.location_ward,
            u.created_at AS member_since,
            w.skills, w.bio, w.hourly_rate, w.fixed_rate,
            w.availability_days, w.availability_start_time, w.availability_end_time,
            w.is_verified, w.is_featured, w.nid_number,
            w.rating_avg, w.rating_punctuality, w.rating_quality, w.rating_behavior,
            w.total_jobs, w.work_photos, w.profile_views,
            w.latitude, w.longitude
     FROM workers w
     JOIN users u ON u.id = w.user_id
     WHERE w.id = $1 AND u.is_active = true`,
    [req.params.id]
  );

  if (!result.rows[0]) return res.status(404).json({ message: 'कामदार फेला परेन।' });

  // Increment profile views
  await pool.query('UPDATE workers SET profile_views = profile_views + 1 WHERE id = $1', [req.params.id]);

  res.json(result.rows[0]);
};

/** GET /api/workers/dashboard */
const getWorkerDashboard = async (req, res) => {
  const workerResult = await pool.query(
    'SELECT id FROM workers WHERE user_id = $1',
    [req.user.id]
  );
  if (!workerResult.rows[0]) return res.status(404).json({ message: 'कामदार प्रोफाइल फेला परेन।' });
  const workerId = workerResult.rows[0].id;

  const [statsResult, todayResult, weekEarnings, monthEarnings] = await Promise.all([
    pool.query(
      'SELECT rating_avg, total_jobs, profile_views, is_verified, is_featured FROM workers WHERE id = $1',
      [workerId]
    ),
    pool.query(
      `SELECT COUNT(*) FROM bookings WHERE worker_id = $1
       AND scheduled_date = CURRENT_DATE AND status IN ('accepted','in_progress')`,
      [workerId]
    ),
    pool.query(
      `SELECT COALESCE(SUM(amount - COALESCE(commission,0)),0) AS earnings
       FROM bookings WHERE worker_id = $1
       AND status = 'completed' AND payment_status = 'paid'
       AND created_at >= date_trunc('week', NOW())`,
      [workerId]
    ),
    pool.query(
      `SELECT COALESCE(SUM(amount - COALESCE(commission,0)),0) AS earnings
       FROM bookings WHERE worker_id = $1
       AND status = 'completed' AND payment_status = 'paid'
       AND created_at >= date_trunc('month', NOW())`,
      [workerId]
    ),
  ]);

  const incomingCount = await pool.query(
    'SELECT COUNT(*) FROM bookings WHERE worker_id = $1 AND status = $2',
    [workerId, 'pending']
  );

  res.json({
    stats: statsResult.rows[0],
    todayJobs: parseInt(todayResult.rows[0].count),
    incomingRequests: parseInt(incomingCount.rows[0].count),
    weekEarnings: parseFloat(weekEarnings.rows[0].earnings),
    monthEarnings: parseFloat(monthEarnings.rows[0].earnings),
  });
};

/** PUT /api/workers/profile */
const updateWorkerProfile = async (req, res) => {
  const {
    bio, hourlyRate, fixedRate, availabilityDays,
    availabilityStartTime, availabilityEndTime, latitude, longitude,
  } = req.body;

  const result = await pool.query(
    `UPDATE workers SET
       bio = COALESCE($1, bio),
       hourly_rate = COALESCE($2, hourly_rate),
       fixed_rate = COALESCE($3, fixed_rate),
       availability_days = COALESCE($4, availability_days),
       availability_start_time = COALESCE($5, availability_start_time),
       availability_end_time = COALESCE($6, availability_end_time),
       latitude = COALESCE($7, latitude),
       longitude = COALESCE($8, longitude),
       updated_at = NOW()
     WHERE user_id = $9
     RETURNING *`,
    [bio, hourlyRate, fixedRate, availabilityDays, availabilityStartTime, availabilityEndTime, latitude, longitude, req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ message: 'कामदार प्रोफाइल फेला परेन।' });
  res.json({ message: 'प्रोफाइल अपडेट भयो।', worker: result.rows[0] });
};

/** POST /api/workers/work-photos */
const uploadWorkPhotos = async (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ message: 'कम्तिमा एउटा फोटो आवश्यक छ।' });
  }
  const urls = req.files.map((f) => f.path);

  const result = await pool.query(
    `UPDATE workers SET work_photos = array_cat(work_photos, $1::text[]), updated_at = NOW()
     WHERE user_id = $2 RETURNING work_photos`,
    [urls, req.user.id]
  );
  res.json({ message: 'फोटोहरू अपलोड भयो।', workPhotos: result.rows[0].work_photos });
};

module.exports = {
  registerWorker, listWorkers, getWorker, getWorkerDashboard,
  updateWorkerProfile, uploadWorkPhotos,
};
