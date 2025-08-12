// ABOUTME: Enum representing different video meeting platforms supported by Docket
// ABOUTME: Provides platform identification, display names, and URL pattern matching for meetings

import Foundation
import SwiftUI

/// Configuration data for a meeting platform
public struct PlatformConfig: Sendable {
  let displayName: String
  let shortName: String
  let iconName: String
  let color: Color
  let urlPatterns: [String]

  public init(
    displayName: String, shortName: String, iconName: String, color: Color, urlPatterns: [String]
  ) {
    self.displayName = displayName
    self.shortName = shortName
    self.iconName = iconName
    self.color = color
    self.urlPatterns = urlPatterns
  }
}

/// Represents the different video meeting platforms supported by the app
public enum MeetingPlatform: String, CaseIterable, Sendable, Hashable {
  /// Zoom meetings (zoom.us, zoomgov.com, zoommtg://)
  case zoom = "zoom"

  /// Google Meet meetings (meet.google.com)
  case googleMeet = "googleMeet"

  /// Unknown or unsupported platform
  case unknown = "unknown"

  // MARK: - Platform Configurations

  /// Centralized platform configuration data
  private static let configs: [MeetingPlatform: PlatformConfig] = [
    .zoom: PlatformConfig(
      displayName: "Zoom",
      shortName: "Zoom",
      iconName: "video.fill",
      color: .blue,
      urlPatterns: [
        "https?://[\\w.-]*zoom\\.us/[^\\s]+",
        "https?://[\\w.-]*zoomgov\\.com/[^\\s]+",
        "zoommtg://[^\\s]+",
        "https?://[\\w.-]*\\.zoom\\.us/[^\\s]+",
      ]
    ),
    .googleMeet: PlatformConfig(
      displayName: "Google Meet",
      shortName: "Meet",
      iconName: "person.2.fill",
      color: .green,
      urlPatterns: [
        "https?://meet\\.google\\.com/[^\\s]+",
        "https?://meet\\.google\\.com/lookup/[^\\s]+",
      ]
    ),
    .unknown: PlatformConfig(
      displayName: "Unknown",
      shortName: "Unknown",
      iconName: "questionmark.circle.fill",
      color: .gray,
      urlPatterns: []
    ),
  ]

  /// Configuration for this platform
  public var config: PlatformConfig {
    return Self.configs[self] ?? Self.configs[.unknown]!
  }

  // MARK: - Display Properties

  /// Human-readable name for the platform
  public var displayName: String {
    return config.displayName
  }

  /// Short identifier for the platform (useful for UI)
  public var shortName: String {
    return config.shortName
  }

  /// SF Symbol icon name for the platform
  public var iconName: String {
    return config.iconName
  }

  /// SwiftUI Color associated with the platform
  public var color: Color {
    return config.color
  }

  // MARK: - Platform Detection

  /// Detect the meeting platform from a URL
  /// - Parameter url: Meeting URL to analyze
  /// - Returns: Detected platform or .unknown if not recognized
  public static func detectPlatform(from url: String) -> MeetingPlatform {
    for platform in allCases where platform != .unknown {
      if platform.matches(url: url) {
        return platform
      }
    }
    return .unknown
  }

  // MARK: - URL Validation

  /// Check if a URL belongs to this platform
  /// - Parameter url: URL to validate
  /// - Returns: True if the URL matches this platform
  public func matches(url: String) -> Bool {
    // Special case: unknown platform matches URLs that don't match any known platform
    if self == .unknown {
      for platform in MeetingPlatform.allCases where platform != .unknown {
        if platform.matches(url: url) {
          return false  // URL matches a known platform, so it's not unknown
        }
      }
      return true  // URL doesn't match any known platform, so it's unknown
    }

    // For known platforms, check URL patterns with case-insensitive matching
    for pattern in config.urlPatterns {
      if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
        let range = NSRange(location: 0, length: url.utf16.count)
        if regex.firstMatch(in: url, options: [], range: range) != nil {
          return true
        }
      }
    }
    return false
  }

  /// Get all URL patterns for this platform
  /// - Returns: Array of regex patterns for this platform
  public var urlPatterns: [String] {
    return config.urlPatterns
  }
}
