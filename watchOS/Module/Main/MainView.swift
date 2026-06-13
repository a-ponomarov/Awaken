//
//  MainView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {

  enum Tab: Int, CaseIterable {

    case alarm
    case dreams
    case lifetime
    case log

  }

  @Environment(Coordinator.self) private var coordinator
  @Environment(Session.self) private var session

  var body: some View {
    @Bindable var coordinator = coordinator

    TabView(selection: $coordinator.tab) {
      AlarmView()
      .tag(Tab.alarm)

      DreamsView()
      .tag(Tab.dreams)
      
      LifetimeView()
      .tag(Tab.lifetime)

      LogView()
        .modelContainer(.log)
        .tag(Tab.log)
    }
    .background(AppColors.background)
    .sheet(item: $coordinator.sheet) { destination in
      switch destination {
      case .alarmTimePicker(let initialTime):
        TimePicker(time: initialTime) { selectedTime in
          Task {
            await session.start(at: selectedTime)
          }
        }
      case .wakeStagePicker:
        WakeStagePickerView()
      }
    }
    .fullScreenCover(item: $coordinator.fullScreenCover) { destination in
      switch destination {
      case .dreamDetail(let dream):
        DreamDetailView(dream: dream)
      }
    }
    .alert(item: $coordinator.alert) { alert in
      switch alert {
      case .healthPermission:
        Alert(
          title: Text(verbatim: ""),
          message: Text(String.healthPermissionsMessage),
          dismissButton: .cancel(Text(String.ok))
        )
      }
    }
  }

}

#Preview {

  MainView()

}
