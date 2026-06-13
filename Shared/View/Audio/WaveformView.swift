//
//  WaveformView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct WaveformView: View {

  private enum Constants {

    static let barWidth: CGFloat = 2
    static let barSpacing: CGFloat = 2
    static let height: CGFloat = 50
    static let centerLineWidth: CGFloat = 2
    static let tapThreshold: CGFloat = 5

  }

  let samples: [Float]
  @Binding var progress: Double
  @Binding var isDragging: Bool
  var onSeek: ((Double) -> Void)? = nil

  @State private var dragOffset: CGFloat = 0

  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: Constants.barSpacing) {
        ForEach(samples.indices, id: \.self) { index in
          let height = max(CGFloat(samples[index]) * Constants.height, Constants.barWidth)
          Capsule()
            .fill(color(for: index, in: geometry))
            .frame(width: Constants.barWidth, height: height)
        }
      }
      .offset(x: calculatedOffset(in: geometry.size))
      .contentShape(Rectangle())
      .gesture(fullGesture(in: geometry.size))
      centerLine(in: geometry.size)
    }
    .frame(height: Constants.height)
  }

  private func centerLine(in size: CGSize) -> some View {
    Rectangle()
      .fill(AppColors.primary)
      .frame(width: Constants.centerLineWidth, height: Constants.height)
      .position(x: size.width / 2, y: Constants.height / 2)
  }

  private func fullGesture(in size: CGSize) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        isDragging = true
        dragOffset = value.translation.width
      }
      .onEnded { value in
        dragOffset = 0
        isDragging = false
        if abs(value.translation.width) < Constants.tapThreshold {
          handleTap(at: value.location, in: size)
        } else {
          handleSwipe(value)
        }
        haptic()
      }
  }

  private func handleTap(at location: CGPoint, in size: CGSize) {
    let offset = location.x - size.width / 2
    let newProgress = min(
      max(progress + offset / totalContentWidth, 0),
      1
    )
    progress = newProgress
    onSeek?(newProgress)
  }

  private func handleSwipe(_ value: DragGesture.Value) {
    let deltaProgress = value.translation.width / totalContentWidth
    let newProgress = min(
      max(progress - deltaProgress, 0),
      1
    )
    progress = newProgress
    onSeek?(newProgress)
  }

  private func haptic() {
    #if os(iOS)
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    #elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
    #endif
  }

  private func color(for index: Int, in geometry: GeometryProxy) -> Color {
    let progressX = progress * totalContentWidth
    let spacing = Constants.barWidth + Constants.barSpacing
    let barCenterX = CGFloat(index) * spacing
      + Constants.barWidth / 2
    return barCenterX <= progressX
      ? AppColors.primary
      : AppColors.tertiary
  }

  private func calculatedOffset(in size: CGSize) -> CGFloat {
    let totalWidth = totalContentWidth
    let currentX = progress * totalWidth
    let centerX = size.width / 2
    let dragAdjustment = dragOffset
    let xOffset = centerX - currentX + dragAdjustment
    return xOffset
  }

  private var totalContentWidth: CGFloat {
    CGFloat(samples.count) * (Constants.barWidth + Constants.barSpacing)
  }

}
