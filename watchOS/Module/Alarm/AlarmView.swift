//
//  AlarmView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmView: View {

  @Environment(Session.self) private var session
  @Environment(HealthSource.self) private var health
  @Environment(Coordinator.self) private var coordinator

  var body: some View {
    VStack(spacing: AppLayout.spacing * 3) {
      AlarmHeartRateButton(
        heartRate: health.lastHeartRate,
        action: {
          if health.lastHeartRate == nil {
            coordinator.showHealthPermissionAlert()
          }
        }
      )
      
      Button {
        guard !session.isPlanned else { return }
        coordinator.showTimePicker(initialTime: session.expireDate)
      } label: {
        Text(session.expireDate.time)
          .font(.bold(size: 33))
          .minimumScaleFactor(0.5)
          .foregroundStyle(AppColors.primary)
      }
      .buttonStyle(.plain)

      let stage = session.wakeStage.badgeText
      let day = session.expireDate.dayLabel.uppercased()
      AlarmWakeStageLink(title: "\(stage) \(day)")
      
      AlarmToggleButton(
        isPlanned: session.isPlanned,
        action: { Task { await session.toggle() } }
      )
    }
    .padding(.horizontal, AppLayout.cardPadding)
    .task {
      await health.requestAuthorization()
      health.start()
    }
  }

}

#Preview {

  MainView()

}
