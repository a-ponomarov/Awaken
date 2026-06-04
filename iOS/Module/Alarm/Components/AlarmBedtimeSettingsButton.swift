//
//  AlarmBedtimeSettingsButton.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmBedtimeSettingsButton: View {

  private enum Constants {

    static let settingRowSpacing: CGFloat = 4
    static let settingLabelSpacing: CGFloat = 8
    static let settingsVerticalPadding = 12.0

  }

  let viewModel: AlarmViewModel
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: Constants.settingRowSpacing) {
        HStack(spacing: Constants.settingLabelSpacing) {
          Image(systemName: "bed.double.fill")
          Text(String.timeToFallAsleep)
        }
        Text(String.minutesShort(viewModel.fallAsleepBufferMinutes))
          .foregroundStyle(AppColors.primary)
      }
      .font(AppFont.caption)
      .foregroundStyle(AppColors.primary)
      .frame(maxWidth: .infinity)
      .padding(.vertical, Constants.settingsVerticalPadding)
      .cardStyle()
    }
    .buttonStyle(.plain)
  }

}
