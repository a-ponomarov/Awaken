//
//  TimePanelView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimePanelView: View {
  
  private let timeService: CountdownViewModel
  let durationPresets: [Int]
  let onCustomDurationTap: () -> Void

  init(
    timeService: CountdownViewModel,
    durationPresets: [Int],
    onCustomDurationTap: @escaping () -> Void
  ) {
    self.timeService = timeService
    self.durationPresets = durationPresets
    self.onCustomDurationTap = onCustomDurationTap
  }

  var body: some View {
    
    @Bindable var timeService = timeService

    VStack(spacing: AppLayout.spacing * 4) {
      TimeTaskField(
        taskName: $timeService.taskName,
        isEditable: isTaskNameEditable,
        onClearTaskName: timeService.clearTaskName
      )

      TimeTimerDial(
        timeText: timeText,
        ringProgress: ringProgress,
        isDurationEditable: canEditDuration,
        onTimeTap: onCustomDurationTap
      )
      .padding()

      TimeDurationSection(
        durationPresets: durationPresets,
        selectedDurationMinutes: selectedDurationMinutes,
        canEditDuration: canEditDuration,
        onSelectPreset: timeService.updateDuration(minutes:),
        onCustomDurationTap: onCustomDurationTap
      )

      TimeActionRow(
        canStop: canStop,
        status: timeService.status,
        actionSymbolName: actionSymbolName,
        primaryActionTitle: primaryActionTitle,
        onStop: timeService.stop,
        onToggle: timeService.toggle
      )
    }
    .frame(maxWidth: .infinity)
  }

  private var canStop: Bool {
    timeService.status != .idle
  }

  private var canEditDuration: Bool {
    timeService.status == .idle
  }

  private var isTaskNameEditable: Bool {
    timeService.status == .idle
  }

  private var actionSymbolName: String {
    switch timeService.status {
    case .idle, .paused:
      "play.fill"
    case .running:
      "pause.fill"
    }
  }

  private var primaryActionTitle: String {
    switch timeService.status {
    case .idle:
      String.startSession
    case .running:
      String.pause
    case .paused:
      String.resume
    }
  }

  private var selectedDurationMinutes: Int {
    max(1, Int((timeService.duration / 60).rounded()))
  }

  private var ringProgress: CGFloat {
    switch timeService.status {
    case .idle:
      return 1
    case .running, .paused:
      let totalDuration = max(timeService.plannedDuration, 1)
      let rawProgress = timeService.remainingDuration / totalDuration
      return max(0.04, min(1, rawProgress))
    }
  }

  private var timeText: String {
    let remaining = Int(max(0, timeService.remainingDuration.rounded()))
    let minutes = remaining / 60
    let seconds = remaining % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

}
