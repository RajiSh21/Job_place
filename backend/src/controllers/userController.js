const pool = require('../config/db');
const cloudinary = require('../config/cloudinary');

/** GET /api/users/profile */
const getProfile = async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.phone, u.email, u.role,
            u.location_district, u.location_city, u.location_municipality, u.location_ward,
            u.profile_photo, u.created_at,
            w.id AS worker_id, w.skills, w.bio, w.hourly_rate, w.fixed_rate,
            w.availability_days, w.availability_start_time, w.availability_end_time,
            w.is_verified, w.is_featured, w.rating_avg, w.total_jobs, w.work_photos
     FROM users u
     LEFT JOIN workers w ON w.user_id = u.id
     WHERE u.id = $1`,
    [req.user.id]
  );
  if (!result.rows[0]) return res.status(404).json({ message: 'प्रयोगकर्ता फेला परेन।' });
  res.json(result.rows[0]);
};

/** PUT /api/users/profile */
const updateProfile = async (req, res) => {
  const { name, email, locationDistrict, locationCity, locationMunicipality, locationWard, fcmToken } = req.body;

  const result = await pool.query(
    `UPDATE users SET
       name = COALESCE($1, name),
       email = COALESCE($2, email),
       location_district = COALESCE($3, location_district),
       location_city = COALESCE($4, location_city),
       location_municipality = COALESCE($5, location_municipality),
       location_ward = COALESCE($6, location_ward),
       fcm_token = COALESCE($7, fcm_token),
       updated_at = NOW()
     WHERE id = $8
     RETURNING id, name, phone, email, role, location_district, location_city, location_municipality, location_ward, profile_photo`,
    [name, email, locationDistrict, locationCity, locationMunicipality, locationWard, fcmToken, req.user.id]
  );
  res.json({ message: 'प्रोफाइल अपडेट भयो।', user: result.rows[0] });
};

/** PUT /api/users/profile-photo */
const updateProfilePhoto = async (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'फोटो आवश्यक छ।' });

  // Delete old photo from Cloudinary if exists
  const old = await pool.query('SELECT profile_photo FROM users WHERE id = $1', [req.user.id]);
  if (old.rows[0]?.profile_photo) {
    const parts = old.rows[0].profile_photo.split('/');
    const publicId = `kaamkhojo/profiles/${parts[parts.length - 1].split('.')[0]}`;
    await cloudinary.uploader.destroy(publicId).catch(() => {});
  }

  const result = await pool.query(
    'UPDATE users SET profile_photo = $1, updated_at = NOW() WHERE id = $2 RETURNING profile_photo',
    [req.file.path, req.user.id]
  );
  res.json({ message: 'फोटो अपडेट भयो।', profilePhoto: result.rows[0].profile_photo });
};

module.exports = { getProfile, updateProfile, updateProfilePhoto };
