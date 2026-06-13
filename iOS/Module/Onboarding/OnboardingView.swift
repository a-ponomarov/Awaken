//
//  OnboardingView.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import SwiftUI

struct OnboardingView: View {

  @Environment(Coordinator.self) private var coordinator
  @Environment(Store.self) private var store

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: AppLayout.cardPadding) {
        TabView {
          ForEach(OnboardingStep.allCases) { step in
            OnboardingStepView(step: step)
          }

          SubscriptionView()
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
      }
    }
    .preferredColorScheme(.dark)
    .onAppear {
      coordinator.updateRoot(entitlementState: store.entitlementState)
    }
    .onChange(of: store.entitlementState) { _, entitlementState in
      coordinator.updateRoot(entitlementState: entitlementState)
    }
  }

}

