// ABOUTME: Enum representing different video meeting platforms supported by Docket
// ABOUTME: Provides platform identification, display names, and URL pattern matching for meetings

import Foundation

/// Represents the different video meeting platforms supported by the app
public enum MeetingPlatform: String, CaseIterable, Sendable, Hashable {
  /// Zoom meetings (zoom.us, zoomgov.com, zoommtg://)
  case zoom = "zoom"

  /// Google Meet meetings (meet.google.com)
  case googleMeet = "googleMeet"

  /// Unknown or unsupported platform
  case unknown = "unknown"

  // MARK: - Display Properties

  /// Human-readable name for the platform
  public var displayName: String {
    switch self {
    case .zoom:
      return "Zoom"
    case .googleMeet:
      return "Google Meet"
    case .unknown:
      return "Unknown"
    }
  }

  /// Short identifier for the platform (useful for UI)
  public var shortName: String {
    switch self {
    case .zoom:
      return "Zoom"
    case .googleMeet:
      return "Meet"
    case .unknown:
      return "Unknown"
    }
  }

  /// SF Symbol icon name for the platform
  public var iconName: String {
    switch self {
    case .zoom:
      return "video.fill"
    case .googleMeet:
      return "person.2.fill"
    case .unknown:
      return "questionmark.circle.fill"
    }
  }

  /// Color associated with the platform
  public var color: String {
    switch self {
    case .zoom:
      return "blue"
    case .googleMeet:
      return "green"
    case .unknown:
      return "gray"
    }
  }

  // MARK: - Platform Detection

  /// Detect the meeting platform from a URL
  /// - Parameter url: Meeting URL to analyze
  /// - Returns: Detected platform or .unknown if not recognized
  public static func detectPlatform(from url: String) -> MeetingPlatform {
    let lowercaseURL = url.lowercased()

    // Check for Zoom patterns
    if lowercaseURL.contains("zoom.us") || lowercaseURL.contains("zoomgov.com")
      || lowercaseURL.hasPrefix("zoommtg://")
    {
      return .zoom
    }

    // Check for Google Meet patterns
    if lowercaseURL.contains("meet.google.com") {
      return .googleMeet
    }

    return .unknown
  }

  // MARK: - URL Validation

  /// Check if a URL belongs to this platform
  /// - Parameter url: URL to validate
  /// - Returns: True if the URL matches this platform
  public func matches(url: String) -> Bool {
    return Self.detectPlatform(from: url) == self
  }
}
