//
//  Coordinator.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Observation
import Foundation

@Observable
final class Coordinator {

  var fullScreenCover: FullScreenDestination?
  var tab: MainView.Tab = .alarm
  var alarmPath: [Route] = []
  var dreamsPath: [Route] = []
  var logPath: [Route] = []
  var lifetimePath: [Route] = []
  var sheet: SheetDestination?
  var alert: AlertDestination?

  func showTimePicker(initialTime: Date) {
    sheet = .alarmTimePicker(initialTime: initialTime)
  }

  func showWakeStagePicker() {
    sheet = .wakeStagePicker
  }

  func showDreamDetail(_ dream: Dream) {
    fullScreenCover = .dreamDetail(dream)
  }

  func showHealthPermissionAlert() {
    alert = .healthPermission
  }

  func dismissSheet() {
    sheet = nil
  }

  func dismissAlert() {
    alert = nil
  }

}
