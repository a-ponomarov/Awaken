//
//  Strings.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum StorageKey {

  static let simpleAlarmDate = "SimpleAlarmDate"
  static let lastSelectedTime = "LastSelectedTime"
  static let wakeStageOption = "WakeStageOption"
  static let fallAsleepBufferMinutes = "fallAsleepBufferMinutes"
  static let subscriptionExpirationDate = "SubscriptionExpirationDate"

}

extension String {

  // MARK: - Common
  static let ok = String(localized: "OK", comment: "Generic confirmation button")
  static let done = String(localized: "Done", comment: "Generic completion button")
  static let cancel = String(localized: "Cancel", comment: "Generic cancel button")
  static let settings = String(localized: "Settings", comment: "Label for navigating to system Settings")
  static let privacyPolicy = String(localized: "Privacy Policy", comment: "Link label opening the privacy policy")
  static let settingsTitle = settings
  static let settingsSupport = String(localized: "Contact Support", comment: "Settings support link label")
  static let settingsSourceCode = String(localized: "Source Code", comment: "Settings source code link label")

  // MARK: - App
  static let awaken = String(localized: "AWAKEN", comment: "App name displayed on the main screen")
  static let bedtimeMessage = String(
    localized: "Sleep now, wake at:",
    comment: "Bedtime recommendation header"
  )
  static let recommendedWakeUpTime = String(
    localized: "Recommended wake-up time:",
    comment: "Header above the suggested wake-up times list"
  )
  static func wakeIn(_ title: String) -> String {
    String.localizedStringWithFormat(
      String(
        localized: "IN %@",
        comment: "Wake-stage badge text. The argument contains the selected sleep stage and day label."
      ),
      title
    )
  }
  static let wakeDuring = String(localized: "WAKE DURING", comment: "Title for the wake-stage picker")
  static let lightSleep = String(localized: "LIGHT SLEEP", comment: "Sleep stage label")
  static let timeToFallAsleep = String(
    localized: "TIME TO FALL ASLEEP",
    comment: "Label for the fall-asleep buffer setting"
  )
  static func minutesShort(_ minutes: Int) -> String {
    String.localizedStringWithFormat(
      String(localized: "%lld min", comment: "A label displaying the selected duration in minutes. The argument is the selected duration in minutes."),
      Int64(minutes)
    )
  }
  static let cycles = String(localized: "cycles", comment: "Sleep cycles unit suffix")

  // MARK: - Alarm
  static let alarmPermissionMessage = String(
    localized: "To wake you up, the app needs permission to schedule alarms. You can grant it in Settings",
    comment: "Shown when AlarmKit permission is denied"
  )
  static let timePermissionMessage = String(
    localized: "To notify you when task timers end, the app needs permission to schedule alarms. You can grant it in Settings.",
    comment: "Shown when alarm permission is denied for the Time module"
  )

  // MARK: - Wake Stage
  nonisolated static let dreamStage = String(
    localized: "DREAM",
    comment: "Wake-stage option label (uppercase) — REM/dream sleep phase"
  )
  nonisolated static let lightStage = String(
    localized: "LIGHT SLEEP",
    comment: "Wake-stage option label (uppercase) — light sleep phase"
  )
  nonisolated static let dreamStageHint = String(
    localized: "lucidity",
    comment: "Wake-stage option subtitle: waking during REM gives lucid/aware feeling"
  )
  nonisolated static let lightStageHint = String(
    localized: "freshness",
    comment: "Wake-stage option subtitle: waking during light sleep feels fresh"
  )
  nonisolated static let dreamStageBadge = String(
    localized: "DREAMING",
    comment: "Wake-stage badge label used after the prefix \"WAKE IN\""
  )
  nonisolated static let lightStageBadge = String(
    localized: "LIGHT SLEEP STAGE",
    comment: "Wake-stage badge label used after the prefix \"WAKE IN\""
  )

  // MARK: - Time Module
  static let timeTitle = String(localized: "Time", comment: "Time module title")
  static let timeComplete = String(localized: "Time is up", comment: "Timer completion message")
  static let timePaused = String(localized: "Time paused", comment: "Status shown when a timer is paused")
  static let timeTaskPlaceholder = String(
    localized: "I'm focusing on...",
    comment: "Placeholder for the focus task input"
  )
  static let timeHistoryTaskPlaceholder = String(
    localized: "Focus label",
    comment: "Placeholder for the focus label in history rows"
  )
  static let history = String(localized: "History", comment: "Section title for past timer sessions")
  static let addFocusLabel = String(
    localized: "+ Add a focus label",
    comment: "Button to add a label to a timer session"
  )
  nonisolated static let today = String(localized: "Today", comment: "Date group header")
  nonisolated static let tomorrow = String(localized: "Tomorrow", comment: "Date group header")
  nonisolated static let yesterday = String(localized: "Yesterday", comment: "Date group header")
  static let ready = String(localized: "Ready", comment: "Timer state: ready to start")
  static let running = String(localized: "Running", comment: "Timer state: currently running")
  static let paused = String(localized: "Paused", comment: "Timer state: paused")
  static let duration = String(localized: "Duration", comment: "Label for the timer duration field")
  static let startSession = String(
    localized: "Start session",
    comment: "VoiceOver/accessibility label for the timer start button"
  )
  static let pause = String(localized: "Pause", comment: "Pause action button")
  static let resume = String(localized: "Resume", comment: "Resume action button")

  // MARK: - Health
  static let healthPermissionsMessage = String(
    localized: "For smart alarm and personalization, the app needs Health permissions. You can grant them on your paired iPhone: Health app > Profile Picture > Apps",
    comment: "Shown on watchOS when HealthKit permission is missing"
  )
  static let microphonePermissionMessage = String(
    localized: "To record your dream, the app needs microphone access. You can grant it in Settings",
    comment: "iOS microphone permission rationale"
  )
  static let watchMicrophonePermissionMessage = String(
    localized: "To record your dream, allow microphone access in Settings > Privacy & Security > Microphone",
    comment: "watchOS microphone permission rationale"
  )

  // MARK: - Paywall
  static let waitingForNetwork = String(
    localized: "Waiting for Network",
    comment: "Network loading state on the paywall"
  )
  static let tryAgain = String(localized: "Try Again", comment: "Retry button after a network failure")
  static let confirmPurchase = String(localized: "Confirm purchase", comment: "Paywall purchase confirmation label")
  static let slideToConfirm = String(
    localized: "slide to subscribe",
    comment: "Slider hint to confirm a subscription"
  )

  // MARK: - Time
  static let dateOfBirth = String(localized: "DATE OF BIRTH", comment: "Field label for the user's birth date")
  static let secondsLived = String(localized: "SECONDS LIVED", comment: "Metric label: total seconds since birth")
  static let billion = String(localized: "BILLION", comment: "Large-number unit suffix")
  static let trillion = String(localized: "TRILLION", comment: "Large-number unit suffix")
  static let years = String(localized: "YEARS", comment: "Time unit (uppercase)")
  static let months = String(localized: "MONTHS", comment: "Time unit (uppercase)")
  static let weeks = String(localized: "WEEKS", comment: "Time unit (uppercase)")
  static let days = String(localized: "DAYS", comment: "Time unit (uppercase)")
  static let hours = String(localized: "HOURS", comment: "Time unit (uppercase)")
  static let minutes = String(localized: "MINUTES", comment: "Time unit (uppercase)")
  static let reached = String(localized: "REACHED", comment: "Status label: milestone reached")
  static let future = String(localized: "FUTURE", comment: "Status label: future event")
  static let next = String(localized: "NEXT", comment: "Status label: next event")
  static let infinity = "∞"

  // MARK: - Calculator
  static let wakeUpTimes = String(
    localized: "Wake-up times:",
    comment: "Header above the list of wake-up time options"
  )
  static let date = String(localized: "DATE", comment: "Field label for date")
  static let time = String(localized: "TIME", comment: "Field label for time")

  // MARK: - Store
  static let purchaseAwaitingApproval = String(
    localized: "Your purchase is awaiting approval",
    comment: "Status shown when a purchase requires Ask-to-Buy approval"
  )
  static let checkInternetConnection = String(
    localized: "Please check your internet connection and try again",
    comment: "Generic network error message"
  )
  static let appStoreUnavailable = String(
    localized: "App Store service is currently unavailable. Please try again later",
    comment: "Shown when StoreKit service is unavailable"
  )

}
