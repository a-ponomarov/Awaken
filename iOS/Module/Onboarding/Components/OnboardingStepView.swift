//
//  OnboardingStepView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/11/2026.
//

import SwiftUI

enum OnboardingStep: CaseIterable, Identifiable {

  struct Card: Identifiable {

    let title: String
    let subtitle: String
    let systemImageName: String

    var id: String { systemImageName }

  }

  case smartWakeUp
  case ecosystem

  var id: Self { self }

  var systemImageName: String {
    switch self {
    case .smartWakeUp:
      "sparkles"
    case .ecosystem:
      "target"
    }
  }

  var title: String {
    switch self {
    case .smartWakeUp:
      String(localized: "Smart wake-up modes", comment: "Onboarding goal screen title")
    case .ecosystem:
      String(localized: "Remember dreams. Build focus.", comment: "Onboarding ecosystem screen title")
    }
  }

  var subtitle: String {
    switch self {
    case .smartWakeUp:
      String(
        localized: "Apple Watch uses heart rate and motion to help find a gentler wake-up moment.",
        comment: "Onboarding goal screen subtitle"
      )
    case .ecosystem:
      String(
        localized: "Awaken connects your night, morning, and focused work into one daily rhythm.",
        comment: "Onboarding ecosystem screen subtitle"
      )
    }
  }

  var cards: [Card] {
    switch self {
    case .smartWakeUp:
      WakeStageOption.allCases.map { wakeStage in
        Card(
          title: wakeStage.leadingText,
          subtitle: wakeStage.onboardingSubtitle,
          systemImageName: wakeStage.onboardingSystemImageName
        )
      }
    case .ecosystem:
      [
        Card(
          title: String(localized: "Dream notes", comment: "Onboarding notes feature title"),
          subtitle: String(
            localized: "Capture dreams while they are still vivid, with text and audio notes.",
            comment: "Onboarding notes feature description"
          ),
          systemImageName: "text.book.closed.fill"
        ),
        Card(
          title: String(localized: "Focus timer", comment: "Onboarding timer feature title"),
          subtitle: String(
            localized: "Turn morning intention into focused sessions that move you toward your goals.",
            comment: "Onboarding timer feature description"
          ),
          systemImageName: "timer"
        )
      ]
    }
  }

}

struct OnboardingStepView: View {

  let step: OnboardingStep

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: AppLayout.spacing * 3) {
          VStack(spacing: AppLayout.spacing * 2) {
            Image(systemName: step.systemImageName)
              .font(.system(size: 44, weight: .semibold))
              .foregroundStyle(AppColors.primary)

            Text(step.title)
              .font(AppFont.title)
              .foregroundStyle(AppColors.primary)
              .multilineTextAlignment(.center)

            Text(step.subtitle)
              .font(AppFont.caption)
              .foregroundStyle(AppColors.secondary)
              .multilineTextAlignment(.center)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity)
          }

          VStack(spacing: AppLayout.spacing * 2) {
            ForEach(step.cards) { card in
              OnboardingInfoCard(
                title: card.title,
                subtitle: card.subtitle,
                systemImageName: card.systemImageName
              )
            }
          }
        }
        .frame(maxWidth: .infinity)
        .padding(AppLayout.cardPadding)
        .frame(minHeight: proxy.size.height)
      }
      .scrollIndicators(.hidden)
    }
  }

}

private extension WakeStageOption {

  var onboardingSubtitle: String {
    switch self {
    case .light:
      String(
        localized: "Wake during a lighter stage, when getting up can feel easier.",
        comment: "Onboarding light sleep wake-up goal description"
      )
    case .dream:
      String(
        localized: "Wake while dreaming, when memories are easier to capture.",
        comment: "Onboarding dream wake-up goal description"
      )
    }
  }

  var onboardingSystemImageName: String {
    switch self {
    case .light:
      "sunrise.fill"
    case .dream:
      "moon.stars.fill"
    }
  }

}
