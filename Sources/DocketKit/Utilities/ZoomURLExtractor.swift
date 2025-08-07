// ABOUTME: Utility class for extracting Zoom meeting URLs from calendar events
// ABOUTME: Searches event fields in priority order and sanitizes URLs by removing tracking parameters

import Foundation

/// Protocol representing a calendar event with searchable fields for Zoom URLs
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

/// Utility class for extracting Zoom meeting URLs from calendar events
public enum ZoomURLExtractor {

  /// Extract Zoom URL from calendar event using priority-based field searching
  /// - Parameter event: Calendar event to search for Zoom URLs
  /// - Returns: Sanitized Zoom URL if found, nil otherwise
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

      if let url = findZoomURL(in: field) {
        return sanitizeURL(url)
      }
    }

    return nil
  }

  // MARK: - Private Implementation

  /// Find first Zoom URL in text using regex patterns
  private static func findZoomURL(in text: String) -> String? {
    // Skip empty or whitespace-only text
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return nil
    }

    // Search using all available Zoom URL patterns
    for pattern in ZoomURLPattern.allCases {
      guard let regex = pattern.regex else {
        continue
      }

      let range = NSRange(location: 0, length: text.utf16.count)
      if let match = regex.firstMatch(in: text, options: [], range: range) {
        let url = String(text[Range(match.range, in: text)!])

        // Additional validation for meaningful URLs
        if isValidZoomURL(url) {
          return url
        }
      }
    }

    return nil
  }

  /// Validate that a Zoom URL contains meaningful content beyond just the domain/path
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
