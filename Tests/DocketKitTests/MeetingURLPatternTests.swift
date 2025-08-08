// ABOUTME: Comprehensive tests for MeetingURLPattern enum regex matching
// ABOUTME: Tests all meeting URL variations including Zoom and Google Meet patterns

import Foundation
import Testing

@testable import DocketKit

struct MeetingURLPatternTests {

  // MARK: - Standard Zoom URL Tests

  @Test func testStandardZoomURLs() {
    let validStandardURLs = [
      "https://zoom.us/j/123456789",
      "http://zoom.us/j/987654321",
      "https://us02web.zoom.us/j/123456789?pwd=abcd1234",
      "https://zoom.us/webinar/register/WN_abcdefgh",
      "https://zoom.us/meeting/register/tJwtdO2hpzIrGNacVtgY",
      "https://www.zoom.us/j/123456789",
      "https://zoom.us/j/123456789?pwd=test&uname=user",
      "http://us04web.zoom.us/j/123456789",
    ]

    let pattern = MeetingURLPattern.zoomStandard
    let regex = pattern.regex

    #expect(regex != nil, "Standard pattern should create valid regex")

    for url in validStandardURLs {
      let range = NSRange(location: 0, length: url.utf16.count)
      let matches = regex!.matches(in: url, options: [], range: range)
      #expect(matches.count > 0, "Should match standard URL: \(url)")
    }
  }

  @Test func testStandardZoomURLsInText() {
    let textWithURL = "Please join the meeting: https://zoom.us/j/123456789 at 2 PM"
    let pattern = MeetingURLPattern.zoomStandard
    let regex = pattern.regex

    #expect(regex != nil)

    let range = NSRange(location: 0, length: textWithURL.utf16.count)
    let matches = regex!.matches(in: textWithURL, options: [], range: range)
    #expect(matches.count == 1, "Should find one URL in text")

    if let match = matches.first {
      let matchedURL = String(textWithURL[Range(match.range, in: textWithURL)!])
      #expect(matchedURL == "https://zoom.us/j/123456789")
    }
  }

  @Test func testNonZoomStandardURLs() {
    let nonZoomURLs = [
      "https://google.com",
      "https://teams.microsoft.com/meet",
      "https://meet.google.com/abc-defg-hij",
      "https://webex.com/meeting/123",
      "https://example.com/zoom/meeting",  // Contains "zoom" but not zoom.us domain
      "",
    ]

    let pattern = MeetingURLPattern.zoomStandard
    let regex = pattern.regex

    #expect(regex != nil)

    for url in nonZoomURLs {
      let range = NSRange(location: 0, length: url.utf16.count)
      let matches = regex!.matches(in: url, options: [], range: range)
      #expect(matches.count == 0, "Should NOT match non-Zoom URL: \(url)")
    }
  }

  // MARK: - Government Zoom URL Tests

  @Test func testGovernmentZoomURLs() {
    let validGovURLs = [
      "https://zoomgov.com/j/123456789",
      "http://zoomgov.com/j/987654321",
      "https://us02web.zoomgov.com/j/123456789?pwd=abcd1234",
      "https://www.zoomgov.com/webinar/register/WN_abcdefgh",
      "https://zoomgov.com/meeting/register/tJwtdO2hpzIrGNacVtgY",
    ]

    let pattern = MeetingURLPattern.zoomGovernment
    let regex = pattern.regex

    #expect(regex != nil, "Government pattern should create valid regex")

    for url in validGovURLs {
      let range = NSRange(location: 0, length: url.utf16.count)
      let matches = regex!.matches(in: url, options: [], range: range)
      #expect(matches.count > 0, "Should match government URL: \(url)")
    }
  }

  @Test func testGovernmentVsStandardDistinction() {
    let govURL = "https://zoomgov.com/j/123456789"
    let standardURL = "https://zoom.us/j/123456789"

    let govPattern = MeetingURLPattern.zoomGovernment
    let standardPattern = MeetingURLPattern.zoomStandard

    // Gov URL should match gov pattern but not standard
    let govRange = NSRange(location: 0, length: govURL.utf16.count)
    let govInGov = govPattern.regex!.matches(in: govURL, options: [], range: govRange)
    let govInStandard = standardPattern.regex!.matches(in: govURL, options: [], range: govRange)

    #expect(govInGov.count > 0, "Gov URL should match gov pattern")
    #expect(govInStandard.count == 0, "Gov URL should NOT match standard pattern")

    // Standard URL should match standard pattern but not gov
    let standardRange = NSRange(location: 0, length: standardURL.utf16.count)
    let standardInStandard = standardPattern.regex!.matches(
      in: standardURL, options: [], range: standardRange)
    let standardInGov = govPattern.regex!.matches(
      in: standardURL, options: [], range: standardRange)

    #expect(standardInStandard.count > 0, "Standard URL should match standard pattern")
    #expect(standardInGov.count == 0, "Standard URL should NOT match gov pattern")
  }

  // MARK: - Protocol URL Tests

  @Test func testProtocolURLs() {
    let validProtocolURLs = [
      "zoommtg://zoom.us/join?confno=123456789",
      "zoommtg://zoom.us/join?confno=123456789&pwd=abcd1234",
      "zoommtg://us02web.zoom.us/join?confno=987654321",
      "zoommtg://zoom.us/join?confno=555666777&uname=TestUser",
    ]

    let pattern = MeetingURLPattern.zoomProtocol
    let regex = pattern.regex

    #expect(regex != nil, "Protocol pattern should create valid regex")

    for url in validProtocolURLs {
      let range = NSRange(location: 0, length: url.utf16.count)
      let matches = regex!.matches(in: url, options: [], range: range)
      #expect(matches.count > 0, "Should match protocol URL: \(url)")
    }
  }

  @Test func testProtocolURLsInText() {
    let textWithProtocol = "Launch directly with: zoommtg://zoom.us/join?confno=123456789"
    let pattern = MeetingURLPattern.zoomProtocol
    let regex = pattern.regex

    let range = NSRange(location: 0, length: textWithProtocol.utf16.count)
    let matches = regex!.matches(in: textWithProtocol, options: [], range: range)
    #expect(matches.count == 1, "Should find protocol URL in text")
  }

  // MARK: - Vanity URL Tests

  @Test func testVanityURLs() {
    let validVanityURLs = [
      "https://company.zoom.us/my/meetingroom",
      "http://myteam.zoom.us/j/personal123",
      "https://school.zoom.us/webinar/register/WN_abcdefgh",
      "https://organization.zoom.us/meeting/register/tJwtdO2h",
      "https://subdomain.zoom.us/j/123456789?pwd=test",
    ]

    let pattern = MeetingURLPattern.zoomVanity
    let regex = pattern.regex

    #expect(regex != nil, "Vanity pattern should create valid regex")

    for url in validVanityURLs {
      let range = NSRange(location: 0, length: url.utf16.count)
      let matches = regex!.matches(in: url, options: [], range: range)
      #expect(matches.count > 0, "Should match vanity URL: \(url)")
    }
  }

  @Test func testVanityVsStandardDistinction() {
    // Standard zoom.us URLs should match standard pattern but NOT vanity pattern
    let standardURL = "https://zoom.us/j/123456789"

    // Vanity URL with subdomain should match vanity pattern but also standard pattern
    let vanityURL = "https://company.zoom.us/j/123456789"

    let standardPattern = MeetingURLPattern.zoomStandard
    let vanityPattern = MeetingURLPattern.zoomVanity

    // Test standard URL
    let standardRange = NSRange(location: 0, length: standardURL.utf16.count)
    let standardInStandard = standardPattern.regex!.matches(
      in: standardURL, options: [], range: standardRange)
    let standardInVanity = vanityPattern.regex!.matches(
      in: standardURL, options: [], range: standardRange)

    #expect(standardInStandard.count > 0, "Standard URL should match standard pattern")
    #expect(
      standardInVanity.count == 0, "Standard URL should NOT match vanity pattern (no subdomain)")

    // Test vanity URL
    let vanityRange = NSRange(location: 0, length: vanityURL.utf16.count)
    let vanityInStandard = standardPattern.regex!.matches(
      in: vanityURL, options: [], range: vanityRange)
    let vanityInVanity = vanityPattern.regex!.matches(
      in: vanityURL, options: [], range: vanityRange)

    #expect(
      vanityInStandard.count > 0,
      "Vanity URL should match standard pattern (*.zoom.us includes zoom.us)")
    #expect(vanityInVanity.count > 0, "Vanity URL should match vanity pattern")
  }

  // MARK: - Pattern Enum Tests

  @Test func testAllPatternsHaveValidRegex() {
    for pattern in MeetingURLPattern.allCases {
      #expect(pattern.regex != nil, "Pattern \(pattern) should have valid regex")
    }
  }

  @Test func testPatternRawValues() {
    #expect(MeetingURLPattern.zoomStandard.rawValue == "https?://[\\w.-]*zoom\\.us/[^\\s]+")
    #expect(MeetingURLPattern.zoomGovernment.rawValue == "https?://[\\w.-]*zoomgov\\.com/[^\\s]+")
    #expect(MeetingURLPattern.zoomProtocol.rawValue == "zoommtg://[^\\s]+")
    #expect(MeetingURLPattern.zoomVanity.rawValue == "https?://[\\w.-]*\\.zoom\\.us/[^\\s]+")
  }

  @Test func testAllCasesCount() {
    #expect(
      MeetingURLPattern.allCases.count == 6,
      "Should have exactly 6 URL pattern types (4 Zoom + 2 Google Meet)")
  }

  // MARK: - Google Meet URL Tests

  @Test func testGoogleMeetURLs() {
    let validGoogleMeetURLs = [
      "https://meet.google.com/abc-defg-hij",
      "http://meet.google.com/xyz-uvwx-rst",
      "https://meet.google.com/abc-defg-hij?pwd=password123",
      "https://meet.google.com/test-meet-room",
      "https://meet.google.com/lookup/abc123def456",
    ]

    // Test both Google Meet patterns
    let patterns = [MeetingURLPattern.googleMeet, MeetingURLPattern.googleMeetLookup]

    for url in validGoogleMeetURLs {
      var foundMatch = false
      for pattern in patterns {
        let regex = pattern.regex
        #expect(regex != nil, "Pattern \(pattern) should create valid regex")

        let range = NSRange(location: 0, length: url.utf16.count)
        if let matches = regex?.matches(in: url, options: [], range: range), matches.count > 0 {
          foundMatch = true
          break
        }
      }
      #expect(foundMatch, "Should match Google Meet URL: \(url)")
    }
  }

  @Test func testGoogleMeetPlatformDetection() {
    let googleMeetURL = "https://meet.google.com/abc-defg-hij"
    let zoomURL = "https://zoom.us/j/123456789"

    let googleMeetPattern = MeetingURLPattern.googleMeet
    let zoomStandardPattern = MeetingURLPattern.zoomStandard

    // Google Meet URL should match Google Meet pattern but not Zoom
    let googleMeetRange = NSRange(location: 0, length: googleMeetURL.utf16.count)
    let googleMeetInGoogleMeet = googleMeetPattern.regex!.matches(
      in: googleMeetURL, options: [], range: googleMeetRange)
    let googleMeetInZoom = zoomStandardPattern.regex!.matches(
      in: googleMeetURL, options: [], range: googleMeetRange)

    #expect(googleMeetInGoogleMeet.count > 0, "Google Meet URL should match Google Meet pattern")
    #expect(googleMeetInZoom.count == 0, "Google Meet URL should NOT match Zoom pattern")

    // Zoom URL should match Zoom pattern but not Google Meet
    let zoomRange = NSRange(location: 0, length: zoomURL.utf16.count)
    let zoomInZoom = zoomStandardPattern.regex!.matches(in: zoomURL, options: [], range: zoomRange)
    let zoomInGoogleMeet = googleMeetPattern.regex!.matches(
      in: zoomURL, options: [], range: zoomRange)

    #expect(zoomInZoom.count > 0, "Zoom URL should match Zoom pattern")
    #expect(zoomInGoogleMeet.count == 0, "Zoom URL should NOT match Google Meet pattern")
  }

  @Test func testMeetingURLPatternPlatformProperty() {
    // Test that each pattern returns the correct platform
    #expect(MeetingURLPattern.zoomStandard.platform == .zoom)
    #expect(MeetingURLPattern.zoomGovernment.platform == .zoom)
    #expect(MeetingURLPattern.zoomProtocol.platform == .zoom)
    #expect(MeetingURLPattern.zoomVanity.platform == .zoom)
    #expect(MeetingURLPattern.googleMeet.platform == .googleMeet)
    #expect(MeetingURLPattern.googleMeetLookup.platform == .googleMeet)
  }

  @Test func testPatternsForPlatform() {
    let zoomPatterns = MeetingURLPattern.patterns(for: .zoom)
    let googleMeetPatterns = MeetingURLPattern.patterns(for: .googleMeet)
    let unknownPatterns = MeetingURLPattern.patterns(for: .unknown)

    #expect(zoomPatterns.count == 4, "Should have 4 Zoom patterns")
    #expect(googleMeetPatterns.count == 2, "Should have 2 Google Meet patterns")
    #expect(unknownPatterns.count == 0, "Should have 0 unknown patterns")

    #expect(zoomPatterns.contains(.zoomStandard))
    #expect(zoomPatterns.contains(.zoomGovernment))
    #expect(zoomPatterns.contains(.zoomProtocol))
    #expect(zoomPatterns.contains(.zoomVanity))

    #expect(googleMeetPatterns.contains(.googleMeet))
    #expect(googleMeetPatterns.contains(.googleMeetLookup))
  }

  // MARK: - Complex Text Parsing Tests

  @Test func testMultipleURLsInText() {
    let textWithMultipleURLs = """
      Meeting options:
      1. Standard: https://zoom.us/j/123456789
      2. Government: https://zoomgov.com/j/987654321
      3. Protocol: zoommtg://zoom.us/join?confno=555666777
      4. Vanity: https://company.zoom.us/my/room
      """

    var totalMatches = 0

    for pattern in MeetingURLPattern.allCases {
      let regex = pattern.regex!
      let range = NSRange(location: 0, length: textWithMultipleURLs.utf16.count)
      let matches = regex.matches(in: textWithMultipleURLs, options: [], range: range)
      totalMatches += matches.count
    }

    // Should find at least 4 URLs (may be more due to pattern overlap)
    #expect(totalMatches >= 4, "Should find at least 4 Zoom URLs in complex text")
  }

  @Test func testURLsWithTrackingParameters() {
    let urlsWithTracking = [
      "https://zoom.us/j/123456789?pwd=test&utm_source=email&utm_campaign=reminder",
      "https://company.zoom.us/my/room?uname=user&tracking=abc123",
      "zoommtg://zoom.us/join?confno=123456789&source=calendar",
    ]

    for url in urlsWithTracking {
      var foundMatch = false

      for pattern in MeetingURLPattern.allCases {
        let regex = pattern.regex!
        let range = NSRange(location: 0, length: url.utf16.count)
        let matches = regex.matches(in: url, options: [], range: range)

        if matches.count > 0 {
          foundMatch = true
          break
        }
      }

      #expect(foundMatch, "Should match URL with tracking parameters: \(url)")
    }
  }

  @Test func testEdgeCaseURLs() {
    let edgeCases: [(url: String, shouldMatch: Bool, description: String)] = [
      ("https://zoom.us/", false, "Just domain without path"),
      ("zoommtg://", false, "Just protocol without parameters"),
      ("https://subdomain-with-dashes.zoom.us/j/123", true, "Subdomain with dashes"),
      ("http://zoom.us/j/123?pwd=", true, "Empty password parameter"),
      ("https://zoom.us/j/123456789#section", true, "URL with fragment"),
    ]

    for (url, shouldMatch, description) in edgeCases {
      var foundMatch = false

      for pattern in MeetingURLPattern.allCases {
        let regex = pattern.regex!
        let range = NSRange(location: 0, length: url.utf16.count)
        let matches = regex.matches(in: url, options: [], range: range)

        if matches.count > 0 {
          foundMatch = true
          break
        }
      }

      #expect(
        foundMatch == shouldMatch,
        "Edge case '\(description)': \(url) should \(shouldMatch ? "match" : "not match")")
    }
  }
}
