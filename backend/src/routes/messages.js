const express = require('express');
const auth = require('../middleware/auth');
const { getMessages, sendMessage } = require('../controllers/messageController');

const router = express.Router();

router.get('/:bookingId', auth(), getMessages);
router.post('/:bookingId', auth(), sendMessage);

module.exports = router;
