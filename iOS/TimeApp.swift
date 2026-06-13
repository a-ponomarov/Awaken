//
//  TimeApp.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftData
import SwiftUI

@main
struct TimeApp: App {

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
    .environment(container.audioRecorder)
    .environment(container.alarmService)
    .environment(\.persistence, container.persistence)
  }

}

private struct ContentView: View {

  @Environment(Coordinator.self) private var coordinator

  var body: some View {
    Group {
      switch coordinator.root {
      case .onboarding:
        OnboardingView()
      case .main:
        MainView()
      }
    }
    .preferredColorScheme(.dark)
  }
  
}
