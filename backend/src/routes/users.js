const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { uploadProfilePhoto } = require('../middleware/upload');
const { getProfile, updateProfile, updateProfilePhoto } = require('../controllers/userController');

const router = express.Router();

router.get('/profile', auth(), getProfile);

router.put(
  '/profile',
  auth(),
  [
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('नाम २-१०० अक्षर हुनुपर्छ।'),
    body('email').optional().isEmail().withMessage('वैध इमेल प्रविष्ट गर्नुहोस्।'),
  ],
  validate,
  updateProfile
);

router.put('/profile-photo', auth(), uploadProfilePhoto, updateProfilePhoto);

module.exports = router;
