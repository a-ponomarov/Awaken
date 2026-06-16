//
//  Strings.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum StorageKey {

  static let simpleAlarmDate = "SimpleAlarmDate"
  static let lastSelectedTime = "LastSelectedTime"
  static let wakeStageOption = "WakeStageOption"
  static let fallAsleepBufferMinutes = "fallAsleepBufferMinutes"
  static let realityCheckScheduleSettings = "RealityCheckScheduleSettings"
  static let subscriptionExpirationDate = "SubscriptionExpirationDate"

}

extension String {

  // MARK: - Common
  static let ok = String(localized: "OK", comment: "Generic confirmation button")
  static let done = String(localized: "Done", comment: "Generic completion button")
  static let start = String(localized: "Start", comment: "Generic start button")
  static let cancel = String(localized: "Cancel", comment: "Generic cancel button")
  static let delete = String(localized: "Delete", comment: "Generic delete button")
  static let settings = String(localized: "Settings", comment: "Label for navigating to system Settings")
  static let privacyPolicy = String(localized: "Privacy Policy", comment: "Link label opening the privacy policy")
  static let settingsTitle = settings
  static let settingsSupport = String(localized: "Contact Support", comment: "Settings support link label")
  static let settingsSourceCode = String(localized: "Source Code", comment: "Settings source code link label")

  // MARK: - App
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
  static let realityChecksTitle = String(
    localized: "Reality Checks",
    comment: "Title for reality check notification settings"
  )
  static let realityChecksExplanation = String(
    localized: "Reality checks help you notice the moment and ask: am I dreaming? If not, feel that you are awake. Repeating this habit can help the same question surface in dreams.",
    comment: "Explains why reality check notifications exist"
  )
  static let realityCheckPermissionMessage = String(
    localized: "To send reality check reminders, the app needs notification permission. You can grant it in Settings.",
    comment: "Shown when notification permission is denied for reality checks"
  )
  static let realityCheckDailyCount = String(
    localized: "Daily reminders",
    comment: "Label for the number of reality check notifications per day"
  )
  static let realityCheckSchedule = String(
    localized: "Schedule",
    comment: "Section title for reality check notification time ranges"
  )
  static let realityCheckFrom = String(
    localized: "FROM",
    comment: "Short label above the reality check start time picker"
  )
  static let realityCheckStartTime = String(
    localized: "Start time",
    comment: "Accessibility label for reality check range start time"
  )
  static let realityCheckTo = String(
    localized: "TO",
    comment: "Short label above the reality check end time picker"
  )
  static let realityCheckEndTime = String(
    localized: "End time",
    comment: "Accessibility label for reality check range end time"
  )
  static let realityCheckNotificationTitle = String(
    localized: "Reality Check",
    comment: "Reality check local notification title"
  )
  static let realityCheckNotificationBodies = [
    String(
      localized: "Look around. Notice: does this feel real?",
      comment: "Reality check local notification body"
    ),
    String(
      localized: "Feel your hands. Are you awake?",
      comment: "Reality check local notification body"
    ),
    String(
      localized: "Notice the moment. Are you dreaming?",
      comment: "Reality check local notification body"
    ),
    String(
      localized: "Feel your breath. Is this real?",
      comment: "Reality check local notification body"
    )
  ]
  static func realityCheckCount(_ count: Int) -> String {
    String.localizedStringWithFormat(
      String(localized: "%lld per day", comment: "Reality check notifications count per day"),
      Int64(count)
    )
  }
  static func realityCheckIntervalSeconds(_ seconds: Int) -> String {
    String.localizedStringWithFormat(
      String(localized: "randomly about every %lld sec", comment: "Reality check notification interval in seconds"),
      Int64(seconds)
    )
  }
  static func realityCheckIntervalMinutes(_ minutes: Int) -> String {
    String.localizedStringWithFormat(
      String(localized: "randomly about every %lld min", comment: "Reality check notification interval in minutes"),
      Int64(minutes)
    )
  }
  static func realityCheckIntervalHours(_ hours: Int) -> String {
    String.localizedStringWithFormat(
      String(localized: "randomly about every %lld hr", comment: "Reality check notification interval in hours"),
      Int64(hours)
    )
  }
  static func realityCheckIntervalHoursDecimal(_ hours: Double) -> String {
    String.localizedStringWithFormat(
      String(localized: "randomly about every %.1f hr", comment: "Reality check notification interval in decimal hours"),
      hours
    )
  }

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
  static let timeComplete = String(localized: "is up", comment: "Timer completion message shown after the app name Time")
  static let timePaused = String(localized: "Time paused", comment: "Status shown when a timer is paused")
  static let timeTaskPlaceholder = String(
    localized: "I'm focusing on...",
    comment: "Placeholder for the focus task input"
  )
  static let timeHistoryTaskPlaceholder = String(
    localized: "Task name",
    comment: "Placeholder for the completed focus session task name"
  )
  static let focusNotePlaceholder = String(
    localized: "What was done and achieved?",
    comment: "Placeholder for notes attached to a completed focus session"
  )
  static let history = String(localized: "History", comment: "Section title for past timer sessions")
  static let emptyTaskName = String(
    localized: "Empty task name",
    comment: "Fallback title for a completed focus session without a task name"
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
  static let upNext = String(localized: "Up Next", comment: "Section title for queued focus tasks")
  static let addFocusTask = String(localized: "Add focus task", comment: "Accessibility label for adding a queued focus task")
  static let addToUpNext = String(localized: "Add to Up Next", comment: "Button that adds a focus task to the queue")


  // MARK: - Notes
  static let notesTitle = String(localized: "Notes", comment: "A tab for viewing and creating notes about dreams")
  static let newNote = String(localized: "New note", comment: "A button that creates a new note")
  static let audio = String(localized: "Audio", comment: "A label displayed above the audio recording section")
  static let addAudio = String(localized: "Add audio", comment: "A button that adds an audio note")
  static let recording = String(localized: "Recording", comment: "A label for the recording state of an audio recording")
  static let stopRecording = String(localized: "Stop recording", comment: "A button that stops recording audio")
  static let deleteAudio = String(localized: "Delete audio", comment: "A button that deletes the audio note")
  static let notePlaceholder = String(localized: "Describe what you remember", comment: "A placeholder text for a note editor")

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
