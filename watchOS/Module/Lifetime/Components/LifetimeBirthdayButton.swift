//
//  LifetimeBirthdayButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LifetimeBirthdayButton: View {

  private enum Constants {

    static let birthdayButtonFontSize = 13.0
    static let birthdayButtonTopPadding = 4.0
    static let birthdayButtonBottomPadding = 16.0
    static let birthdayButtonVerticalPadding = 8.0
    static let birthdayButtonHorizontalPadding = 16.0

  }

  let birthday: Date
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(birthday.formatted(date: .numeric, time: .shortened))
        .font(.light(size: Constants.birthdayButtonFontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .padding(.vertical, Constants.birthdayButtonVerticalPadding)
        .padding(.horizontal, Constants.birthdayButtonHorizontalPadding)
        .background(Capsule().fill(AppColors.surface))
        .overlay {
          Capsule()
            .stroke(AppColors.accent, lineWidth: AppLayout.stroke)
        }
      
    }
    .buttonStyle(.plain)
    .padding(.top, Constants.birthdayButtonTopPadding)
    .padding(.bottom, Constants.birthdayButtonBottomPadding)
  }

}
