// ABOUTME: Utility class for extracting video meeting URLs from calendar events
// ABOUTME: Searches event fields in priority order and sanitizes URLs by removing tracking parameters

import Foundation

/// Protocol representing a calendar event with searchable fields for video meeting URLs
public protocol CalendarEventLike {
  /// Virtual conference URL (highest priority)
  var virtualConferenceURL: String? { get }
  /// Direct URL field (second priority)
  var url: String? { get }
  /// Location field (third priority)
  var location: String? { get }
  /// Notes/description field (lowest priority)
  var notes: String? { get }
}

/// Utility class for extracting video meeting URLs from calendar events
public enum MeetingURLExtractor {

  /// Extract video meeting URL from calendar event using priority-based field searching
  /// - Parameter event: Calendar event to search for video meeting URLs
  /// - Returns: Sanitized video meeting URL if found, nil otherwise
  public static func extract<T: CalendarEventLike>(from event: T) -> String? {
    // Search fields in priority order
    let searchData = [
      ("virtualConference", event.virtualConferenceURL),
      ("url", event.url),
      ("location", event.location),
      ("notes", event.notes),
    ]

    for (_, fieldValue) in searchData {
      guard let field = fieldValue, !field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        continue
      }

      if let url = findMeetingURL(in: field) {
        return sanitizeURL(url)
      }
    }

    return nil
  }

  /// Extract video meeting URL and platform from calendar event
  /// - Parameter event: Calendar event to search for video meeting URLs
  /// - Returns: Tuple of (URL, platform) if found, nil otherwise
  public static func extractWithPlatform<T: CalendarEventLike>(from event: T) -> (
    url: String, platform: MeetingPlatform
  )? {
    // Search fields in priority order
    let searchData = [
      ("virtualConference", event.virtualConferenceURL),
      ("url", event.url),
      ("location", event.location),
      ("notes", event.notes),
    ]

    for (_, fieldValue) in searchData {
      guard let field = fieldValue, !field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        continue
      }

      if let (url, platform) = findMeetingURLWithPlatform(in: field) {
        return (sanitizeURL(url), platform)
      }
    }

    return nil
  }

  // MARK: - Private Implementation

  /// Find first video meeting URL in text using regex patterns
  private static func findMeetingURL(in text: String) -> String? {
    // Skip empty or whitespace-only text
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return nil
    }

    // Search using all available video meeting URL patterns
    for pattern in MeetingURLPattern.allCases {
      guard let regex = pattern.regex else {
        continue
      }

      let range = NSRange(location: 0, length: text.utf16.count)
      if let match = regex.firstMatch(in: text, options: [], range: range) {
        let url = String(text[Range(match.range, in: text)!])

        // Additional validation for meaningful URLs
        if isValidMeetingURL(url, platform: pattern.platform) {
          return url
        }
      }
    }

    return nil
  }

  /// Find first video meeting URL with platform in text using regex patterns
  private static func findMeetingURLWithPlatform(in text: String) -> (
    url: String, platform: MeetingPlatform
  )? {
    // Skip empty or whitespace-only text
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return nil
    }

    // Search using all available video meeting URL patterns
    for pattern in MeetingURLPattern.allCases {
      guard let regex = pattern.regex else {
        continue
      }

      let range = NSRange(location: 0, length: text.utf16.count)
      if let match = regex.firstMatch(in: text, options: [], range: range) {
        let url = String(text[Range(match.range, in: text)!])

        // Additional validation for meaningful URLs
        if isValidMeetingURL(url, platform: pattern.platform) {
          return (url, pattern.platform)
        }
      }
    }

    return nil
  }

  /// Validate that a video meeting URL contains meaningful content beyond just the domain/path
  private static func isValidMeetingURL(_ url: String, platform: MeetingPlatform) -> Bool {
    switch platform {
    case .zoom:
      return isValidZoomURL(url)
    case .googleMeet:
      return isValidGoogleMeetURL(url)
    case .unknown:
      return true  // Accept unknown platforms to avoid false negatives
    }
  }

  /// Validate Zoom URLs for meaningful content
  private static func isValidZoomURL(_ url: String) -> Bool {
    // Reject URLs that end with just a slash or common incomplete patterns
    let invalidEndings = [
      "/j/", "/meeting/", "/webinar/", "/my/",
      "/j", "/meeting", "/webinar", "/my",
    ]

    for ending in invalidEndings {
      if url.hasSuffix(ending) {
        return false
      }
    }

    return true
  }

  /// Validate Google Meet URLs for meaningful content
  private static func isValidGoogleMeetURL(_ url: String) -> Bool {
    // Google Meet URLs should have a meeting code after the domain
    // Reject URLs that are just the base domain
    let invalidEndings = [
      "meet.google.com", "meet.google.com/",
    ]

    for ending in invalidEndings {
      if url.hasSuffix(ending) {
        return false
      }
    }

    return true
  }

  /// Sanitize URL by removing tracking parameters while preserving essential parameters
  private static func sanitizeURL(_ url: String) -> String {
    guard var components = URLComponents(string: url) else {
      return url  // Return original if URL parsing fails
    }

    // List of tracking parameters to remove
    let trackingParameters = [
      "utm_source",
      "utm_medium",
      "utm_campaign",
      "utm_term",
      "utm_content",
    ]

    // Remove tracking parameters while preserving others
    components.queryItems = components.queryItems?.filter { queryItem in
      !trackingParameters.contains(queryItem.name)
    }

    // Clear queryItems entirely if empty to clean up URL
    if components.queryItems?.isEmpty == true {
      components.queryItems = nil
    }

    return components.string ?? url
  }
}
