//
//  AlarmPlayStopButton.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmPlayStopButton: View {

  private enum Constants {

    static let playButtonIconFontSize = 60.0
    static let playButtonHeight = 60.0

  }

  let viewModel: AlarmViewModel

  var body: some View {
    Button(action: viewModel.toggleAlarm) {
      Image(systemName: viewModel.isAlarmActive ? "stop.fill" : "play.fill")
        .contentTransition(.symbolEffect(.replace))
        .font(.bold(size: Constants.playButtonIconFontSize))
        .foregroundStyle(AppColors.primary)
        .frame(height: Constants.playButtonHeight)
    }
    .buttonStyle(.plain)
  }

}
