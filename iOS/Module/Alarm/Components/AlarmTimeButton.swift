//
//  AlarmTimeButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmTimeButton: View {

  private enum Constants {

    static let timeMinimumScale = 0.6

  }

  let viewModel: AlarmViewModel
  let action: () -> Void

  var body: some View {
    Button {
      guard !viewModel.isAlarmActive else { return }
      action()
    } label: {
      Text(viewModel.selectedTime.time)
        .font(AppFont.displayLarge)
        .minimumScaleFactor(Constants.timeMinimumScale)
        .foregroundStyle(AppColors.primary)
        .id(viewModel.selectedTime.time)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
    .buttonStyle(.plain)
  }

}
