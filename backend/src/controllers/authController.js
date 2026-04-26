const pool = require('../config/db');
const jwt = require('jsonwebtoken');
const { generateOTP, normalizePhone } = require('../utils/helpers');
const { sendOTP } = require('../utils/sendSMS');

const OTP_EXPIRY_MINUTES = 5;

/** POST /api/auth/send-otp */
const sendOTPHandler = async (req, res) => {
  const { phone } = req.body;
  const normalizedPhone = normalizePhone(phone);

  const otp = generateOTP();
  const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

  // Invalidate previous unused OTPs for this phone
  await pool.query(
    'UPDATE otp_codes SET is_used = true WHERE phone = $1 AND is_used = false',
    [normalizedPhone]
  );

  await pool.query(
    'INSERT INTO otp_codes (phone, code, expires_at) VALUES ($1, $2, $3)',
    [normalizedPhone, otp, expiresAt]
  );

  // In development, return OTP in response to avoid SMS costs
  if (process.env.NODE_ENV === 'development') {
    return res.json({ message: 'OTP पठाइयो।', otp, phone: normalizedPhone });
  }

  try {
    await sendOTP(normalizedPhone, otp);
    res.json({ message: 'OTP पठाइयो।', phone: normalizedPhone });
  } catch (err) {
    console.error('SMS send error:', err);
    res.status(500).json({ message: 'OTP पठाउन सकिएन। पछि पुनः प्रयास गर्नुहोस्।' });
  }
};

/** POST /api/auth/verify-otp */
const verifyOTPHandler = async (req, res) => {
  const { phone, otp } = req.body;
  const normalizedPhone = normalizePhone(phone);

  const result = await pool.query(
    `SELECT * FROM otp_codes
     WHERE phone = $1 AND code = $2 AND is_used = false AND expires_at > NOW()
     ORDER BY created_at DESC LIMIT 1`,
    [normalizedPhone, otp]
  );

  if (result.rows.length === 0) {
    return res.status(400).json({ message: 'OTP गलत छ वा म्याद सकिएको छ।' });
  }

  // Mark OTP as used
  await pool.query('UPDATE otp_codes SET is_used = true WHERE id = $1', [result.rows[0].id]);

  // Create user if they don't exist (upsert)
  const userResult = await pool.query(
    `INSERT INTO users (phone) VALUES ($1)
     ON CONFLICT (phone) DO UPDATE SET updated_at = NOW()
     RETURNING id, name, phone, role, is_active, profile_photo`,
    [normalizedPhone]
  );
  const user = userResult.rows[0];

  if (!user.is_active) {
    return res.status(403).json({ message: 'खाता निलम्बित गरिएको छ।' });
  }

  const accessToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  const refreshToken = jwt.sign({ userId: user.id, type: 'refresh' }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  });

  const isNewUser = !user.name;

  res.json({
    message: 'लगइन सफल भयो।',
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      name: user.name,
      phone: user.phone,
      role: user.role,
      profilePhoto: user.profile_photo,
    },
    isNewUser,
  });
};

/** POST /api/auth/refresh-token */
const refreshTokenHandler = async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ message: 'Refresh token आवश्यक छ।' });
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    if (decoded.type !== 'refresh') {
      return res.status(401).json({ message: 'अवैध refresh token।' });
    }

    const userResult = await pool.query('SELECT id, role, is_active FROM users WHERE id = $1', [
      decoded.userId,
    ]);
    const user = userResult.rows[0];
    if (!user || !user.is_active) {
      return res.status(401).json({ message: 'प्रयोगकर्ता फेला परेन।' });
    }

    const accessToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });
    res.json({ accessToken });
  } catch {
    res.status(401).json({ message: 'Refresh token अवैध वा म्याद सकिएको छ।' });
  }
};

module.exports = { sendOTPHandler, verifyOTPHandler, refreshTokenHandler };
