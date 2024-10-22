const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendUrgentNotification = functions.https.onRequest(async (req, res) => {
  const { title, body, data, topic } = req.body;

  const message = {
    notification: {
      title,
      body,
    },
    data,
    topic,
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).send(`Notification sent successfully: ${response}`);
  } catch (error) {
    res.status(500).send(`Error sending notification: ${error}`);
  }
});
