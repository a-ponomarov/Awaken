//
//  WidgetsBundle.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {

  var body: some Widget {
    AlarmTimeWidget()
    CountdownLiveActivity()
  }

}
