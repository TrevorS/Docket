// ABOUTME: Comprehensive tests for MeetingPlatform enum platform detection logic
// ABOUTME: Tests URL pattern matching and platform identification for different meeting providers

import Foundation
import Testing

@testable import DocketKit

struct MeetingPlatformTests {

  // MARK: - Platform Detection Tests

  @Test("Detect Zoom platform from URLs")
  func testZoomPlatformDetection() {
    let zoomURLs = [
      "https://zoom.us/j/123456789",
      "https://us02web.zoom.us/j/123456789?pwd=abcd1234",
      "https://company.zoom.us/my/room",
      "zoommtg://zoom.us/join?confno=123456789",
      "https://zoomgov.com/j/987654321",
      "http://zoom.us/webinar/register/WN_abcdefgh",
    ]

    for url in zoomURLs {
      let platform = MeetingPlatform.detectPlatform(from: url)
      #expect(platform == .zoom, "Should detect Zoom platform for URL: \(url)")
    }
  }

  @Test("Detect Google Meet platform from URLs")
  func testGoogleMeetPlatformDetection() {
    let googleMeetURLs = [
      "https://meet.google.com/abc-defg-hij",
      "http://meet.google.com/xyz-uvwx-rst",
      "https://meet.google.com/test-meet-room",
      "https://meet.google.com/lookup/abc123def456",
      "https://meet.google.com/room?pwd=password123",
    ]

    for url in googleMeetURLs {
      let platform = MeetingPlatform.detectPlatform(from: url)
      #expect(platform == .googleMeet, "Should detect Google Meet platform for URL: \(url)")
    }
  }

  @Test("Detect unknown platform for unsupported URLs")
  func testUnknownPlatformDetection() {
    let unknownURLs = [
      "https://teams.microsoft.com/meet",
      "https://webex.com/meeting/123",
      "https://example.com/meeting",
      "https://discord.com/channels/123/456",
      "mailto:someone@example.com",
      "",
      "not-a-url",
    ]

    for url in unknownURLs {
      let platform = MeetingPlatform.detectPlatform(from: url)
      #expect(platform == .unknown, "Should detect unknown platform for URL: \(url)")
    }
  }

  @Test("Platform detection is case insensitive")
  func testCaseInsensitivePlatformDetection() {
    let testCases = [
      ("HTTPS://ZOOM.US/J/123456789", MeetingPlatform.zoom),
      ("https://MEET.GOOGLE.COM/abc-defg-hij", MeetingPlatform.googleMeet),
      ("ZOOMMTG://ZOOM.US/join?confno=123", MeetingPlatform.zoom),
      ("https://ZOOMGOV.COM/j/123", MeetingPlatform.zoom),
    ]

    for (url, expectedPlatform) in testCases {
      let platform = MeetingPlatform.detectPlatform(from: url)
      #expect(
        platform == expectedPlatform,
        "Should detect \(expectedPlatform) for case-insensitive URL: \(url)")
    }
  }

  // MARK: - URL Validation Tests

  @Test("Platform matches method works correctly")
  func testPlatformMatches() {
    // Zoom URLs
    #expect(MeetingPlatform.zoom.matches(url: "https://zoom.us/j/123456789"))
    #expect(!MeetingPlatform.zoom.matches(url: "https://meet.google.com/abc-defg-hij"))
    #expect(!MeetingPlatform.zoom.matches(url: "https://teams.microsoft.com/meet"))

    // Google Meet URLs
    #expect(MeetingPlatform.googleMeet.matches(url: "https://meet.google.com/abc-defg-hij"))
    #expect(!MeetingPlatform.googleMeet.matches(url: "https://zoom.us/j/123456789"))
    #expect(!MeetingPlatform.googleMeet.matches(url: "https://webex.com/meeting"))

    // Unknown platform
    #expect(MeetingPlatform.unknown.matches(url: "https://teams.microsoft.com/meet"))
    #expect(!MeetingPlatform.unknown.matches(url: "https://zoom.us/j/123456789"))
    #expect(!MeetingPlatform.unknown.matches(url: "https://meet.google.com/abc-defg-hij"))
  }

  // MARK: - Display Properties Tests

  @Test("Display name properties are correct")
  func testDisplayNames() {
    #expect(MeetingPlatform.zoom.displayName == "Zoom")
    #expect(MeetingPlatform.googleMeet.displayName == "Google Meet")
    #expect(MeetingPlatform.unknown.displayName == "Unknown")
  }

  @Test("Short name properties are correct")
  func testShortNames() {
    #expect(MeetingPlatform.zoom.shortName == "Zoom")
    #expect(MeetingPlatform.googleMeet.shortName == "Meet")
    #expect(MeetingPlatform.unknown.shortName == "?")
  }

  @Test("Icon name properties are valid SF Symbols")
  func testIconNames() {
    #expect(MeetingPlatform.zoom.iconName == "video.fill")
    #expect(MeetingPlatform.googleMeet.iconName == "person.2.fill")
    #expect(MeetingPlatform.unknown.iconName == "questionmark.circle.fill")
  }

  @Test("Color properties are defined")
  func testColors() {
    #expect(MeetingPlatform.zoom.color == "blue")
    #expect(MeetingPlatform.googleMeet.color == "green")
    #expect(MeetingPlatform.unknown.color == "gray")
  }

  // MARK: - Enum Conformance Tests

  @Test("MeetingPlatform conforms to required protocols")
  func testProtocolConformance() {
    // Test CaseIterable
    #expect(MeetingPlatform.allCases.count == 3)
    #expect(MeetingPlatform.allCases.contains(.zoom))
    #expect(MeetingPlatform.allCases.contains(.googleMeet))
    #expect(MeetingPlatform.allCases.contains(.unknown))

    // Test Hashable (which includes Equatable)
    let platformSet: Set<MeetingPlatform> = [.zoom, .googleMeet, .unknown]
    #expect(platformSet.count == 3)
    #expect(platformSet.contains(.zoom))
  }

  @Test("Raw values are correct")
  func testRawValues() {
    #expect(MeetingPlatform.zoom.rawValue == "zoom")
    #expect(MeetingPlatform.googleMeet.rawValue == "googleMeet")
    #expect(MeetingPlatform.unknown.rawValue == "unknown")
  }
}
