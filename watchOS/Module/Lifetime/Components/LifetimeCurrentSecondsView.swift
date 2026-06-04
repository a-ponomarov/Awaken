//
//  LifetimeCurrentSecondsView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LifetimeCurrentSecondsView: View {

  private enum Constants {

    static let currentSecondsSpacing = 4.0
    static let currentSecondsHorizontalPadding = 16.0
    static let currentSecondsLabelFontSize = 11.0
    static let currentSecondsValueFontSize = 26.0

  }

  let value: Int64

  var body: some View {
    VStack(spacing: Constants.currentSecondsSpacing) {
      Text(String.secondsLived)
        .font(.bold(size: Constants.currentSecondsLabelFontSize))
        .foregroundStyle(AppColors.primary)

      Text(value.decimal)
        .font(.light(size: Constants.currentSecondsValueFontSize))
        .contentTransition(.numericText())
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    .padding(.horizontal, Constants.currentSecondsHorizontalPadding)
  }

}
