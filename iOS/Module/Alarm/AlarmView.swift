//
//  AlarmView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct AlarmView: View {

  @Environment(AlarmService.self) private var alarmService

  var body: some View {
    AlarmViewContent(alarmService: alarmService)
  }

}

private struct AlarmViewContent: View {

  private enum Constants {

    static let contentSpacing: CGFloat = 24
    static let presentationDetentHeight = 250.0
    static let loadAnimationDuration = 0.4

  }

  @State private var viewModel: AlarmViewModel

  @State private var presentTimePicker = false
  @State private var presentFallAsleepBufferPicker = false
  @State private var hasLoaded = false

  init(alarmService: AlarmService) {
    _viewModel = State(initialValue: AlarmViewModel(alarmService: alarmService))
  }

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      GeometryReader { proxy in
        ScrollView {
          VStack(spacing: Constants.contentSpacing) {
            Spacer()

            AlarmTimeButton(
              viewModel: viewModel,
              action: { presentTimePicker = true }
            )

            AlarmPlayStopButton(
              viewModel: viewModel
            )

            Spacer()

            AlarmRecommendationsView(
              viewModel: viewModel,
              action: { presentFallAsleepBufferPicker = true }
            )
          }
          .opacity(hasLoaded ? 1 : 0)
          .frame(maxWidth: .infinity)
          .frame(minHeight: proxy.size.height)
        }
        .scrollIndicators(.hidden)
      }
    }
    .foregroundStyle(.white)
    .alert(Text(verbatim: ""), isPresented: Bindable(viewModel).showPermissionAlert) {
      Button(String.settings) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
      Button(String.cancel, role: .cancel) { }
    } message: {
      Text(String.alarmPermissionMessage)
    }
    .sheet(isPresented: $presentTimePicker) {
      TimePickerView(
        selectedTime: Bindable(viewModel).selectedTime,
        onConfirm: { viewModel.schedule(at: $0) }
      )
    }
    .sheet(isPresented: $presentFallAsleepBufferPicker) {
      DurationSliderSheet(
        minimumMinutes: 0,
        maximumMinutes: 60,
        selectedMinutes: Bindable(viewModel).fallAsleepBufferMinutes,
        onCancel: { presentFallAsleepBufferPicker = false },
        onDone: { presentFallAsleepBufferPicker = false }
      )
      .presentationDetents([.height(Constants.presentationDetentHeight)])
      .presentationDragIndicator(.hidden)
    }
    .onAppear {
      if !hasLoaded {
        withAnimation(.easeIn(duration: Constants.loadAnimationDuration)) {
          hasLoaded = true
        }
      }
      viewModel.startClock()
    }
    .onDisappear {
      viewModel.stopClock()
    }
  }

}
