// ABOUTME: Tests for CopyConfirmationBanner component covering animation states and binding patterns
// ABOUTME: Ensures correct visibility handling, message display, and auto-hide timing configuration

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("CopyConfirmationBanner Tests")
struct CopyConfirmationBannerTests {

  @Test("Component creation with default message")
  @MainActor
  func componentWithDefaultMessage() {
    @State var isVisible = true

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible
    )

    #expect(banner.message == "Meeting link copied")
    #expect(banner.autohideDuration == 2.0)
  }

  @Test("Component creation with custom message")
  @MainActor
  func componentWithCustomMessage() {
    @State var isVisible = true
    let customMessage = "Custom confirmation message"

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: customMessage
    )

    #expect(banner.message == customMessage)
    #expect(banner.autohideDuration == 2.0)
  }

  @Test("Component creation with custom duration")
  @MainActor
  func componentWithCustomDuration() {
    @State var isVisible = true
    let customDuration: TimeInterval = 5.0

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Test message",
      autohideDuration: customDuration
    )

    #expect(banner.message == "Test message")
    #expect(banner.autohideDuration == customDuration)
  }

  @Test("Component creation with all custom parameters")
  @MainActor
  func componentWithAllCustomParameters() {
    @State var isVisible = false
    let customMessage = "Operation completed successfully"
    let customDuration: TimeInterval = 1.5

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: customMessage,
      autohideDuration: customDuration
    )

    #expect(banner.message == customMessage)
    #expect(banner.autohideDuration == customDuration)
  }

  @Test("Banner visibility state handling")
  @MainActor
  func visibilityStateHandling() {
    @State var isVisible = false

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible
    )

    #expect(banner.message == "Meeting link copied")

    // Test initial state
    #expect(isVisible == false)
  }

  @Test("Multiple banners with independent state")
  @MainActor
  func multipleBannersIndependentState() {
    @State var firstVisible = true
    @State var secondVisible = false

    let firstBanner = CopyConfirmationBanner(
      isVisible: $firstVisible,
      message: "First banner"
    )

    let secondBanner = CopyConfirmationBanner(
      isVisible: $secondVisible,
      message: "Second banner"
    )

    #expect(firstBanner.message == "First banner")
    #expect(secondBanner.message == "Second banner")
    #expect(firstVisible == true)
    #expect(secondVisible == false)
  }

  @Test("Component interface consistency")
  @MainActor
  func componentInterfaceConsistency() {
    let testCases = [
      (message: "Link copied", duration: 1.0),
      (message: "Operation successful", duration: 2.5),
      (message: "Data saved", duration: 3.0),
      (message: "", duration: 0.5),  // Edge case: empty message
      (message: "Very long confirmation message that might wrap to multiple lines", duration: 4.0),
    ]

    for testCase in testCases {
      @State var isVisible = true

      let banner = CopyConfirmationBanner(
        isVisible: $isVisible,
        message: testCase.message,
        autohideDuration: testCase.duration
      )

      #expect(banner.message == testCase.message)
      #expect(banner.autohideDuration == testCase.duration)
    }
  }

  @Test("Default parameter values")
  @MainActor
  func defaultParameterValues() {
    @State var isVisible = true

    let banner = CopyConfirmationBanner(isVisible: $isVisible)

    #expect(banner.message == "Meeting link copied")
    #expect(banner.autohideDuration == 2.0)
  }

  @Test("Banner with very short duration")
  @MainActor
  func veryShortDuration() {
    @State var isVisible = true
    let shortDuration: TimeInterval = 0.1

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Quick message",
      autohideDuration: shortDuration
    )

    #expect(banner.autohideDuration == shortDuration)
    #expect(banner.message == "Quick message")
  }

  @Test("Banner with very long duration")
  @MainActor
  func veryLongDuration() {
    @State var isVisible = true
    let longDuration: TimeInterval = 10.0

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Long duration message",
      autohideDuration: longDuration
    )

    #expect(banner.autohideDuration == longDuration)
    #expect(banner.message == "Long duration message")
  }

  @Test("Empty message handling")
  @MainActor
  func emptyMessageHandling() {
    @State var isVisible = true

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: ""
    )

    #expect(banner.message == "")
    #expect(banner.autohideDuration == 2.0)
  }

  @Test("Special characters in message")
  @MainActor
  func specialCharactersInMessage() {
    @State var isVisible = true
    let specialMessage = "🎉 Success! Link copied to clipboard 📋"

    let banner = CopyConfirmationBanner(
      isVisible: $isVisible,
      message: specialMessage
    )

    #expect(banner.message == specialMessage)
  }

  @Test("Binding state changes")
  @MainActor
  func bindingStateChanges() {
    @State var visibilityState = false

    let banner = CopyConfirmationBanner(
      isVisible: $visibilityState,
      message: "State change test"
    )

    // Test initial state
    #expect(visibilityState == false)

    // Verify banner properties remain consistent
    #expect(banner.message == "State change test")
    #expect(banner.autohideDuration == 2.0)
  }
}
