const express = require('express');
const { body, query } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { uploadWorkPhotos: uploadWorkPhotosMiddleware } = require('../middleware/upload');
const {
  registerWorker, listWorkers, getWorker, getWorkerDashboard,
  updateWorkerProfile, uploadWorkPhotos,
} = require('../controllers/workerController');

const router = express.Router();

router.post(
  '/register',
  auth(),
  [
    body('skills').isArray({ min: 1 }).withMessage('कम्तिमा एउटा सिप चयन गर्नुहोस्।'),
    body('hourlyRate').optional().isFloat({ min: 0 }).withMessage('मान्य मूल्य प्रविष्ट गर्नुहोस्।'),
    body('fixedRate').optional().isFloat({ min: 0 }).withMessage('मान्य मूल्य प्रविष्ट गर्नुहोस्।'),
  ],
  validate,
  registerWorker
);

router.get('/', listWorkers);

// Dashboard must come before /:id to avoid route shadowing
router.get('/dashboard', auth('worker'), getWorkerDashboard);

router.get('/:id', getWorker);

router.put('/profile', auth('worker'), updateWorkerProfile);

router.post('/work-photos', auth('worker'), uploadWorkPhotosMiddleware, uploadWorkPhotos);

module.exports = router;
