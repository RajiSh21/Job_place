const jwt = require('jsonwebtoken');
const pool = require('../config/db');

/**
 * Socket.io real-time chat handler.
 * Each booking has its own room: `booking_${bookingId}`
 */
const chatHandler = (io) => {
  // Middleware: authenticate socket connection via JWT
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];
    if (!token) return next(new Error('Authentication required'));

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.data.userId = decoded.userId;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}, user: ${socket.data.userId}`);

    /** Join a booking chat room */
    socket.on('join_booking_room', async ({ bookingId }) => {
      try {
        // Verify user is a party to the booking
        const result = await pool.query(
          `SELECT b.customer_id, w.user_id AS worker_user_id
           FROM bookings b JOIN workers w ON w.id = b.worker_id
           WHERE b.id = $1`,
          [bookingId]
        );
        const booking = result.rows[0];
        if (!booking) return;

        const isParty =
          booking.customer_id === socket.data.userId ||
          booking.worker_user_id === socket.data.userId;
        if (!isParty) return;

        const room = `booking_${bookingId}`;
        socket.join(room);
        socket.data.currentRoom = room;
        socket.emit('joined_room', { bookingId, room });
      } catch (err) {
        console.error('join_booking_room error:', err);
      }
    });

    /** Send a message */
    socket.on('send_message', async ({ bookingId, message }) => {
      if (!message?.trim()) return;

      try {
        const result = await pool.query(
          `INSERT INTO messages (booking_id, sender_id, message)
           VALUES ($1,$2,$3)
           RETURNING id, booking_id, sender_id, message, is_read, created_at`,
          [bookingId, socket.data.userId, message.trim()]
        );

        const userResult = await pool.query(
          'SELECT name, profile_photo FROM users WHERE id = $1',
          [socket.data.userId]
        );

        const msg = {
          ...result.rows[0],
          sender_name: userResult.rows[0]?.name,
          sender_photo: userResult.rows[0]?.profile_photo,
        };

        // Broadcast to everyone in the booking room
        io.to(`booking_${bookingId}`).emit('message_received', msg);
      } catch (err) {
        console.error('send_message error:', err);
        socket.emit('message_error', { error: 'सन्देश पठाउन सकिएन।' });
      }
    });

    /** Typing indicator */
    socket.on('typing', ({ bookingId, isTyping }) => {
      socket.to(`booking_${bookingId}`).emit('typing_indicator', {
        userId: socket.data.userId,
        isTyping,
      });
    });

    socket.on('disconnect', () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  });
};

module.exports = chatHandler;
