const jwt = require('jsonwebtoken');
const pool = require('../config/db');

/**
 * Middleware to verify JWT and attach user to req.user.
 * Pass role string or array to restrict to specific roles.
 * e.g. auth(), auth('worker'), auth(['admin','worker'])
 */
const auth = (role) => async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'प्रमाणीकरण टोकन आवश्यक छ।' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const result = await pool.query(
      'SELECT id, name, phone, role, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );
    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({ message: 'प्रयोगकर्ता फेला परेन।' });
    }
    if (!user.is_active) {
      return res.status(403).json({ message: 'खाता निलम्बित गरिएको छ।' });
    }

    if (role) {
      const allowed = Array.isArray(role) ? role : [role];
      if (!allowed.includes(user.role)) {
        return res.status(403).json({ message: 'यो कार्य गर्ने अनुमति छैन।' });
      }
    }

    req.user = user;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'सत्र समाप्त भयो। फेरि लगइन गर्नुहोस्।' });
    }
    return res.status(401).json({ message: 'अवैध टोकन।' });
  }
};

module.exports = auth;
