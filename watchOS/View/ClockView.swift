//
//  ClockView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct ClockView: View {

  private enum Constants {

    static let tickCount = 60
    static let ticksPerHour = 5
    static let hourTickWidth: CGFloat = 0.015
    static let minuteTickWidth: CGFloat = 0.005
    static let tickHeight: CGFloat = 0.033
    static let tickOffset: CGFloat = 0.88
    static let degreesPerTick: Double = 6

  }

  let hour: Int
  let minute: Int
  let is12HourFormat: Bool

  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let radius = size / 2
      let minuteIndex = minute % Constants.tickCount
      let hourValue = is12HourFormat ? hour % 12 : hour % 24
      let hourIndex = (hourValue * Constants.ticksPerHour) % Constants.tickCount

      ZStack {
        ForEach(0 ..< Constants.tickCount, id: \.self) { tick in
          let isHourMark = tick % Constants.ticksPerHour == 0
          let width = isHourMark
            ? size * Constants.hourTickWidth
            : size * Constants.minuteTickWidth
          let height = size * Constants.tickHeight
          let highlight = tick == hourIndex || tick == minuteIndex

          (highlight ? Color.white : Color.gray)
            .frame(width: width, height: height)
            .offset(y: -radius * Constants.tickOffset)
            .rotationEffect(.degrees(Double(tick) * Constants.degreesPerTick))
        }
      }
      .frame(width: size, height: size)
      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
  }

}

#Preview {

  ClockView(hour: 15, minute: 33, is12HourFormat: true)
    .ignoresSafeArea()

}
