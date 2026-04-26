const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { uploadJobPhotos } = require('../middleware/upload');
const {
  createBooking, listBookings, getBooking,
  acceptBooking, declineBooking, startBooking, completeBooking, cancelBooking,
} = require('../controllers/bookingController');

const router = express.Router();

router.post(
  '/',
  auth('customer'),
  uploadJobPhotos,
  [
    body('workerId').notEmpty().withMessage('कामदार ID आवश्यक छ।'),
    body('serviceType').notEmpty().withMessage('सेवा प्रकार आवश्यक छ।'),
    body('scheduledDate').isDate().withMessage('मान्य मिति प्रविष्ट गर्नुहोस्।'),
    body('scheduledTime').notEmpty().withMessage('समय आवश्यक छ।'),
    body('address').notEmpty().withMessage('ठेगाना आवश्यक छ।'),
  ],
  validate,
  createBooking
);

router.get('/', auth(), listBookings);
router.get('/:id', auth(), getBooking);
router.put('/:id/accept', auth('worker'), acceptBooking);
router.put('/:id/decline', auth('worker'), declineBooking);
router.put('/:id/start', auth('worker'), startBooking);
router.put('/:id/complete', auth('worker'), completeBooking);
router.put('/:id/cancel', auth(), cancelBooking);

module.exports = router;
