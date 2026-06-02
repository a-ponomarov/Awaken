//
//  TimeView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeView: View {

  static let minimumDurationMinutes = 1
  static let maximumDurationMinutes = 180

  private enum Constants {

    static let panelInsets = EdgeInsets(
      top: AppLayout.cardPadding,
      leading: AppLayout.cardPadding,
      bottom: AppLayout.cardPadding,
      trailing: AppLayout.cardPadding
    )
    static let customDurationSheetHeight = 250.0
    static let historyLabelSheetHeight = 166.0
    static let defaultCustomDuration = 45
    static let durationPresets = [25, 45, 90]
    static let minimumDurationMinutes = TimeView.minimumDurationMinutes
    static let maximumDurationMinutes = TimeView.maximumDurationMinutes

  }

  @Environment(CountdownViewModel.self) private var timeService
  @State private var isShowingCustomDurationSheet = false
  @State private var customDurationMinutes = Constants.durationPresets.first
    ?? Constants.defaultCustomDuration
  @State private var historyLabelDraft = ""
  @State private var selectedHistoryRecord: TimeRecord?

  var body: some View {
    @Bindable var timeService = timeService

    ZStack {
      ThemeGradient().ignoresSafeArea()
      List {
        TimePanelView(
          timeService: timeService,
          durationPresets: Constants.durationPresets,
          onCustomDurationTap: showCustomDurationSheet
        )
        .listRowInsets(Constants.panelInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        ForEach(historySections) { section in
          Section {
            ForEach(section.records) { timeRecord in
              TimeHistoryRow(timeRecord: timeRecord) {
                editTimeRecord(timeRecord)
              }
              .listRowInsets(AppLayout.rowItemInsets)
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: { timeService.deleteTimeRecord(timeRecord) }) {
                  Image(systemName: "trash")
                }
                .tint(.clear)
              }
            }
          } header: {
            Text(section.title.uppercased() + " " + section.totalDurationText)
              .font(AppFont.subtitle).bold()
              .foregroundStyle(AppColors.textPrimary)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.top, AppLayout.spacing)
          }
        }
      }
      .listStyle(.plain)
      .listRowSpacing(0)
      .listSectionSpacing(0)
      .scrollContentBackground(.hidden)
      .scrollIndicators(.hidden)
    }
    .foregroundStyle(AppColors.textPrimary)
    .navigationBarTitleDisplayMode(.inline)
    .alert(Text(verbatim: ""), isPresented: $timeService.showPermissionAlert) {
      Button(String.settings) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
      Button(String.cancel, role: .cancel) { }
    } message: {
      Text(String.timePermissionMessage)
    }
    .onAppear {
      timeService.refresh()
      customDurationMinutes = max(1, Int((timeService.duration / 60).rounded()))
    }
    .sheet(isPresented: $isShowingCustomDurationSheet) {
      DurationSliderSheet(
        minimumMinutes: Constants.minimumDurationMinutes,
        maximumMinutes: Constants.maximumDurationMinutes,
        selectedMinutes: $customDurationMinutes,
        onCancel: { isShowingCustomDurationSheet = false },
        onDone: applyCustomDuration
      )
      .presentationDetents([.height(Constants.customDurationSheetHeight)])
      .presentationDragIndicator(.hidden)
    }
    .sheet(isPresented: isShowingHistoryLabelSheet) {
      HistoryLabelSheet(
        label: $historyLabelDraft,
        onCancel: dismissHistoryLabelSheet,
        onDone: applyHistoryLabel
      )
      .presentationDetents([.height(Constants.historyLabelSheetHeight)])
      .presentationDragIndicator(.hidden)
    }
  }

  private func showCustomDurationSheet() {
    customDurationMinutes = max(1, Int((timeService.duration / 60).rounded()))
    isShowingCustomDurationSheet = true
  }

  private func applyCustomDuration() {
    timeService.updateDuration(minutes: customDurationMinutes)
    isShowingCustomDurationSheet = false
  }

  private func editTimeRecord(_ timeRecord: TimeRecord) {
    selectedHistoryRecord = timeRecord
    historyLabelDraft = timeRecord.taskName
  }

  private func applyHistoryLabel() {
    guard let selectedHistoryRecord else { return }

    let trimmedLabel = historyLabelDraft.trimmingCharacters(in: .whitespacesAndNewlines)
    timeService.updateTimeRecord(selectedHistoryRecord, taskName: trimmedLabel)

    dismissHistoryLabelSheet()
  }

  private func dismissHistoryLabelSheet() {
    selectedHistoryRecord = nil
    historyLabelDraft = ""
  }

  private var historySections: [TimeHistorySection] {
    TimeHistorySection.grouped(from: timeService.history)
  }

  private var isShowingHistoryLabelSheet: Binding<Bool> {
    Binding(
      get: { selectedHistoryRecord != nil },
      set: { isPresented in
        if !isPresented {
          dismissHistoryLabelSheet()
        }
      }
    )
  }

}

private struct TimeHistorySection: Identifiable {

  let date: Date
  let title: String
  var records: [TimeRecord]

  var id: Date { date }

  var totalDurationText: String {
    records
      .map(\.duration)
      .reduce(0, +)
      .timeHistoryDurationText
  }

  static func grouped(from records: [TimeRecord]) -> [TimeHistorySection] {
    var sections: [TimeHistorySection] = []
    let calendar = Calendar.current

    for record in records {
      let sectionDate = calendar.startOfDay(
        for: record.endedAt ?? record.startedAt ?? .distantPast
      )

      if let lastSection = sections.last,
         calendar.isDate(lastSection.date, inSameDayAs: sectionDate) {
        sections[sections.count - 1].records.append(record)
      } else {
        sections.append(
          TimeHistorySection(
            date: sectionDate,
            title: sectionTitle(for: sectionDate, calendar: calendar),
            records: [record]
          )
        )
      }
    }

    return sections
  }

  private static func sectionTitle(for date: Date, calendar: Calendar) -> String {
    if calendar.isDateInToday(date) {
      return String.today
    }

    if calendar.isDateInYesterday(date) {
      return String.yesterday
    }

    return date.formatted(
      .dateTime
        .weekday(.abbreviated)
        .day()
        .month(.abbreviated)
    )
  }

}

private struct HistoryLabelSheet: View {

  @Binding var label: String
  let onCancel: () -> Void
  let onDone: () -> Void
  @FocusState private var isTextFieldFocused: Bool

  var body: some View {
    NavigationStack {
      TimeTextField(
        title: String.timeHistoryTaskPlaceholder,
        text: $label,
        autocapitalization: .sentences,
        isEnabled: true,
        focus: $isTextFieldFocused,
        onSubmit: {
          isTextFieldFocused = false
        },
        onClear: {
          label = ""
        }
      )
      .padding(.horizontal, AppLayout.cardPadding)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(String.cancel, action: onCancel).tint(.white)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(String.done, action: onDone).tint(.white)
        }
      }
      .onAppear {
        isTextFieldFocused = true
      }
    }
    .background(AppColors.blue.ignoresSafeArea())
  }

}
