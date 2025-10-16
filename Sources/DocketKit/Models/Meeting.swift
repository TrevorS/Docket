// ABOUTME: Core meeting data model representing a video meeting from calendar events
// ABOUTME: Provides time-based state calculations and meeting information for UI display

import Foundation

/// Core data model representing a video meeting extracted from calendar events
public struct Meeting: Identifiable, Sendable, Equatable, Hashable {
  public let id: UUID
  public let title: String
  public let startTime: Date
  public let endTime: Date
  public let joinUrl: String?
  public let platform: MeetingPlatform
  public let organizerName: String?
  public let organizerEmail: String?
  public let attendeeCount: Int
  public let attendees: [(name: String?, email: String?)]
  public let calendarName: String
  public let eventIdentifier: String

  public init(
    id: UUID,
    title: String,
    startTime: Date,
    endTime: Date,
    joinUrl: String? = nil,
    platform: MeetingPlatform,
    organizerName: String? = nil,
    organizerEmail: String? = nil,
    attendeeCount: Int,
    attendees: [(name: String?, email: String?)] = [],
    calendarName: String,
    eventIdentifier: String
  ) {
    self.id = id
    self.title = title
    self.startTime = startTime
    self.endTime = endTime
    self.joinUrl = joinUrl
    self.platform = platform
    self.organizerName = organizerName
    self.organizerEmail = organizerEmail
    self.attendeeCount = attendeeCount
    self.attendees = attendees
    self.calendarName = calendarName
    self.eventIdentifier = eventIdentifier
  }

  // MARK: - Computed Properties

  /// Time interval until the meeting starts (negative if already started)
  public var timeUntilStart: TimeInterval {
    startTime.timeIntervalSince(Date())
  }

  /// Duration of the meeting in seconds
  public var duration: TimeInterval {
    endTime.timeIntervalSince(startTime)
  }

  /// Whether the meeting is starting within 5 minutes
  public var isUpcoming: Bool {
    let now = Date()
    let fiveMinutesFromNow = now.addingTimeInterval(300)  // 5 minutes = 300 seconds
    return startTime <= fiveMinutesFromNow && startTime > now
  }

  /// Whether the meeting has already started
  public var hasStarted: Bool {
    Date() >= startTime
  }

  /// Whether the meeting has ended
  public var hasEnded: Bool {
    Date() >= endTime
  }

  /// Minutes elapsed since the meeting ended (returns 0 if meeting hasn't ended)
  public var minutesSinceEnd: Double {
    guard hasEnded else { return 0 }
    return Date().timeIntervalSince(endTime) / 60.0
  }

  /// Whether this meeting should be hidden based on completion status
  /// - Parameter hideCompletedAfter5Min: If true, meetings are hidden 5 minutes after completion
  /// - Returns: True if the meeting should be hidden from the list
  public func shouldBeHidden(hideCompletedAfter5Min: Bool) -> Bool {
    return hideCompletedAfter5Min && hasEnded && minutesSinceEnd >= 5.0
  }
}

// MARK: - Equatable & Hashable Conformance

extension Meeting {
  public static func == (lhs: Meeting, rhs: Meeting) -> Bool {
    // Use all properties for equality comparison
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.startTime == rhs.startTime
      && lhs.endTime == rhs.endTime && lhs.joinUrl == rhs.joinUrl && lhs.platform == rhs.platform
      && lhs.organizerName == rhs.organizerName && lhs.organizerEmail == rhs.organizerEmail
      && lhs.attendeeCount == rhs.attendeeCount && lhs.attendees.count == rhs.attendees.count
      && lhs.calendarName == rhs.calendarName && lhs.eventIdentifier == rhs.eventIdentifier
  }

  public func hash(into hasher: inout Hasher) {
    // Hash based on unique identifier and core properties
    hasher.combine(id)
    hasher.combine(eventIdentifier)
    hasher.combine(title)
    hasher.combine(startTime)
    hasher.combine(attendeeCount)
  }
}
