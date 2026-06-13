//
//  TimeDurationSection.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeDurationSection: View {

  let durationPresets: [Int]
  let selectedDurationMinutes: Int
  let canEditDuration: Bool
  let onSelectPreset: (Int) -> Void
  let onCustomDurationTap: () -> Void

  private var isUsingCustomDuration: Bool {
    !durationPresets.contains(selectedDurationMinutes)
  }

  var body: some View {
    HStack(spacing: 10) {
      ForEach(durationPresets, id: \.self) { minutes in
        TimePresetButton(
          title: String.minutesShort(minutes),
          isSelected: selectedDurationMinutes == minutes,
          isEnabled: canEditDuration,
          action: { onSelectPreset(minutes) }
        )
      }

      TimePresetButton(
        systemImageName: "slider.horizontal.3",
        isSelected: isUsingCustomDuration,
        isEnabled: canEditDuration,
        action: onCustomDurationTap
      )
    }
  }

}
