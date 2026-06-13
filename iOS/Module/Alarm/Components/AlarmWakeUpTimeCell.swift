//
//  AlarmWakeUpTimeCell.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmWakeUpTimeCell: View {

  private enum Constants {

    static let wakeTimeVerticalPadding = 10.0
    static let selectAnimationDuration = 0.88
    static let wakeTimeMinimumScale = 0.7
    static let cycleTextMinimumScale = 0.8

  }

  let viewModel: AlarmViewModel
  let date: Date

  var body: some View {
    Button {
      withAnimation(.easeInOut(duration: Constants.selectAnimationDuration)) {
        viewModel.selectWakeUpTime(date)
      }
    } label: {
      VStack(spacing: 2) {
        Text(date.formatted(date: .omitted, time: .shortened))
          .font(AppFont.bodyMedium)
          .foregroundStyle(AppColors.primary)
          .minimumScaleFactor(Constants.wakeTimeMinimumScale)
          .lineLimit(1)
        Text(viewModel.cyclesText(for: date))
          .font(AppFont.caption)
          .foregroundStyle(AppColors.secondary)
          .minimumScaleFactor(Constants.cycleTextMinimumScale)
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, Constants.wakeTimeVerticalPadding)
      .cardStyle()
    }
    .buttonStyle(.plain)
  }

}
