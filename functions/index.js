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
    // New logic: send notification when alarmDateTime matches current time (to the minute)
    functions.logger.info(`⏰ 알림 전송 체크 중: 현재 시간 ${new Date().toISOString()}`);

    // court_alarms 컬렉션에서 모든 알람 대상 가져오기
    const snapshot = await admin.firestore().collection("court_alarms").get();
    functions.logger.info(`✅✅ 활성화된 알람 ${snapshot.docs.length}개`);
    const currentTime = new Date();
    functions.logger.info(`🕒 현재 시각 (서버 기준): ${currentTime}`);

    for (const doc of snapshot.docs) {
      const alarmData = doc.data();
      const alarmDateTimeRaw = alarmData.alarmDateTime ?? alarmData.alarm_date_time;
      functions.logger.info(`📄 알람 문서 ID: ${doc.id}`);
      functions.logger.info(`🔍 필드 alarm_enabled: ${alarmData.alarm_enabled}`);
      functions.logger.info(`🔍 필드 alarm_date_time: ${alarmDateTimeRaw}`);

      if (!alarmData.alarm_enabled) {
        functions.logger.info(`⏭️  스킵됨 - alarm_enabled가 false`);
        continue;
      }
      if (!alarmDateTimeRaw) {
        functions.logger.info(`⏭️  스킵됨 - alarmDateTime 없음`);
        continue;
      }

      let alarmDate;
      try {
        alarmDate = typeof alarmDateTimeRaw.toDate === "function"
          ? alarmDateTimeRaw.toDate()
          : new Date(alarmDateTimeRaw);
      } catch (e) {
        functions.logger.error(`❌ 알람 시간 파싱 실패:`, alarmDateTimeRaw, e);
        continue;
      }

      const diffInMinutes = Math.floor((alarmDate - currentTime) / (1000 * 60));
      functions.logger.info(`🕓 현재 시간: ${currentTime}`);
      functions.logger.info(`📆 알람 시간: ${alarmDate}`);
      functions.logger.info(`⏱️ 시간 차이 (분): ${diffInMinutes}`);
      functions.logger.info(`🔍 fcm_token: ${alarmData.fcmToken ?? alarmData.fcm_token}`);
      functions.logger.info(`🔍 user_uid: ${alarmData.userUid ?? alarmData.user_uid}`);
      if (Math.abs(diffInMinutes) <= 1) {
        functions.logger.info(`🔔 알람 전송 대상: ${alarmData.courtName ?? alarmData.court_name ?? "테니스 코트"}`);
        functions.logger.info(`🕓 알람 예약 시간: ${alarmDateTimeRaw?.toDate ? alarmDateTimeRaw.toDate() : alarmDateTimeRaw}`);
        // FCM 토큰 확인
        const fcmToken = alarmData.fcmToken ?? alarmData.fcm_token;
        const userUid = alarmData.userUid ?? alarmData.user_uid ?? "unknown";
        if (!fcmToken) {
          functions.logger.warn(`❌ FCM 토큰 없음: ${userUid}`);
          continue;
        }
        try {
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: `${alarmData.courtName ?? alarmData.court_name ?? "테니스 코트"} 예약 알림`,
              body: "곧 예약시간입니다. 준비해주세요!",
            },
            android: {
              priority: "high",
            },
          });
          functions.logger.info(`✅ FCM 전송 성공: ${userUid}`);
        } catch (error) {
          functions.logger.error(`🚨 FCM 전송 실패: ${userUid}`, error);
        }
      }
    }
  }
);

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
