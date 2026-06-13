//
//  AlarmHeartRateButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmHeartRateButton: View {

  private enum Constants {

    static let heartIconFontSize: CGFloat = 33
    static let heartRateFontSize: CGFloat = 10

  }

  let heartRate: Double?
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        Image(systemName: "heart.fill")
          .offset(y: 1)
          .foregroundStyle(AppColors.accent)
          .font(.bold(size: Constants.heartIconFontSize))
          .shadow(color: AppColors.accent, radius: 1)

        if let heartRate {
          Text(Int(heartRate), format: .number)
            .font(.bold(size: Constants.heartRateFontSize))
            .foregroundStyle(.white)
        }
      }
    }
    .buttonStyle(.plain)
  }

}
