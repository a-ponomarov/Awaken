//
//  AlarmComplication.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmComplication: View {

  private enum Constants {

    static let iconFontSize = 14.0
    static let timeFontSize = 13.0
    static let minimumScaleFactor = 0.1
    static let horizontalPadding = 5.0
    static let placeholderTime = "--:--"

  }

  let date: Date?

  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "alarm.waves.left.and.right")
        .font(.bold(size: Constants.iconFontSize))
      if let date {
        Text(date, style: .time)
          .font(.semibold(size: Constants.timeFontSize))
          .lineLimit(1)
          .minimumScaleFactor(Constants.minimumScaleFactor)
          .padding(.horizontal, Constants.horizontalPadding)
      } else {
        Text(Constants.placeholderTime)
          .font(.light(size: Constants.timeFontSize))
          .foregroundStyle(AppColors.tertiary)
      }
    }
  }

}
