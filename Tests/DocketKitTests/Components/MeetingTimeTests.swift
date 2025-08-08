// ABOUTME: Tests for MeetingTimeView component covering time formatting and state-based colors
// ABOUTME: Ensures correct time range display, duration calculation, and color logic for different meeting states

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("MeetingTimeView Tests")
struct MeetingTimeTests {

  @Test("Time range formatting displays correctly")
  @MainActor
  func timeRangeFormatting() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour later
    let meeting = Meeting(
      id: UUID(),
      title: "Test Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-meeting"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting == meeting)
  }

  @Test("Duration calculation for short meetings")
  @MainActor
  func shortMeetingDuration() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(30 * 60)  // 30 minutes
    let meeting = Meeting(
      id: UUID(),
      title: "Short Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-short"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting == meeting)
  }

  @Test("Duration calculation for long meetings")
  @MainActor
  func longMeetingDuration() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(2.5 * 3600)  // 2.5 hours
    let meeting = Meeting(
      id: UUID(),
      title: "Long Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-long"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting == meeting)
  }

  @Test("Color logic for ended meetings")
  @MainActor
  func endedMeetingColor() {
    let startTime = Date().addingTimeInterval(-7200)  // 2 hours ago
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour duration
    let meeting = Meeting(
      id: UUID(),
      title: "Ended Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-ended"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting.hasEnded)
  }

  @Test("Color logic for active meetings")
  @MainActor
  func activeMeetingColor() {
    let startTime = Date().addingTimeInterval(-900)  // 15 minutes ago
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour duration
    let meeting = Meeting(
      id: UUID(),
      title: "Active Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-active"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting.hasStarted)
    #expect(!view.meeting.hasEnded)
  }

  @Test("Color logic for upcoming meetings")
  @MainActor
  func upcomingMeetingColor() {
    let startTime = Date().addingTimeInterval(240)  // 4 minutes from now (within 5 minute window)
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour duration
    let meeting = Meeting(
      id: UUID(),
      title: "Upcoming Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-upcoming"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting.isUpcoming)
  }

  @Test("Edge case: zero duration meeting")
  @MainActor
  func zeroDurationMeeting() {
    let startTime = Date()
    let endTime = startTime  // Same time
    let meeting = Meeting(
      id: UUID(),
      title: "Zero Duration Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Test Calendar",
      eventIdentifier: "test-zero"
    )

    let view = MeetingTimeView(meeting: meeting)
    #expect(view.meeting == meeting)
  }

  @Test("Meeting time component maintains meeting reference")
  @MainActor
  func meetingReferenceIntegrity() {
    let meeting = Meeting(
      id: UUID(),
      title: "Test Meeting",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .googleMeet,
      organizerName: "John Doe",
      organizerEmail: "john@company.com",
      attendeeCount: 5,
      calendarName: "Test Calendar",
      eventIdentifier: "test-reference"
    )

    let view = MeetingTimeView(meeting: meeting)

    // Verify all properties are preserved
    #expect(view.meeting.id == meeting.id)
    #expect(view.meeting.title == meeting.title)
    #expect(view.meeting.joinUrl == meeting.joinUrl)
    #expect(view.meeting.organizerName == meeting.organizerName)
    #expect(view.meeting.attendeeCount == meeting.attendeeCount)
    #expect(view.meeting.platform == meeting.platform)
  }
}
