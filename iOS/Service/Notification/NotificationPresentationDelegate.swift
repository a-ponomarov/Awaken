//
//  NotificationPresentationDelegate.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/16/2026.
//

import UserNotifications

final class NotificationPresentationDelegate: NSObject, UNUserNotificationCenterDelegate {

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    [.banner, .sound]
  }

}
