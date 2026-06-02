//
//  LogView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import SwiftData

struct LogView: View {

  var body: some View {
    LogViewContent()
  }

}

private struct LogViewContent: View {

  @Query(
    filter: #Predicate<Log> { log in
      log.eventData != nil
    },
    sort: \Log.date,
    order: .reverse
  ) private var logs: [Log]

  var body: some View {
    if logs.isEmpty {
      Image(systemName: "transmission")
        .font(.regular(size: 34))
    } else {
      WatchList(logs, id: \.id) { log in
        LogRow(log: log)
      }
    }
  }

}
