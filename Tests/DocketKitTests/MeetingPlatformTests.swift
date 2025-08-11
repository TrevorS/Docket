// ABOUTME: Comprehensive tests for MeetingPlatform enum platform detection logic
// ABOUTME: Tests URL pattern matching and platform identification for different meeting providers

import Foundation
import SwiftUI
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
    #expect(MeetingPlatform.unknown.shortName == "Unknown")
  }

  @Test("Icon name properties are valid SF Symbols")
  func testIconNames() {
    #expect(MeetingPlatform.zoom.iconName == "video.fill")
    #expect(MeetingPlatform.googleMeet.iconName == "person.2.fill")
    #expect(MeetingPlatform.unknown.iconName == "questionmark.circle.fill")
  }

  @Test("Color properties are defined")
  func testColors() {
    // Test new SwiftUI Color properties
    #expect(MeetingPlatform.zoom.color == .blue)
    #expect(MeetingPlatform.googleMeet.color == .green)
    #expect(MeetingPlatform.unknown.color == .gray)

    // Test legacy string colors for backward compatibility
    #expect(MeetingPlatform.zoom.colorString == "blue")
    #expect(MeetingPlatform.googleMeet.colorString == "green")
    #expect(MeetingPlatform.unknown.colorString == "gray")
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

  // MARK: - Centralized Config Tests

  @Test("Platform config contains all required properties")
  func testPlatformConfigProperties() {
    // Test Zoom config
    let zoomConfig = MeetingPlatform.zoom.config
    #expect(zoomConfig.displayName == "Zoom")
    #expect(zoomConfig.shortName == "Zoom")
    #expect(zoomConfig.iconName == "video.fill")
    #expect(zoomConfig.color == .blue)
    #expect(!zoomConfig.urlPatterns.isEmpty)

    // Test Google Meet config
    let meetConfig = MeetingPlatform.googleMeet.config
    #expect(meetConfig.displayName == "Google Meet")
    #expect(meetConfig.shortName == "Meet")
    #expect(meetConfig.iconName == "person.2.fill")
    #expect(meetConfig.color == .green)
    #expect(!meetConfig.urlPatterns.isEmpty)

    // Test Unknown config
    let unknownConfig = MeetingPlatform.unknown.config
    #expect(unknownConfig.displayName == "Unknown")
    #expect(unknownConfig.shortName == "Unknown")
    #expect(unknownConfig.iconName == "questionmark.circle.fill")
    #expect(unknownConfig.color == .gray)
    #expect(unknownConfig.urlPatterns.isEmpty)
  }

  @Test("URL patterns are properly configured")
  func testURLPatternsInConfig() {
    // Zoom should have multiple URL patterns for different domains/protocols
    let zoomPatterns = MeetingPlatform.zoom.urlPatterns
    #expect(zoomPatterns.count >= 4)
    #expect(zoomPatterns.contains("https?://[\\w.-]*zoom\\.us/[^\\s]+"))
    #expect(zoomPatterns.contains("https?://[\\w.-]*zoomgov\\.com/[^\\s]+"))
    #expect(zoomPatterns.contains("zoommtg://[^\\s]+"))

    // Google Meet should have patterns for standard and lookup URLs
    let meetPatterns = MeetingPlatform.googleMeet.urlPatterns
    #expect(meetPatterns.count >= 2)
    #expect(meetPatterns.contains("https?://meet\\.google\\.com/[^\\s]+"))
    #expect(meetPatterns.contains("https?://meet\\.google\\.com/lookup/[^\\s]+"))

    // Unknown should have no patterns
    #expect(MeetingPlatform.unknown.urlPatterns.isEmpty)
  }

  @Test("Properties still work through config indirection")
  func testConfigIndirection() {
    // Verify that properties now go through config but return same values
    for platform in MeetingPlatform.allCases {
      #expect(platform.displayName == platform.config.displayName)
      #expect(platform.shortName == platform.config.shortName)
      #expect(platform.iconName == platform.config.iconName)
      #expect(platform.color == platform.config.color)
    }
  }
}
