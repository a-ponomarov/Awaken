//
//  DateLabel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DateLabel: View {

  let date: Date

  var body: some View {
    VStack(alignment: .leading) {
      Text(date, style: .date)
        .font(AppFont.subtitle)
        .foregroundStyle(AppColors.textPrimary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      Text(date, style: .time)
        .font(AppFont.caption)
        .foregroundStyle(AppColors.textSecondary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
  }

}
