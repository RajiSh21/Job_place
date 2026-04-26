const express = require('express');
const { body } = require('express-validator');
const rateLimit = require('express-rate-limit');
const validate = require('../middleware/validate');
const { sendOTPHandler, verifyOTPHandler, refreshTokenHandler } = require('../controllers/authController');

const router = express.Router();

// Strict rate limit for OTP sends: 5 per 10 minutes per IP
const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 5,
  message: { message: 'धेरै OTP अनुरोध। १० मिनेट पछि पुनः प्रयास गर्नुहोस्।' },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post(
  '/send-otp',
  otpLimiter,
  [
    body('phone')
      .notEmpty().withMessage('फोन नम्बर आवश्यक छ।')
      .matches(/^(\+977)?[9][6-9]\d{8}$/).withMessage('वैध नेपाली फोन नम्बर प्रविष्ट गर्नुहोस्।'),
  ],
  validate,
  sendOTPHandler
);

router.post(
  '/verify-otp',
  [
    body('phone').notEmpty().withMessage('फोन नम्बर आवश्यक छ।'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP ६ अंकको हुनुपर्छ।'),
  ],
  validate,
  verifyOTPHandler
);

router.post(
  '/refresh-token',
  [body('refreshToken').notEmpty().withMessage('Refresh token आवश्यक छ।')],
  validate,
  refreshTokenHandler
);

module.exports = router;
