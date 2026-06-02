//
//  AlarmRecommendationsView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmRecommendationsView: View {

  let viewModel: AlarmViewModel
  let action: () -> Void

  var body: some View {
    VStack(spacing: AppLayout.vInset) {
      Text(String.bedtimeMessage)
        .font(AppFont.bodyMedium)
        .foregroundStyle(AppColors.textPrimary)

      LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible())],
        spacing: AppLayout.vInset
      ) {
        ForEach(viewModel.wakeUpTimes, id: \.self) { date in
          AlarmWakeUpTimeCell(viewModel: viewModel, date: date)
        }
      }
      
      AlarmBedtimeSettingsButton(
        viewModel: viewModel,
        action: action
      )
    }
    .padding(AppLayout.cardPadding)
    .opacity(viewModel.isAlarmActive ? 0 : 1)
    .allowsHitTesting(!viewModel.isAlarmActive)
  }

}
