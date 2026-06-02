//
//  Coordinator.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Observation
import Foundation
import SwiftUI

@Observable
final class Coordinator {

  var root: Root = .main
  var fullScreenCover: FullScreenDestination?
  var sheet: SheetDestination?
  var tab: MainView.RootTab = .alarm
  var alarmPath = NavigationPath()
  var dreamsPath = NavigationPath()
  var timePath = NavigationPath()

  func updateRoot(entitlementState: Store.EntitlementState) {
    switch entitlementState {
    case .active:
      root = .main
    case .inactive:
      root = .paywall
    }
  }

  func showDreamDetail(_ dream: Dream) {
    fullScreenCover = .dreamDetail(dream)
  }

  func presentSettings() {
    sheet = .settings
  }

  func dismissSheet() {
    sheet = nil
  }

}
