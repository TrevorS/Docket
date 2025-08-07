// ABOUTME: Adapter making EKEvent compatible with CalendarEventLike protocol for ZoomURLExtractor
// ABOUTME: Wraps EventKit events to provide the protocol requirements for URL extraction

import EventKit
import Foundation

/// Adapter that wraps EKEvent to make it compatible with ZoomURLExtractor
public struct EKEventAdapter: CalendarEventLike {
  private let event: EKEvent

  public init(event: EKEvent) {
    self.event = event
  }

  /// Virtual conference URL from EventKit (highest priority for URL extraction)
  /// Maps to structured location or URL field in EventKit
  public var virtualConferenceURL: String? {
    // Check for structured location URL first
    if let structuredLocation = event.structuredLocation,
      let url = structuredLocation.geoLocation?.description
    {
      return url
    }

    // Fall back to direct URL property
    return event.url?.absoluteString
  }

  /// Direct URL field mapping (second priority)
  public var url: String? {
    return event.url?.absoluteString
  }

  /// Location field mapping (third priority)
  /// Combines both location string and structured location title
  public var location: String? {
    // Prefer structured location title if available
    if let structuredTitle = event.structuredLocation?.title {
      return structuredTitle
    }

    // Fall back to basic location string
    return event.location
  }

  /// Notes/description field mapping (lowest priority)
  public var notes: String? {
    return event.notes
  }
}
