//
//  NotesList.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct NotesList: View {

  let notes: [Note]
  let onSelect: (Note) -> Void
  let onDelete: (Note) -> Void

  var body: some View {
    List {
      ForEach(notes, id: \.self) { note in
        NoteRow(note: note)
          .contentShape(.rect)
          .listRowInsets(AppLayout.rowItemInsets)
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: { onDelete(note) }) {
              Image(systemName: "trash")
            }
            .tint(.clear)
          }
          .onTapGesture {
            onSelect(note)
          }
      }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.hidden)
  }

}
