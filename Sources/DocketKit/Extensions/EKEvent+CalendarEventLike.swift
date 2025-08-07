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
    print("🔌 EKEventAdapter: Getting virtualConferenceURL for '\(event.title ?? "Untitled")'")

    // Check for structured location URL first
    if let structuredLocation = event.structuredLocation {
      print("🔌   Structured location found: '\(structuredLocation.title ?? "No title")'")
      if let url = structuredLocation.geoLocation?.description {
        print("🔌   Structured location has geo URL: '\(url)'")
        return url
      }
      print("🔌   Structured location has no geo URL")
    } else {
      print("🔌   No structured location found")
    }

    // Fall back to direct URL property
    let directURL = event.url?.absoluteString
    print("🔌   Direct URL property: '\(directURL ?? "nil")'")
    return directURL
  }

  /// Direct URL field mapping (second priority)
  public var url: String? {
    let urlString = event.url?.absoluteString
    print(
      "🔌 EKEventAdapter: Direct URL for '\(event.title ?? "Untitled")': '\(urlString ?? "nil")'")
    return urlString
  }

  /// Location field mapping (third priority)
  /// Combines both location string and structured location title
  public var location: String? {
    print("🔌 EKEventAdapter: Getting location for '\(event.title ?? "Untitled")'")

    // Prefer structured location title if available
    if let structuredTitle = event.structuredLocation?.title {
      print("🔌   Using structured location title: '\(structuredTitle)'")
      return structuredTitle
    }

    // Fall back to basic location string
    let basicLocation = event.location
    print("🔌   Using basic location: '\(basicLocation ?? "nil")'")
    return basicLocation
  }

  /// Notes/description field mapping (lowest priority)
  public var notes: String? {
    let notesText = event.notes
    let displayNotes =
      notesText?.prefix(100).appending(notesText!.count > 100 ? "..." : "") ?? "nil"
    print("🔌 EKEventAdapter: Notes for '\(event.title ?? "Untitled")': '\(displayNotes)'")
    return notesText
  }
}
