const axios = require('axios');

/**
 * Send OTP via Sparrow SMS Nepal.
 * Docs: https://api.sparrowsms.com/v2/sms/
 */
const sendSMS = async (phone, message) => {
  const normalizedPhone = phone.startsWith('+977') ? phone.slice(4) : phone;

  const response = await axios.post(
    'https://api.sparrowsms.com/v2/sms/',
    {
      token: process.env.SPARROW_SMS_TOKEN,
      from: process.env.SPARROW_SMS_FROM || 'KaamKhojo',
      to: normalizedPhone,
      text: message,
    },
    { timeout: 10000 }
  );

  if (response.data.response_code !== 200) {
    throw new Error(`SMS failed: ${response.data.message}`);
  }

  return response.data;
};

/**
 * Send OTP message to Nepali phone number.
 */
const sendOTP = async (phone, otp) => {
  const message = `KaamKhojo: तपाईंको OTP कोड ${otp} हो। यो ५ मिनेटमा expire हुनेछ। कसैलाई नदिनुहोस्।`;
  return sendSMS(phone, message);
};

module.exports = { sendSMS, sendOTP };
