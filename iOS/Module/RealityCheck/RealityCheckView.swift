//
//  RealityCheckView.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/16/2026.
//

import SwiftUI

struct RealityCheckView: View {

  @Environment(\.dismiss) private var dismiss
  @Environment(RealityCheckNotificationService.self) private var notificationService

  var body: some View {
    RealityCheckViewContent(notificationService: notificationService, dismiss: dismiss)
  }

}

private struct RealityCheckViewContent: View {

  @State private var viewModel: RealityCheckViewModel
  let dismiss: DismissAction

  init(notificationService: RealityCheckNotificationService, dismiss: DismissAction) {
    _viewModel = State(initialValue: RealityCheckViewModel(notificationService: notificationService))
    self.dismiss = dismiss
  }

  var body: some View {
    NavigationStack {
      List {
        explanationSection
        scheduleSection
        enableSection
        countSection
      }
      .navigationTitle(String.realityChecksTitle)
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(AppColors.background)
      .foregroundStyle(AppColors.primary)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(String.done) {
            dismiss()
          }
        }
      }
    }
    .alert(Text(verbatim: ""), isPresented: Bindable(viewModel).showPermissionAlert) {
      Button(String.settings) {
        viewModel.openSettings()
      }
      Button(String.cancel, role: .cancel) { }
    } message: {
      Text(String.realityCheckPermissionMessage)
    }
    .onAppear {
      viewModel.refreshAuthorizationStatus()
    }
  }

  private var explanationSection: some View {
    Section {
      Text(String.realityChecksExplanation)
        .font(AppFont.caption)
        .foregroundStyle(AppColors.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)
    }
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }

  private var enableSection: some View {
    Section {
      Toggle(
        "",
        isOn: Binding(
          get: { viewModel.settings.isEnabled },
          set: { viewModel.setEnabled($0) }
        )
      )
      .labelsHidden()
      .tint(AppColors.accent)
      .accessibilityLabel(String.realityChecksTitle)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }

  private var countSection: some View {
    Section {
      VStack(alignment: .center, spacing: AppLayout.spacing * 3) {
        Text(viewModel.notificationIntervalText)
          .font(AppFont.bodyMedium)
          .foregroundStyle(AppColors.secondary)
          .frame(maxWidth: .infinity, alignment: .center)

        Slider(
          value: Binding(
            get: { Double(viewModel.dailyCount) },
            set: { viewModel.setDailyCount(Int($0.rounded())) }
          ),
          in: Double(RealityCheckScheduleSettings.minimumDailyCount)
            ... Double(RealityCheckScheduleSettings.maximumDailyCount),
          step: 1
        )
        .tint(AppColors.primary)

        Stepper(
          String.realityCheckDailyCount,
          value: Binding(
            get: { viewModel.dailyCount },
            set: { viewModel.setDailyCount($0) }
          ),
          in: RealityCheckScheduleSettings.minimumDailyCount
            ... RealityCheckScheduleSettings.maximumDailyCount,
          step: 1
        )
        .labelsHidden()
        .tint(AppColors.primary)
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .padding(.vertical, AppLayout.spacing)
    }
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }

  private var scheduleSection: some View {
    Section {
      HStack(spacing: AppLayout.spacing * 8) {
        timePickerColumn(
          title: String.realityCheckFrom,
          accessibilityLabel: String.realityCheckStartTime,
          date: Binding(
            get: { viewModel.startDate },
            set: { viewModel.setStartDate($0) }
          ),
          range: viewModel.startDateRange
        )

        timePickerColumn(
          title: String.realityCheckTo,
          accessibilityLabel: String.realityCheckEndTime,
          date: Binding(
            get: { viewModel.endDate },
            set: { viewModel.setEndDate($0) }
          ),
          range: viewModel.endDateRange
        )
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.vertical, AppLayout.spacing * 2)
    }
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }

  private func timePickerColumn(
    title: String,
    accessibilityLabel: String,
    date: Binding<Date>,
    range: ClosedRange<Date>
  ) -> some View {
    VStack(alignment: .center, spacing: AppLayout.spacing * 2) {
      Text(title)
        .font(AppFont.captionMedium)
        .foregroundStyle(AppColors.secondary)

      DatePicker(
        accessibilityLabel,
        selection: date,
        in: range,
        displayedComponents: .hourAndMinute
      )
      .labelsHidden()
      .tint(AppColors.primary)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .frame(maxWidth: .infinity, alignment: .center)
  }

}
