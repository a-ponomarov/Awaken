//
//  TimeTimerDial.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeTimerDial: View {

  let timeText: String
  let ringProgress: CGFloat
  let isDurationEditable: Bool
  let onTimeTap: () -> Void

  var body: some View {
    ZStack {
      Circle()
        .trim(from: 0.01, to: ringProgress - 0.01)
        .stroke(
          AppColors.surface,
          style: StrokeStyle(
            lineWidth: 18,
            lineCap: .round
          )
        )
        .rotationEffect(.degrees(90))

      Button(action: onTimeTap) {
        Text(timeText)
          .font(AppFont.displayMedium)
          .minimumScaleFactor(0.55)
          .padding(.horizontal, AppLayout.spacing * 8)
      }
      .buttonStyle(.plain)
      .allowsHitTesting(isDurationEditable)
    }
  }

}
