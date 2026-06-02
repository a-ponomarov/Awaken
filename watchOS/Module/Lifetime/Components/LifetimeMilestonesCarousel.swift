//
//  LifetimeMilestonesCarousel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LifetimeMilestonesCarousel: View {

  private enum Constants {

    static let oneBillion: Int64 = 1_000_000_000
    static let oneTrillion: Int64 = 1_000_000_000_000

  }

  let birthday: Date
  let currentSeconds: Int64

  var body: some View {
    let oneBillionDate = birthday.addingTimeInterval(TimeInterval(Constants.oneBillion))
    let oneTrillionDate = birthday.addingTimeInterval(TimeInterval(Constants.oneTrillion))

    TabView {
      LifetimeCurrentSecondsView(value: currentSeconds)
      LifetimeMilestoneView(
        title: .billion,
        value: Constants.oneBillion,
        date: oneBillionDate,
        isReached: currentSeconds >= Constants.oneBillion,
        isInfinity: true
      )
      LifetimeMilestoneView(
        title: .trillion,
        value: Constants.oneTrillion,
        date: oneTrillionDate,
        isReached: currentSeconds >= Constants.oneTrillion,
        isInfinity: false
      )
    }
    .tabViewStyle(.carousel)
    .ignoresSafeArea()
  }

}
