//
//  TimeHistoryRow.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeHistoryRow: View {

  let timeRecord: TimeRecord
  let hasTextNote: Bool
  let hasAudioRecording: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(timeRecord.timeHistoryTitleText)
            .font(AppFont.bodyMedium)
            .foregroundStyle(titleColor)
            .fixedSize(horizontal: false, vertical: true)

          HStack(spacing: 6) {
            Text(timeRecord.timeHistoryRangeText)

            noteIndicators
          }
          .font(AppFont.caption)
          .foregroundStyle(AppColors.secondary)
        }

        Spacer(minLength: AppLayout.spacing * 3)

        Text(timeRecord.duration.timeHistoryDurationText)
          .font(AppFont.body)
          .foregroundStyle(AppColors.primary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(AppLayout.cardPadding)
      .cardStyle()
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var noteIndicators: some View {
    if hasTextNote {
      Image(systemName: "book.pages")
    }

    if hasAudioRecording {
      Image(systemName: "waveform")
    }
  }

  private var titleColor: Color {
    timeRecord.hasTaskName ? AppColors.primary : AppColors.tertiary
  }

}
