const admin = require('firebase-admin');

let initialized = false;

const initFirebase = () => {
  if (!initialized && process.env.FIREBASE_PROJECT_ID) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      }),
    });
    initialized = true;
  }
};

/**
 * Send push notification to a single device token.
 */
const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken) return;
  initFirebase();

  const message = {
    token: fcmToken,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
    android: {
      priority: 'high',
      notification: { sound: 'default', clickAction: 'FLUTTER_NOTIFICATION_CLICK' },
    },
  };

  try {
    await admin.messaging().send(message);
  } catch (err) {
    // Log but don't crash — push notification failures are non-critical
    console.error('Push notification error:', err.message);
  }
};

/**
 * Send push notification to multiple device tokens.
 */
const sendMulticastNotification = async (fcmTokens, title, body, data = {}) => {
  if (!fcmTokens || fcmTokens.length === 0) return;
  initFirebase();

  const message = {
    tokens: fcmTokens,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
  };

  try {
    await admin.messaging().sendEachForMulticast(message);
  } catch (err) {
    console.error('Multicast push error:', err.message);
  }
};

module.exports = { sendPushNotification, sendMulticastNotification };
