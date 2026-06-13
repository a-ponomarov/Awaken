//
//  LifetimeMilestoneView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LifetimeMilestoneView: View {

  private enum Constants {

    static let milestoneSpacing = 6.0
    static let milestoneHeaderSpacing = 2.0
    static let milestoneValueSpacing = 4.0
    static let milestoneIconFontSize = 8.0
    static let milestoneTitleFontSize = 11.0
    static let milestoneInfinityFontSize = 16.0
    static let milestoneValueFontSize = 22.0
    static let milestoneDateFontSize = 10.0

  }

  let title: String
  let value: Int64
  let date: Date
  let isReached: Bool
  let isInfinity: Bool

  var body: some View {
    VStack(spacing: Constants.milestoneSpacing) {
      VStack(spacing: Constants.milestoneHeaderSpacing) {
        if isInfinity {
          Image(systemName: "star.fill")
            .font(.regular(size: Constants.milestoneIconFontSize))
            .foregroundStyle(AppColors.primary)
        }

        Text(title)
          .font(.bold(size: Constants.milestoneTitleFontSize))
          .foregroundStyle(AppColors.primary)
      }

      HStack(alignment: .lastTextBaseline, spacing: Constants.milestoneValueSpacing) {
        if isInfinity {
          Text(String.infinity)
            .font(.light(size: Constants.milestoneInfinityFontSize))
        }

        Text(value.decimal)
          .font(.light(size: Constants.milestoneValueFontSize))

        if isInfinity {
          Text(String.infinity)
            .font(.light(size: Constants.milestoneInfinityFontSize))
        }
      }
      .lineLimit(1)
      .minimumScaleFactor(0.5)

      Label(
        date.formatted(date: .abbreviated, time: .shortened),
        systemImage: isReached ? "checkmark.circle" : "calendar"
      )
      .font(.light(size: Constants.milestoneDateFontSize))
      .foregroundStyle(AppColors.secondary)
      .lineLimit(1)
      .minimumScaleFactor(0.5)
    }
    .padding(.horizontal)
  }

}
