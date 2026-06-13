//
//  TimeView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftData
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
    static let focusTaskEditorSheetHeight = 160.0
    static let defaultCustomDuration = 45
    static let durationPresets = [25, 45, 90]
    static let minimumDurationMinutes = TimeView.minimumDurationMinutes
    static let maximumDurationMinutes = TimeView.maximumDurationMinutes

  }

  @Environment(CountdownViewModel.self) private var timeService
  @Query(
    filter: #Predicate<Note> { $0.focusSession != nil },
    sort: \Note.createdAt,
    order: .reverse
  ) private var focusNotes: [Note]
  @State private var isShowingCustomDurationSheet = false
  @State private var focusTaskStartContext: FocusTaskStartContext?
  @State private var focusTaskEditorContext: FocusTaskEditorContext?
  @State private var customDurationMinutes = Constants.durationPresets.first
    ?? Constants.defaultCustomDuration
  @State private var focusTaskStartDurationMinutes = Constants.durationPresets.first
    ?? Constants.defaultCustomDuration
  @State private var pendingFocusRecord: TimeRecord?
  @State private var pendingFocusNoteID: UUID?
  @State private var selectedFocusDetail: TimeRecordDetailContext?

  var body: some View {
    @Bindable var timeService = timeService

    ZStack {
      AppColors.background.ignoresSafeArea()
      List {
        TimePanelView(
          timeService: timeService,
          durationPresets: Constants.durationPresets,
          onCustomDurationTap: showCustomDurationSheet
        )
        .listRowInsets(Constants.panelInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        Section {
          ForEach(timeService.focusQueue) { focusTask in
            TimeFocusQueueRow(
              focusTask: focusTask,
              isEnabled: timeService.status == .idle,
              onSelect: { showFocusTaskEditor(for: focusTask) },
              onStart: { showFocusTaskStartDurationSheet(for: focusTask) }
            )
            .listRowInsets(AppLayout.rowItemInsets)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
              Button(action: { timeService.deleteFocusTask(focusTask) }) {
                Image(systemName: "trash")
              }
              .tint(.clear)
            }
          }
        } header: {
          HStack {
            Text(String.upNext.uppercased())
              .font(AppFont.subtitle).bold()
              .foregroundStyle(AppColors.primary)

            Spacer()

            Button(action: showFocusTaskEditor) {
              Image(systemName: "plus")
                .font(AppFont.buttonSmall)
                .foregroundStyle(AppColors.primary)
                .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String.addFocusTask)
          }
          .padding(.top, AppLayout.spacing)
        }

        ForEach(historySections) { section in
          Section {
            ForEach(section.records) { timeRecord in
              TimeHistoryRow(
                timeRecord: timeRecord,
                hasTextNote: hasTextNote(for: timeRecord),
                hasAudioRecording: hasAudioRecording(for: timeRecord)
              ) {
                openTimeRecordDetail(timeRecord)
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
              .foregroundStyle(AppColors.primary)
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
    .foregroundStyle(AppColors.primary)
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
        onCancel: cancelCustomDuration,
        onDone: applyCustomDuration
      )
      .presentationDetents([.height(Constants.customDurationSheetHeight)])
      .presentationDragIndicator(.hidden)
    }
    .sheet(item: $focusTaskEditorContext) { context in
      QueuedTimeEditorView(
        initialTitle: context.initialTitle,
        onCancel: cancelFocusTaskEditor,
        onSave: { saveFocusTask(title: $0, context: context) }
      )
      .presentationDetents([.height(Constants.focusTaskEditorSheetHeight)])
      .presentationDragIndicator(.hidden)
    }
    .sheet(item: $focusTaskStartContext) { context in
      DurationSliderSheet(
        minimumMinutes: Constants.minimumDurationMinutes,
        maximumMinutes: Constants.maximumDurationMinutes,
        selectedMinutes: $focusTaskStartDurationMinutes,
        actionTitle: String.start,
        onCancel: cancelFocusTaskStartDuration,
        onDone: { startFocusTask(context: context) }
      )
      .presentationDetents([.height(Constants.customDurationSheetHeight)])
      .presentationDragIndicator(.hidden)
    }
    .fullScreenCover(item: $selectedFocusDetail) { detail in
      TimeRecordDetailView(
        timeRecord: detail.timeRecord,
        note: detail.note,
        onUpdateLabel: { label in
          timeService.updateTimeRecord(detail.timeRecord, taskName: label)
        }
      )
    }
    .onChange(of: focusNotes.map(\.id)) { _, _ in
      openPendingFocusDetailIfNeeded()
    }
  }

  private func showCustomDurationSheet() {
    customDurationMinutes = selectedDurationMinutes
    isShowingCustomDurationSheet = true
  }

  private func showFocusTaskEditor() {
    focusTaskEditorContext = FocusTaskEditorContext(focusTask: nil)
  }

  private func showFocusTaskEditor(for focusTask: QueuedTimeRecord) {
    guard timeService.status == .idle else { return }
    focusTaskEditorContext = FocusTaskEditorContext(focusTask: focusTask)
  }

  private func showFocusTaskStartDurationSheet(for focusTask: QueuedTimeRecord) {
    guard timeService.status == .idle else { return }
    focusTaskStartDurationMinutes = selectedDurationMinutes
    focusTaskStartContext = FocusTaskStartContext(focusTask: focusTask)
  }

  private func saveFocusTask(title: String, context: FocusTaskEditorContext) {
    if let focusTask = context.focusTask {
      timeService.updateFocusTask(focusTask, title: title)
    } else {
      timeService.addFocusTask(title: title)
    }

    cancelFocusTaskEditor()
  }

  private func cancelFocusTaskEditor() {
    focusTaskEditorContext = nil
  }

  private func applyCustomDuration() {
    timeService.updateDuration(minutes: customDurationMinutes)
    cancelCustomDuration()
  }

  private func cancelCustomDuration() {
    isShowingCustomDurationSheet = false
  }

  private func cancelFocusTaskStartDuration() {
    focusTaskStartContext = nil
  }

  private func startFocusTask(context: FocusTaskStartContext) {
    timeService.startFocusTask(
      context.focusTask,
      durationMinutes: focusTaskStartDurationMinutes
    )
    cancelFocusTaskStartDuration()
  }

  private func openTimeRecordDetail(_ timeRecord: TimeRecord) {
    pendingFocusRecord = timeRecord
    pendingFocusNoteID = nil

    Task {
      guard let noteID = await timeService.ensureNote(for: timeRecord) else { return }

      await MainActor.run {
        pendingFocusNoteID = noteID
        openPendingFocusDetailIfNeeded()
      }
    }
  }

  private func openPendingFocusDetailIfNeeded() {
    guard let pendingFocusRecord,
          let pendingFocusNoteID,
          let note = focusNotes.first(where: { $0.id == pendingFocusNoteID })
    else {
      return
    }

    let currentRecord = timeService.history.first(where: { $0.id == pendingFocusRecord.id })
      ?? pendingFocusRecord
    self.pendingFocusRecord = nil
    self.pendingFocusNoteID = nil
    selectedFocusDetail = TimeRecordDetailContext(timeRecord: currentRecord, note: note)
  }

  private var historySections: [TimeHistorySection] {
    TimeHistorySection.grouped(from: timeService.history)
  }

  private var selectedDurationMinutes: Int {
    max(1, Int((timeService.duration / 60).rounded()))
  }

  private func hasTextNote(for timeRecord: TimeRecord) -> Bool {
    guard let noteID = timeRecord.noteID,
          let note = focusNotes.first(where: { $0.id == noteID })
    else {
      return false
    }

    return !(note.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func hasAudioRecording(for timeRecord: TimeRecord) -> Bool {
    guard let noteID = timeRecord.noteID,
          let note = focusNotes.first(where: { $0.id == noteID })
    else {
      return false
    }

    return !note.dreams.isEmpty
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

private struct FocusTaskStartContext: Identifiable {

  let focusTask: QueuedTimeRecord

  var id: UUID { focusTask.id }

}

private struct FocusTaskEditorContext: Identifiable {

  let id: UUID
  let focusTask: QueuedTimeRecord?

  var initialTitle: String {
    focusTask?.title ?? ""
  }

  init(focusTask: QueuedTimeRecord?) {
    self.id = focusTask?.id ?? UUID()
    self.focusTask = focusTask
  }

}

private struct TimeRecordDetailContext: Identifiable {

  let timeRecord: TimeRecord
  let note: Note

  var id: UUID { note.id }

}
