//
//  RealityCheckViewModel.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/16/2026.
//

import Foundation
import UIKit

@Observable
@MainActor
final class RealityCheckViewModel {

  private let notificationService: RealityCheckNotificationService
  private let defaults: KeyValueStore
  private let encoder = JSONEncoder()

  var settings: RealityCheckScheduleSettings
  var showPermissionAlert = false

  init(
    notificationService: RealityCheckNotificationService,
    defaults: KeyValueStore = UserDefaults.standard
  ) {
    self.notificationService = notificationService
    self.defaults = defaults
    self.settings = Self.loadSettings(defaults: defaults)
  }

  var dailyCount: Int {
    settings.dailyCount
  }

  var startDate: Date {
    date(for: settings.startMinute)
  }

  var endDate: Date {
    date(for: settings.endMinute)
  }

  var startDateRange: ClosedRange<Date> {
    let lowerBound = date(for: RealityCheckScheduleSettings.minimumStartMinute)
    let upperBound = Calendar.current.date(
      byAdding: .minute,
      value: -1,
      to: endDate
    ) ?? lowerBound
    return lowerBound ... max(lowerBound, upperBound)
  }

  var endDateRange: ClosedRange<Date> {
    let lowerBound = Calendar.current.date(
      byAdding: .minute,
      value: 1,
      to: startDate
    ) ?? startDate
    let upperBound = date(for: RealityCheckScheduleSettings.maximumEndMinute)
    return min(lowerBound, upperBound) ... upperBound
  }

  var notificationIntervalText: String {
    let rangeSeconds = max(1, (settings.endMinute - settings.startMinute) * 60)
    let intervalSeconds = max(1, Int((Double(rangeSeconds) / Double(dailyCount)).rounded()))

    if intervalSeconds < 60 {
      return String.realityCheckIntervalSeconds(intervalSeconds)
    }

    let intervalMinutes = Int((Double(intervalSeconds) / 60.0).rounded())
    if intervalMinutes < 60 {
      return String.realityCheckIntervalMinutes(intervalMinutes)
    }

    let intervalHours = Double(intervalSeconds) / 3600.0
    if intervalHours.rounded() == intervalHours {
      return String.realityCheckIntervalHours(Int(intervalHours))
    }

    return String.realityCheckIntervalHoursDecimal(intervalHours)
  }

  func refreshAuthorizationStatus() {
    Task { @MainActor in
      let status = await notificationService.authorizationStatus()
      if status == .denied, settings.isEnabled {
        settings.isEnabled = false
        saveSettings()
        notificationService.cancelPendingReschedule()
        await notificationService.cancelScheduledChecks()
      }
    }
  }

  func setEnabled(_ isEnabled: Bool) {
    if isEnabled {
      enableChecks()
    } else {
      settings.isEnabled = false
      saveSettings()
      notificationService.cancelPendingReschedule()
      Task { @MainActor in
        await notificationService.cancelScheduledChecks()
      }
    }
  }

  func setDailyCount(_ dailyCount: Int) {
    settings.dailyCount = min(
      max(dailyCount, RealityCheckScheduleSettings.minimumDailyCount),
      RealityCheckScheduleSettings.maximumDailyCount
    )
    saveAndRescheduleIfNeeded()
  }

  func setStartDate(_ date: Date) {
    settings.startMinute = minute(from: date)
    if settings.startMinute >= settings.endMinute {
      settings.endMinute = min(settings.startMinute + 60, RealityCheckScheduleSettings.maximumEndMinute)
    }
    saveAndRescheduleIfNeeded()
  }

  func setEndDate(_ date: Date) {
    settings.endMinute = minute(from: date)
    if settings.endMinute <= settings.startMinute {
      settings.startMinute = max(
        settings.endMinute - 60,
        RealityCheckScheduleSettings.minimumStartMinute
      )
    }
    saveAndRescheduleIfNeeded()
  }

  func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  private func enableChecks() {
    settings.isEnabled = true
    saveSettings()

    Task { @MainActor in
      let didSchedule = await notificationService.reschedule(settings)
      if !didSchedule {
        settings.isEnabled = false
        saveSettings()
        showPermissionAlert = true
      }
    }
  }

  private func saveAndRescheduleIfNeeded() {
    saveSettings()
    guard settings.isEnabled else { return }

    notificationService.rescheduleAfterDelay(settings) { [weak self] didSchedule in
      guard !didSchedule, let self else { return }

      self.settings.isEnabled = false
      saveSettings()
      showPermissionAlert = true
    }
  }

  private func saveSettings() {
    settings = settings.normalized
    guard let data = try? encoder.encode(settings) else { return }
    defaults.set(data, forKey: StorageKey.realityCheckScheduleSettings)
  }

  private func date(for minute: Int) -> Date {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    return calendar.date(byAdding: .minute, value: minute, to: startOfDay) ?? startOfDay
  }

  private func minute(from date: Date) -> Int {
    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
    let minute = (components.hour ?? 0) * 60 + (components.minute ?? 0)
    return min(
      max(minute, RealityCheckScheduleSettings.minimumStartMinute),
      RealityCheckScheduleSettings.maximumEndMinute
    )
  }

  private static func loadSettings(defaults: KeyValueStore) -> RealityCheckScheduleSettings {
    guard
      let data = defaults.object(forKey: StorageKey.realityCheckScheduleSettings) as? Data,
      let settings = try? JSONDecoder().decode(RealityCheckScheduleSettings.self, from: data)
    else {
      return .defaultValue
    }

    return settings.normalized
  }

}
