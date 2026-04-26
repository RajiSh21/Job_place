const pool = require('../config/db');

/** GET /api/messages/:bookingId */
const getMessages = async (req, res) => {
  const { bookingId } = req.params;
  const { page = 1, limit = 50 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  // Verify user is a party to the booking
  const bookingResult = await pool.query(
    `SELECT b.customer_id, w.user_id AS worker_user_id
     FROM bookings b JOIN workers w ON w.id = b.worker_id
     WHERE b.id = $1`,
    [bookingId]
  );
  const booking = bookingResult.rows[0];
  if (!booking) return res.status(404).json({ message: 'बुकिङ फेला परेन।' });

  const isParty = booking.customer_id === req.user.id || booking.worker_user_id === req.user.id;
  if (!isParty) return res.status(403).json({ message: 'यो च्याट हेर्ने अनुमति छैन।' });

  const result = await pool.query(
    `SELECT m.*, u.name AS sender_name, u.profile_photo AS sender_photo
     FROM messages m JOIN users u ON u.id = m.sender_id
     WHERE m.booking_id = $1
     ORDER BY m.created_at ASC
     LIMIT $2 OFFSET $3`,
    [bookingId, parseInt(limit), offset]
  );

  // Mark messages as read
  await pool.query(
    'UPDATE messages SET is_read = true WHERE booking_id = $1 AND sender_id != $2',
    [bookingId, req.user.id]
  );

  res.json({ messages: result.rows });
};

/** POST /api/messages/:bookingId */
const sendMessage = async (req, res) => {
  const { bookingId } = req.params;
  const { message } = req.body;

  if (!message || message.trim() === '') {
    return res.status(400).json({ message: 'सन्देश खाली हुन सक्दैन।' });
  }

  const result = await pool.query(
    `INSERT INTO messages (booking_id, sender_id, message)
     VALUES ($1,$2,$3) RETURNING *`,
    [bookingId, req.user.id, message.trim()]
  );

  res.status(201).json({ message: result.rows[0] });
};

module.exports = { getMessages, sendMessage };
