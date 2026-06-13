//
//  LifetimeView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct LifetimeView: View {

  @Environment(\.persistence) private var persistence

  @State private var birthday: Date?
  @State private var birthdaySaveTask: Task<Void, Never>?
  @State private var showDatePicker = false

  private var birthdayBinding: Binding<Date> {
    Binding(
      get: { birthday ?? .now },
      set: { newBirthday in
        self.birthday = newBirthday
        birthdaySaveTask?.cancel()
        birthdaySaveTask = Task {
          await persistence.updateUserBirthday(newBirthday)
        }
      }
    )
  }

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      if birthday != nil {
        LifetimeContentView(
          birthday: birthdayBinding,
          showDatePicker: $showDatePicker
        )
      }
    }
    .task {
      await persistence.ensureUser()
      birthday = await persistence.fetchUserBirthday()
    }
    .onDisappear {
      birthdaySaveTask?.cancel()
      birthdaySaveTask = nil
    }
  }

}

private struct LifetimeContentView: View {

  @Binding var birthday: Date
  @Binding var showDatePicker: Bool

  var body: some View {
    VStack(spacing: 0) {
      Text(String.infinity)
        .font(.light(size: 16))
        .sheet(isPresented: $showDatePicker) {
          CustomDatePickerView(selection: $birthday)
        }

      TimelineView(.periodic(from: .now, by: 1.0)) { _ in
        let currentSeconds = birthday.livedTotal(for: .second)
        LifetimeMilestonesCarousel(
          birthday: birthday,
          currentSeconds: currentSeconds
        )
      }

      LifetimeBirthdayButton(
        birthday: birthday,
        action: { showDatePicker = true }
      )
    }
  }

}

#Preview {

  LifetimeView()

}
