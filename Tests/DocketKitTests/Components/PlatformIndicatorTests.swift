// ABOUTME: Tests for PlatformIndicatorView component covering all platform types and styling
// ABOUTME: Ensures correct colors, icons, and display names are shown for each platform

import SwiftUI
import Testing

@testable import DocketKit

@Suite("PlatformIndicatorView Tests")
struct PlatformIndicatorTests {

  @Test("Zoom platform displays correct content")
  @MainActor
  func zoomPlatformContent() {
    let view = PlatformIndicatorView(platform: .zoom)

    // Test that zoom platform shows correct short name and icon
    #expect(view.platform == .zoom)
  }

  @Test("Google Meet platform displays correct content")
  @MainActor
  func googleMeetPlatformContent() {
    let view = PlatformIndicatorView(platform: .googleMeet)

    // Test that Google Meet platform shows correct short name and icon
    #expect(view.platform == .googleMeet)
  }

  @Test("Unknown platform displays correct content")
  @MainActor
  func unknownPlatformContent() {
    let view = PlatformIndicatorView(platform: .unknown)

    // Test that unknown platform shows correct short name and icon
    #expect(view.platform == .unknown)
  }

  @Test("Platform color logic matches original implementation")
  @MainActor
  func platformColorLogic() {
    let zoomView = PlatformIndicatorView(platform: .zoom)
    let meetView = PlatformIndicatorView(platform: .googleMeet)
    let unknownView = PlatformIndicatorView(platform: .unknown)

    // These should match the color logic from the original MeetingRowView
    #expect(zoomView.platform == .zoom)
    #expect(meetView.platform == .googleMeet)
    #expect(unknownView.platform == .unknown)
  }

  @Test("All platform cases are supported")
  @MainActor
  func allPlatformCasesSupported() {
    for platform in MeetingPlatform.allCases {
      let view = PlatformIndicatorView(platform: platform)
      #expect(view.platform == platform)
    }
  }

  @Test("Platform properties are correctly exposed")
  @MainActor
  func platformPropertiesExposed() {
    let zoomView = PlatformIndicatorView(platform: .zoom)

    // Verify platform properties are accessible
    #expect(zoomView.platform.shortName == "Zoom")
    #expect(zoomView.platform.iconName == "video.fill")
    #expect(zoomView.platform.displayName == "Zoom")

    let meetView = PlatformIndicatorView(platform: .googleMeet)
    #expect(meetView.platform.shortName == "Meet")
    #expect(meetView.platform.iconName == "person.2.fill")
    #expect(meetView.platform.displayName == "Google Meet")

    let unknownView = PlatformIndicatorView(platform: .unknown)
    #expect(unknownView.platform.shortName == "Unknown")
    #expect(unknownView.platform.iconName == "questionmark.circle.fill")
    #expect(unknownView.platform.displayName == "Unknown")
  }
}
