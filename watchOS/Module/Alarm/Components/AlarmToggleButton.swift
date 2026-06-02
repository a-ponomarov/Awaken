//
//  AlarmToggleButton.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmToggleButton: View {

  private enum Constants {

    static let actionIconFontSize: CGFloat = 33

  }

  let isPlanned: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: isPlanned ? "stop.fill" : "play.fill")
        .font(.light(size: Constants.actionIconFontSize))
        .foregroundStyle(AppColors.textPrimary)
    }
    .buttonStyle(.plain)
    .frame(maxHeight: .infinity)
  }

}
