//
//  TimeFocusQueueRow.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/12/2026.
//

import SwiftUI

struct TimeFocusQueueRow: View {

  let focusTask: QueuedTimeRecord
  let isEnabled: Bool
  let onSelect: () -> Void
  let onStart: () -> Void

  var body: some View {
    Button(action: onSelect) {
      HStack(spacing: AppLayout.spacing * 3) {
        
        Text(focusTask.title)
          .font(AppFont.bodyMedium)
          .foregroundStyle(AppColors.primary)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)

        Spacer(minLength: 0)

        Button(action: onStart) {
          Image(systemName: "play.fill")
            .font(AppFont.buttonSmall)
            .foregroundStyle(AppColors.background)
            .frame(width: 36, height: 36)
            .background(Circle().fill(AppColors.primary.opacity(0.92)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String.startSession)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .padding(AppLayout.cardPadding)
      .cardStyle()
    }
    .buttonStyle(.plain)
    .disabled(!isEnabled)
  }

}
