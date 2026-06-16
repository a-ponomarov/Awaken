//
//  RealityCheckNotificationService.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/16/2026.
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class RealityCheckNotificationService {

  private enum Constants {

    static let identifierPrefix = "RealityCheck."
    static let scheduleDays = 7
    static let rescheduleDelay: Duration = .milliseconds(350)

  }

  private let center: UNUserNotificationCenter
  private let defaults: KeyValueStore
  private let rescheduleTask = AppTask()

  init(
    center: UNUserNotificationCenter = .current(),
    defaults: KeyValueStore = UserDefaults.standard
  ) {
    self.center = center
    self.defaults = defaults
  }

  func authorizationStatus() async -> UNAuthorizationStatus {
    await center.notificationSettings().authorizationStatus
  }

  func requestAuthorizationIfNeeded() async -> Bool {
    let status = await authorizationStatus()
    switch status {
    case .authorized, .provisional, .ephemeral:
      return true
    case .notDetermined:
      return (try? await center.requestAuthorization(options: [.alert, .sound])) == true
    case .denied:
      return false
    @unknown default:
      return false
    }
  }

  func reschedule(_ settings: RealityCheckScheduleSettings) async -> Bool {
    await cancelScheduledChecks()

    guard settings.isEnabled else { return true }
    guard await requestAuthorizationIfNeeded() else { return false }

    return await schedule(settings.normalized, dayOffsets: 0 ..< Constants.scheduleDays)
  }

  func rescheduleAfterDelay(
    _ settings: RealityCheckScheduleSettings,
    completion: (@MainActor (Bool) -> Void)? = nil
  ) {
    let settings = settings.normalized
    rescheduleTask.schedule(after: Constants.rescheduleDelay) { [weak self] in
      guard let self else { return }
      let didSchedule = await reschedule(settings)
      completion?(didSchedule)
    }
  }

  func cancelPendingReschedule() {
    rescheduleTask.currentTask = nil
  }

  func refreshScheduleIfNeeded() async {
    let settings = loadSettings().normalized
    guard settings.isEnabled else { return }

    let status = await authorizationStatus()
    guard status == .authorized || status == .provisional || status == .ephemeral else {
      await cancelScheduledChecks()
      return
    }

    await cancelFutureScheduledChecks()
    _ = await schedule(settings, dayOffsets: 1 ..< Constants.scheduleDays)
  }

  func cancelScheduledChecks() async {
    let pendingRequests = await center.pendingNotificationRequests()
    let identifiers = pendingRequests
      .map(\.identifier)
      .filter { $0.hasPrefix(Constants.identifierPrefix) }
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
  }

  private func cancelFutureScheduledChecks() async {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
    let pendingRequests = await center.pendingNotificationRequests()
    let identifiers = pendingRequests.compactMap { request -> String? in
      guard request.identifier.hasPrefix(Constants.identifierPrefix) else { return nil }
      guard
        let trigger = request.trigger as? UNCalendarNotificationTrigger,
        let triggerDate = trigger.nextTriggerDate()
      else {
        return request.identifier
      }
      return triggerDate >= tomorrow ? request.identifier : nil
    }
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
  }

  private func schedule(
    _ settings: RealityCheckScheduleSettings,
    dayOffsets: some Sequence<Int>
  ) async -> Bool {
    let requests = makeRequests(for: settings, dayOffsets: dayOffsets)
    var addedIdentifiers: [String] = []

    for request in requests {
      do {
        try await center.add(request)
        addedIdentifiers.append(request.identifier)
      } catch {
        center.removePendingNotificationRequests(withIdentifiers: addedIdentifiers)
        return false
      }
    }
    return true
  }

  private func loadSettings() -> RealityCheckScheduleSettings {
    guard
      let data = defaults.object(forKey: StorageKey.realityCheckScheduleSettings) as? Data,
      let settings = try? JSONDecoder().decode(RealityCheckScheduleSettings.self, from: data)
    else {
      return .defaultValue
    }

    return settings
  }

  private func makeRequests(
    for settings: RealityCheckScheduleSettings,
    dayOffsets: some Sequence<Int>
  ) -> [UNNotificationRequest] {
    let calendar = Calendar.current
    let now = Date()
    var requests: [UNNotificationRequest] = []

    for dayOffset in dayOffsets {
      guard let day = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
      let startSecond = dayOffset == 0
        ? max(settings.startMinute * 60, nextSchedulableSecond(from: now))
        : settings.startMinute * 60
      let endSecond = settings.endMinute * 60
      guard startSecond < endSecond else { continue }

      let seconds = randomSeconds(
        startSecond: startSecond,
        endSecond: endSecond,
        count: settings.dailyCount
      )
      for (index, second) in seconds.enumerated() {
        guard let date = date(on: day, second: second), date > now else { continue }
        requests.append(makeRequest(date: date, dayOffset: dayOffset, index: index))
      }
    }

    return requests
  }

  private func nextSchedulableSecond(from date: Date) -> Int {
    let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
    return ((components.hour ?? 0) * 60 * 60)
      + ((components.minute ?? 0) * 60)
      + (components.second ?? 0)
      + 1
  }

  private func randomSeconds(startSecond: Int, endSecond: Int, count: Int) -> [Int] {
    let availableSeconds = max(1, endSecond - startSecond)
    let targetCount = min(count, availableSeconds)
    let bucketSize = Double(availableSeconds) / Double(targetCount)

    return (0 ..< targetCount).map { index in
      let bucketStart = startSecond + Int((Double(index) * bucketSize).rounded(.down))
      let bucketEnd = startSecond + Int((Double(index + 1) * bucketSize).rounded(.down))
      return Int.random(in: bucketStart ..< max(bucketStart + 1, bucketEnd))
    }.sorted()
  }

  private func date(on day: Date, second: Int) -> Date? {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: day)
    return calendar.date(byAdding: .second, value: second, to: startOfDay)
  }

  private func makeRequest(date: Date, dayOffset: Int, index: Int) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = String.realityCheckNotificationTitle
    content.body = String.realityCheckNotificationBodies.randomElement() ?? ""
    content.sound = .default

    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: date
    )
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let identifier = Constants.identifierPrefix + "\(dayOffset).\(index).\(Int(date.timeIntervalSince1970))"

    return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
  }

}
