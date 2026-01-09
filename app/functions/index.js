
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new notification is created in the 'notifications' collection.
 * Sends a push notification to the target user if they have an FCM token.
 */
exports.sendPushNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
        const notification = snap.data();
        const notificationId = context.params.notificationId;

        console.log(`New notification created: ${notificationId}`);
        console.log(`Target user: ${notification.targetUserId}`);

        // Get the target user's FCM token
        const targetUserId = notification.targetUserId;
        if (!targetUserId) {
            console.log("No target user ID, skipping push notification");
            return null;
        }

        try {
            const userDoc = await db.collection("users").doc(targetUserId).get();

            if (!userDoc.exists) {
                console.log(`User ${targetUserId} not found`);
                return null;
            }

            const userData = userDoc.data();
            const fcmToken = userData.fcmToken;

            if (!fcmToken) {
                console.log(`User ${targetUserId} has no FCM token`);
                return null;
            }

            // Build the FCM message
            const message = {
                token: fcmToken,
                notification: {
                    title: notification.title || "New Notification",
                    body: notification.body || "",
                },
                data: {
                    notificationId: notificationId,
                    type: notification.type || "info",
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                android: {
                    priority: "high",
                    notification: {
                        channelId: "cofiz_main_channel",
                        priority: "high",
                        defaultSound: true,
                        defaultVibrateTimings: true,
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                            badge: 1,
                        },
                    },
                },
            };

            // Send the push notification
            const response = await messaging.send(message);
            console.log(`Push notification sent successfully: ${response}`);

            // Update the notification document to mark push as sent
            await snap.ref.update({
                pushSent: true,
                pushSentAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return response;
        } catch (error) {
            console.error("Error sending push notification:", error);

            // If the token is invalid, remove it from the user
            if (error.code === "messaging/invalid-registration-token" ||
                error.code === "messaging/registration-token-not-registered") {
                console.log(`Removing invalid FCM token for user ${targetUserId}`);
                await db.collection("users").doc(targetUserId).update({
                    fcmToken: admin.firestore.FieldValue.delete(),
                });
            }

            return null;
        }
    });

/**
 * Optional: Clean up old notifications (older than 30 days)
 * Run daily via Cloud Scheduler
 */
exports.cleanupOldNotifications = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - 30);

        const oldNotifications = await db
            .collection("notifications")
            .where("createdAt", "<", cutoffDate.getTime())
            .get();

        const batch = db.batch();
        oldNotifications.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();
        console.log(`Deleted ${oldNotifications.size} old notifications`);

        return null;
    });
