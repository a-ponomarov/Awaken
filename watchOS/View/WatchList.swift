//
//  WatchList.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/20/2026.
//

import SwiftUI

struct WatchList<Data, ID, HeaderContent, RowContent>: View
where Data: RandomAccessCollection, ID: Hashable, HeaderContent: View, RowContent: View {

  private let data: Data
  private let id: KeyPath<Data.Element, ID>
  private let spacing: CGFloat
  private let headerContent: HeaderContent
  private let rowContent: (Data.Element) -> RowContent

  init(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    spacing: CGFloat = AppLayout.vInset,
    @ViewBuilder header: () -> HeaderContent,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) {
    self.data = data
    self.id = id
    self.spacing = spacing
    self.headerContent = header()
    self.rowContent = rowContent
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: spacing) {
        headerContent

        ForEach(data, id: id) { element in
          rowContent(element)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, AppLayout.cardPadding)
    }
    .scrollIndicators(.hidden)
  }

}

extension WatchList where HeaderContent == EmptyView {

  init(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    spacing: CGFloat = AppLayout.vInset,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) {
    self.init(
      data,
      id: id,
      spacing: spacing,
      header: { EmptyView() },
      rowContent: rowContent
    )
  }

}
