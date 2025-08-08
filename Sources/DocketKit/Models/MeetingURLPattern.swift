// ABOUTME: URL pattern matching for different types of video meeting URLs
// ABOUTME: Provides regex patterns for Zoom, Google Meet, and other video meeting platforms

import Foundation

/// Enum representing different types of video meeting URL patterns with corresponding regex patterns
public enum MeetingURLPattern: String, CaseIterable, Sendable {
  // MARK: - Zoom URL Patterns

  /// Standard Zoom URLs (zoom.us domain)
  case zoomStandard = "https?://[\\w.-]*zoom\\.us/[^\\s]+"

  /// Government Zoom URLs (zoomgov.com domain)
  case zoomGovernment = "https?://[\\w.-]*zoomgov\\.com/[^\\s]+"

  /// Zoom protocol URLs (zoommtg:// scheme)
  case zoomProtocol = "zoommtg://[^\\s]+"

  /// Vanity Zoom URLs (*.zoom.us subdomains)
  case zoomVanity = "https?://[\\w.-]*\\.zoom\\.us/[^\\s]+"

  // MARK: - Google Meet URL Patterns

  /// Standard Google Meet URLs (meet.google.com)
  case googleMeet = "https?://meet\\.google\\.com/[^\\s]+"

  /// Google Meet lookup URLs (meet.google.com/lookup/...)
  case googleMeetLookup = "https?://meet\\.google\\.com/lookup/[^\\s]+"

  /// Compiled regex pattern for this URL type
  public var regex: NSRegularExpression? {
    try? NSRegularExpression(pattern: rawValue, options: [])
  }

  /// The meeting platform this pattern belongs to
  public var platform: MeetingPlatform {
    switch self {
    case .zoomStandard, .zoomGovernment, .zoomProtocol, .zoomVanity:
      return .zoom
    case .googleMeet, .googleMeetLookup:
      return .googleMeet
    }
  }

  /// Display name for this pattern type
  public var displayName: String {
    switch self {
    case .zoomStandard:
      return "Zoom Standard"
    case .zoomGovernment:
      return "Zoom Government"
    case .zoomProtocol:
      return "Zoom Protocol"
    case .zoomVanity:
      return "Zoom Vanity"
    case .googleMeet:
      return "Google Meet"
    case .googleMeetLookup:
      return "Google Meet Lookup"
    }
  }

  /// Get all patterns for a specific platform
  /// - Parameter platform: The meeting platform
  /// - Returns: Array of patterns for that platform
  public static func patterns(for platform: MeetingPlatform) -> [MeetingURLPattern] {
    return allCases.filter { $0.platform == platform }
  }
}
