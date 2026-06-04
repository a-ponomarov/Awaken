//
//  MainView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct MainView: View {

  enum RootTab: Hashable {
    case alarm
    case dreams
    case time
  }

  @Environment(\.scenePhase) private var scenePhase
  @Environment(Coordinator.self) private var coordinator
  @Environment(AlarmService.self) private var alarmService
  @Environment(CountdownViewModel.self) private var timeService

  var body: some View {
    @Bindable var coordinator = coordinator

    TabView(selection: $coordinator.tab) {
      Tab("Alarm", systemImage: "bell", value: .alarm) {
        NavigationStack(path: $coordinator.alarmPath) {
          AlarmView()
            .toolbar { settingsToolbarItem }
        }
      }

      Tab("Dream", systemImage: "waveform.badge.microphone", value: .dreams) {
        NavigationStack(path: $coordinator.dreamsPath) {
          DreamsView()
        }
      }

      Tab(String.timeTitle, systemImage: "hourglass", value: .time) {
        NavigationStack(path: $coordinator.timePath) {
          TimeView()
        }
      }
    }
    .tint(AppColors.primary)
    .onChange(of: scenePhase) { _, phase in
      guard phase == .active else { return }
      alarmService.refresh()
      timeService.refresh()
    }
    .fullScreenCover(item: $coordinator.fullScreenCover) { destination in
      switch destination {
      case .dreamDetail(let dream):
        DreamDetailView(dream: dream)
      }
    }
    .sheet(item: $coordinator.sheet) { sheet in
      switch sheet {
      case .settings:
        SettingsView()
      }
    }
  }

  private var settingsToolbarItem: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        coordinator.presentSettings()
      } label: {
        Image(systemName: "gearshape")
      }
      .accessibilityLabel(String.settingsTitle)
    }
  }

}
