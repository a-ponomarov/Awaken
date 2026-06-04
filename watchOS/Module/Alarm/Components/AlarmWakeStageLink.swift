//
//  AlarmWakeStageLink.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmWakeStageLink: View {

  private enum Constants {

    static let wakeStageFontSize: CGFloat = 12

  }

  let title: String
  @Environment(Coordinator.self) private var coordinator

  var body: some View {
    Button {
      coordinator.showWakeStagePicker()
    } label: {
      Text(String.wakeIn(title))
        .font(.bold(size: Constants.wakeStageFontSize))
        .minimumScaleFactor(0.5)
        .lineLimit(1)
        .foregroundStyle(.white)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background {
          Capsule()
            .fill(AppColors.surface)
        }
        .overlay {
          Capsule()
            .stroke(AppColors.accent, lineWidth: AppLayout.stroke)
        }
    }
    .buttonStyle(.plain)
  }

}
