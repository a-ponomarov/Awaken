//
//  TimeHistoryRow.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeHistoryRow: View {

  let timeRecord: TimeRecord
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(timeRecord.timeHistoryTitleText)
            .font(AppFont.bodyMedium)
            .foregroundStyle(AppColors.primary)
            .fixedSize(horizontal: false, vertical: true)

          Text(timeRecord.timeHistoryRangeText)
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

}
