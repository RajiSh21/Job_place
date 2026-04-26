const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { createReview, getWorkerReviews } = require('../controllers/reviewController');

const router = express.Router();

router.post(
  '/',
  auth('customer'),
  [
    body('bookingId').notEmpty().withMessage('Booking ID आवश्यक छ।'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('१–५ बीचको रेटिङ दिनुहोस्।'),
    body('punctuality').optional().isInt({ min: 1, max: 5 }),
    body('quality').optional().isInt({ min: 1, max: 5 }),
    body('behavior').optional().isInt({ min: 1, max: 5 }),
  ],
  validate,
  createReview
);

router.get('/worker/:workerId', getWorkerReviews);

module.exports = router;
