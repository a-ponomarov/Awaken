//
//  AwakenApp.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import SwiftData
import WatchKit

@main
struct AwakenWatchApp: App {

  @WKApplicationDelegateAdaptor(AppDelegate.self) private var delegate

  var body: some Scene {
    WindowGroup {
      MainView()
    }
    .modelContainer(.main)
    .environment(\.persistence, delegate.container.persistence)
    .environment(delegate.container.coordinator)
    .environment(delegate.container.audioPlayer)
    .environment(delegate.container.healthSource)
    .environment(delegate.container.network)
    .environment(delegate.container.session)
    
  }

}

final class AppDelegate: NSObject, WKApplicationDelegate {

  let container = AppContainer()

  func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    container.session.handle(extendedRuntimeSession: extendedRuntimeSession)
  }

  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    backgroundTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
  }

}
