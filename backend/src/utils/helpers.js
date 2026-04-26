const crypto = require('crypto');

/** Generate a 6-digit numeric OTP */
const generateOTP = () => {
  return Math.floor(100000 + crypto.randomInt(900000)).toString();
};

/**
 * Calculate distance in km between two lat/lng points (Haversine formula).
 */
const calculateDistance = (lat1, lng1, lat2, lng2) => {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

const toRad = (deg) => (deg * Math.PI) / 180;

/** Calculate platform commission (default 10%) */
const calculateCommission = (amount, rate) => {
  const r = rate ?? parseFloat(process.env.COMMISSION_RATE ?? '0.10');
  return parseFloat((amount * r).toFixed(2));
};

/** Format number as NPR currency string */
const formatNPR = (amount) => `रू ${parseFloat(amount).toLocaleString('ne-NP')}`;

/** Normalize Nepal phone number to +977XXXXXXXXXX */
const normalizePhone = (phone) => {
  const digits = phone.replace(/\D/g, '');
  if (digits.startsWith('977')) return `+${digits}`;
  if (digits.startsWith('0')) return `+977${digits.slice(1)}`;
  return `+977${digits}`;
};

module.exports = { generateOTP, calculateDistance, calculateCommission, formatNPR, normalizePhone };
