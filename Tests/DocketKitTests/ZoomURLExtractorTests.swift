// ABOUTME: Comprehensive tests for ZoomURLExtractor utility class
// ABOUTME: Tests URL extraction from calendar event fields with priority ordering and sanitization

import EventKit
import Testing

@testable import DocketKit

struct ZoomURLExtractorTests {

  // MARK: - Priority Order Tests

  @Test("Extract from virtualConference.url field (highest priority)")
  func testExtractFromVirtualConferenceURL() {
    let virtualConferenceURL = "https://zoom.us/j/123456789"
    let locationURL = "https://zoom.us/j/987654321"
    let notesURL = "https://zoom.us/j/555666777"

    let testEvent = MockCalendarEvent(
      virtualConferenceURL: virtualConferenceURL,
      url: nil,
      location: locationURL,
      notes: notesURL
    )

    let extracted = ZoomURLExtractor.extract(from: testEvent)
    #expect(extracted == virtualConferenceURL, "Should prioritize virtualConference.url")
  }

  @Test("Extract from URL field (second priority)")
  func testExtractFromURLField() {
    let urlField = "https://zoom.us/j/123456789"
    let locationURL = "https://zoom.us/j/987654321"
    let notesURL = "https://zoom.us/j/555666777"

    let testEvent = MockCalendarEvent(
      virtualConferenceURL: nil,
      url: urlField,
      location: locationURL,
      notes: notesURL
    )

    let extracted = ZoomURLExtractor.extract(from: testEvent)
    #expect(extracted == urlField, "Should use URL field when virtualConference not available")
  }

  @Test("Extract from location field (third priority)")
  func testExtractFromLocationField() {
    let location = "Meeting Room A - https://zoom.us/j/123456789"
    let notes = "Please join us: https://zoom.us/j/555666777"

    let testEvent = MockCalendarEvent(
      virtualConferenceURL: nil,
      url: nil,
      location: location,
      notes: notes
    )

    let extracted = ZoomURLExtractor.extract(from: testEvent)
    #expect(extracted == "https://zoom.us/j/123456789", "Should extract from location field")
  }

  @Test("Extract from notes field (lowest priority)")
  func testExtractFromNotesField() {
    let notes = "Important meeting! Join here: https://zoom.us/j/123456789 - Don't be late!"

    let testEvent = MockCalendarEvent(
      virtualConferenceURL: nil,
      url: nil,
      location: nil,
      notes: notes
    )

    let extracted = ZoomURLExtractor.extract(from: testEvent)
    #expect(
      extracted == "https://zoom.us/j/123456789",
      "Should extract from notes field when other fields empty")
  }

  // MARK: - URL Pattern Type Tests

  @Test("Extract standard Zoom URLs")
  func testExtractStandardZoomURLs() {
    let testCases = [
      "https://zoom.us/j/123456789",
      "http://zoom.us/meeting/register/12345",
      "https://us02web.zoom.us/j/123456789",
      "https://company.zoom.us/j/123456789",
    ]

    for url in testCases {
      let event = MockCalendarEvent(notes: "Join: \(url)")
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == url, "Should extract standard Zoom URL: \(url)")
    }
  }

  @Test("Extract government Zoom URLs")
  func testExtractGovernmentZoomURLs() {
    let testCases = [
      "https://zoomgov.com/j/123456789",
      "https://us02web.zoomgov.com/j/987654321",
    ]

    for url in testCases {
      let event = MockCalendarEvent(location: url)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == url, "Should extract government Zoom URL: \(url)")
    }
  }

  @Test("Extract protocol URLs")
  func testExtractProtocolURLs() {
    let testCases = [
      "zoommtg://zoom.us/join?confno=123456789",
      "zoommtg://company.zoom.us/join?confno=987654321",
    ]

    for url in testCases {
      let event = MockCalendarEvent(virtualConferenceURL: url)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == url, "Should extract protocol URL: \(url)")
    }
  }

  @Test("Extract vanity URLs")
  func testExtractVanityURLs() {
    let testCases = [
      "https://company.zoom.us/my/personalroom",
      "https://university.zoom.us/j/123456789",
    ]

    for url in testCases {
      let event = MockCalendarEvent(url: url)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == url, "Should extract vanity URL: \(url)")
    }
  }

  // MARK: - URL Sanitization Tests

  @Test("Sanitize URLs by removing tracking parameters")
  func testURLSanitization() {
    let testCases = [
      (
        input:
          "https://zoom.us/j/123456789?utm_source=calendar&utm_medium=email&utm_campaign=meeting",
        expected: "https://zoom.us/j/123456789"
      ),
      (
        input: "https://zoom.us/j/123456789?pwd=abc123&utm_source=calendar",
        expected: "https://zoom.us/j/123456789?pwd=abc123"
      ),
      (
        input: "https://zoom.us/j/123456789?utm_medium=email&other_param=keep",
        expected: "https://zoom.us/j/123456789?other_param=keep"
      ),
    ]

    for (input, expected) in testCases {
      let event = MockCalendarEvent(notes: input)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == expected, "Should sanitize URL: \(input) -> \(expected)")
    }
  }

  // MARK: - Edge Case Tests

  @Test("Handle multiple URLs in same field")
  func testMultipleURLsInSameField() {
    let notes = "First meeting: https://zoom.us/j/111111111 and backup: https://zoom.us/j/222222222"
    let event = MockCalendarEvent(notes: notes)
    let extracted = ZoomURLExtractor.extract(from: event)
    #expect(extracted == "https://zoom.us/j/111111111", "Should return first valid URL found")
  }

  @Test("Handle no Zoom URLs found")
  func testNoZoomURLsFound() {
    let testCases = [
      MockCalendarEvent(notes: "Teams meeting: https://teams.microsoft.com/l/meetup/join"),
      MockCalendarEvent(location: "Conference Room B"),
      MockCalendarEvent(url: "https://google.com/meet"),
      MockCalendarEvent(),  // All fields nil
    ]

    for event in testCases {
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == nil, "Should return nil when no Zoom URLs found")
    }
  }

  @Test("Handle malformed URLs gracefully")
  func testMalformedURLsHandling() {
    let testCases = [
      "htt://zoom.us/j/broken",  // Missing 'p'
      "zoom.us/j/123456789",  // Missing protocol
      "https://zoom.us/j/",  // Missing meeting ID
      "https://zom.us/j/123456789",  // Wrong domain
    ]

    for malformedURL in testCases {
      let event = MockCalendarEvent(notes: malformedURL)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == nil, "Should handle malformed URL gracefully: \(malformedURL)")
    }
  }

  @Test("Handle empty and whitespace-only fields")
  func testEmptyAndWhitespaceFields() {
    let testCases = [
      MockCalendarEvent(notes: ""),
      MockCalendarEvent(location: "   "),
      MockCalendarEvent(url: "\n\t"),
      MockCalendarEvent(virtualConferenceURL: ""),
    ]

    for event in testCases {
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(extracted == nil, "Should handle empty/whitespace fields")
    }
  }

  // MARK: - Mixed Content Tests

  @Test("Extract from mixed content with other text")
  func testMixedContentExtraction() {
    let complexNote = """
      📅 Weekly Team Meeting

      Agenda:
      - Project updates
      - Sprint planning

      📞 Join via Zoom: https://zoom.us/j/123456789?pwd=secret123

      🔗 Alternative link: https://teams.microsoft.com/backup

      See you there!
      """

    let event = MockCalendarEvent(notes: complexNote)
    let extracted = ZoomURLExtractor.extract(from: event)
    #expect(
      extracted == "https://zoom.us/j/123456789?pwd=secret123",
      "Should extract URL from complex mixed content")
  }

  // MARK: - Integration with ZoomURLPattern Tests

  @Test("Verify integration with all ZoomURLPattern cases")
  func testIntegrationWithZoomURLPattern() {
    // This test ensures ZoomURLExtractor uses the same patterns as ZoomURLPattern
    let testURLs = [
      "https://zoom.us/j/standard",
      "https://zoomgov.com/j/government",
      "zoommtg://protocol.test",
      "https://vanity.zoom.us/j/test",
    ]

    for url in testURLs {
      // First verify the pattern matches our ZoomURLPattern enum
      let hasMatchingPattern = ZoomURLPattern.allCases.contains { pattern in
        if let regex = pattern.regex {
          let range = NSRange(location: 0, length: url.utf16.count)
          return regex.firstMatch(in: url, options: [], range: range) != nil
        }
        return false
      }
      #expect(hasMatchingPattern, "URL should match at least one ZoomURLPattern: \(url)")

      // Then test extraction
      let event = MockCalendarEvent(notes: url)
      let extracted = ZoomURLExtractor.extract(from: event)
      #expect(
        extracted == url, "ZoomURLExtractor should extract URL that matches ZoomURLPattern: \(url)")
    }
  }
}

// MARK: - Mock Calendar Event

/// Mock implementation of calendar event for testing
private struct MockCalendarEvent: CalendarEventLike {
  let virtualConferenceURL: String?
  let url: String?
  let location: String?
  let notes: String?

  init(
    virtualConferenceURL: String? = nil,
    url: String? = nil,
    location: String? = nil,
    notes: String? = nil
  ) {
    self.virtualConferenceURL = virtualConferenceURL
    self.url = url
    self.location = location
    self.notes = notes
  }
}
