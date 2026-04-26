const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');
const crypto = require('crypto');

const makeStorage = (folder) =>
  new CloudinaryStorage({
    cloudinary,
    params: {
      folder: `kaamkhojo/${folder}`,
      allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
      transformation: [{ quality: 'auto:good', fetch_format: 'auto' }],
      public_id: () => crypto.randomUUID(),
    },
  });

const uploadProfilePhoto = multer({
  storage: makeStorage('profiles'),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
}).single('photo');

const uploadWorkPhotos = multer({
  storage: makeStorage('work'),
  limits: { fileSize: 5 * 1024 * 1024 },
}).array('photos', 10);

const uploadJobPhotos = multer({
  storage: makeStorage('jobs'),
  limits: { fileSize: 5 * 1024 * 1024 },
}).array('photos', 5);

module.exports = { uploadProfilePhoto, uploadWorkPhotos, uploadJobPhotos };
