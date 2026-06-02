//
//  AwakenApp.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftData
import SwiftUI

@main
struct AwakenApp: App {

  @State private var container = AppContainer()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(.main)
    .environment(container.store)
    .environment(container.network)
    .environment(container.timeService)
    .environment(container.coordinator)
    .environment(container.audioPlayer)
    .environment(container.alarmService)
    .environment(\.persistence, container.persistence)
  }

}

private struct ContentView: View {

  @Environment(Coordinator.self) private var coordinator

  var body: some View {
    Group {
      switch coordinator.root {
      case .main:
        MainView()
      case .paywall:
        SubscriptionView()
      }
    }
    .preferredColorScheme(.dark)
  }
  
}
