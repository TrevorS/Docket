// ABOUTME: Core meeting data model representing a Zoom meeting from calendar events
// ABOUTME: Provides time-based state calculations and meeting information for UI display

import Foundation

/// Core data model representing a Zoom meeting extracted from calendar events
public struct ZoomMeeting: Identifiable, Sendable, Equatable {
  public let id: UUID
  public let title: String
  public let startTime: Date
  public let endTime: Date
  public let joinUrl: String?
  public let organizerName: String?
  public let organizerEmail: String?
  public let attendeeCount: Int
  public let calendarName: String
  public let eventIdentifier: String

  public init(
    id: UUID,
    title: String,
    startTime: Date,
    endTime: Date,
    joinUrl: String? = nil,
    organizerName: String? = nil,
    organizerEmail: String? = nil,
    attendeeCount: Int,
    calendarName: String,
    eventIdentifier: String
  ) {
    self.id = id
    self.title = title
    self.startTime = startTime
    self.endTime = endTime
    self.joinUrl = joinUrl
    self.organizerName = organizerName
    self.organizerEmail = organizerEmail
    self.attendeeCount = attendeeCount
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
}

// MARK: - Equatable Conformance

extension ZoomMeeting {
  public static func == (lhs: ZoomMeeting, rhs: ZoomMeeting) -> Bool {
    // Use all properties for equality comparison
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.startTime == rhs.startTime
      && lhs.endTime == rhs.endTime && lhs.joinUrl == rhs.joinUrl
      && lhs.organizerName == rhs.organizerName && lhs.organizerEmail == rhs.organizerEmail
      && lhs.attendeeCount == rhs.attendeeCount && lhs.calendarName == rhs.calendarName
      && lhs.eventIdentifier == rhs.eventIdentifier
  }
}
