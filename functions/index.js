/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const moment = require("moment-timezone");

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const { onSchedule } = require("firebase-functions/v2/scheduler");
// 선택된 시간에 맞춰 알림 전송 (Asia/Seoul 시간대 기준)
exports.sendDailyAlarm = onSchedule(
  {
    schedule: "* * * * *",
    timeZone: "Asia/Seoul",
  },
  async (event) => {
    const now = moment().tz("Asia/Seoul");
    const currentHour = now.hour();
    const currentMinute = now.minute();
    const currentWeekday = now.day() === 0 ? 7 : now.day(); // 일요일 보정

    console.log(`⏰ 알림 전송 체크 중: ${currentWeekday}요일 ${currentHour}:${currentMinute}`);

    // court_alarms 컬렉션에서 모든 알람 대상 가져오기
    const courtAlarmsSnapshot = await admin.firestore().collection("court_alarms").get();

    const targetAlarms = courtAlarmsSnapshot.docs.filter(doc => {
      const data = doc.data();
      return (
        data.alarm_enabled &&
        data.weekday === currentWeekday &&
        data.hour === currentHour &&
        data.minute === currentMinute
      );
    });

    for (const doc of targetAlarms) {
      const data = doc.data();
      const fcmToken = data.fcm_token;
      const courtName = data.court_name ?? "테니스 코트";

      if (!fcmToken) continue;

const messaging = admin.messaging();

await messaging.send({
  token: fcmToken,
  notification: {
    title: "테니스 알림 ⏰",
    body: `${courtName} 예약을 확인해보세요!`,
  },
  android: {
    notification: {
      channelId: "alarm_channel", // 앱에서 사용하는 채널 ID
    }
  },
});
      console.log(`✅ ${fcmToken}에게 알림 전송 완료`);
    }
  }
);

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
