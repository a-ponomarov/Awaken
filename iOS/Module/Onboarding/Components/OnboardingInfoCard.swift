//
//  OnboardingInfoCard.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct OnboardingInfoCard: View {

  let title: String
  let subtitle: String
  let systemImageName: String

  var body: some View {
    HStack(spacing: AppLayout.spacing * 3) {
      Image(systemName: systemImageName)
        .font(AppFont.title)
        .foregroundStyle(AppColors.primary)
        .frame(width: 28)

      VStack(alignment: .leading, spacing: AppLayout.spacing) {
        Text(title)
          .font(AppFont.bodyMedium)
          .foregroundStyle(AppColors.primary)

        Text(subtitle)
          .font(AppFont.caption)
          .foregroundStyle(AppColors.secondary)
          .multilineTextAlignment(.leading)
      }

      Spacer()
    }
    .padding(AppLayout.cardPadding)
    .cardStyle()
  }

}
