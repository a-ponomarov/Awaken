//
//  LogRow.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LogRow: View {

  private enum Constants {

    static let contentSpacing: CGFloat = 8
    static let eventIconFontSize: CGFloat = 10
    static let messageFontSize: CGFloat = 13
    static let metadataFontSize: CGFloat = 7
    static let timestampVerticalPadding: CGFloat = 2
    static let timestampHorizontalPadding: CGFloat = 5

  }

  let log: Log

  var body: some View {
    VStack(spacing: Constants.contentSpacing) {
      HStack(alignment: .top, spacing: Constants.contentSpacing) {
        Text(log.timestamp)
          .padding(.vertical, Constants.timestampVerticalPadding)
          .padding(.horizontal, Constants.timestampHorizontalPadding)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .overlay {
            Capsule()
              .stroke(
                AppColors.accent,
                lineWidth: AppLayout.stroke
              )
          }

        Spacer(minLength: AppLayout.spacing * 2)

        Image(systemName: log.event?.icon ?? "")
          .font(.light(size: Constants.eventIconFontSize))
      }

      Text(log.message)
        .font(.light(size: Constants.messageFontSize))
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(AppLayout.cardPadding)
    .cardStyle(cornerRadius: AppLayout.cardRadius)
    .font(.light(size: Constants.metadataFontSize))
    .foregroundStyle(AppColors.primary)
  }

}
