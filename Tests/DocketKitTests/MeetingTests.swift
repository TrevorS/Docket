// ABOUTME: Comprehensive tests for Meeting model using Swift Testing framework
// ABOUTME: Tests time calculations, state properties, and Sendable/Equatable conformance

import Foundation
import Testing

@testable import DocketKit

struct MeetingTests {

  // MARK: - Test Data Helpers

  private func createMeeting(
    id: UUID = UUID(),
    title: String = "Test Meeting",
    startTime: Date,
    endTime: Date,
    joinUrl: String? = "https://zoom.us/j/123456789",
    organizerName: String? = "John Doe",
    organizerEmail: String? = "john@example.com",
    attendeeCount: Int = 5,
    calendarName: String = "Work",
    eventIdentifier: String = "test-event-123"
  ) -> Meeting {
    Meeting(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      joinUrl: joinUrl,
      platform: .zoom,
      organizerName: organizerName,
      organizerEmail: organizerEmail,
      attendeeCount: attendeeCount,
      calendarName: calendarName,
      eventIdentifier: eventIdentifier
    )
  }

  // MARK: - Basic Properties Tests

  @Test func testMeetingCreation() {
    let id = UUID()
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour later

    let meeting = createMeeting(
      id: id,
      title: "Daily Standup",
      startTime: startTime,
      endTime: endTime,
      joinUrl: "https://zoom.us/j/987654321",
      organizerName: "Jane Smith",
      organizerEmail: "jane@example.com",
      attendeeCount: 8,
      calendarName: "Team Calendar",
      eventIdentifier: "daily-standup-456"
    )

    #expect(meeting.id == id)
    #expect(meeting.title == "Daily Standup")
    #expect(meeting.startTime == startTime)
    #expect(meeting.endTime == endTime)
    #expect(meeting.joinUrl == "https://zoom.us/j/987654321")
    #expect(meeting.organizerName == "Jane Smith")
    #expect(meeting.organizerEmail == "jane@example.com")
    #expect(meeting.attendeeCount == 8)
    #expect(meeting.calendarName == "Team Calendar")
    #expect(meeting.eventIdentifier == "daily-standup-456")
  }

  @Test func testMeetingWithoutZoomURL() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(1800)  // 30 minutes

    let meeting = createMeeting(
      title: "In-person Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: nil,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0
    )

    #expect(meeting.joinUrl == nil)
    #expect(meeting.organizerName == nil)
    #expect(meeting.organizerEmail == nil)
    #expect(meeting.attendeeCount == 0)
  }

  // MARK: - Time Calculation Tests

  @Test func testDurationCalculation() {
    let startTime = Date()
    let thirtyMinutes: TimeInterval = 30 * 60
    let endTime = startTime.addingTimeInterval(thirtyMinutes)

    let meeting = createMeeting(startTime: startTime, endTime: endTime)

    #expect(meeting.duration == thirtyMinutes)
  }

  @Test func testTimeUntilStart() {
    let now = Date()
    let futureStart = now.addingTimeInterval(600)  // 10 minutes from now
    let endTime = futureStart.addingTimeInterval(1800)  // 30 minutes long

    let meeting = createMeeting(startTime: futureStart, endTime: endTime)

    // Allow some tolerance for test execution time
    let timeUntil = meeting.timeUntilStart
    #expect(timeUntil > 590)  // At least 9 minutes 50 seconds
    #expect(timeUntil < 610)  // Less than 10 minutes 10 seconds
  }

  @Test func testTimeUntilStartForPastMeeting() {
    let now = Date()
    let pastStart = now.addingTimeInterval(-600)  // 10 minutes ago
    let pastEnd = now.addingTimeInterval(-300)  // 5 minutes ago

    let meeting = createMeeting(startTime: pastStart, endTime: pastEnd)

    #expect(meeting.timeUntilStart < 0)
  }

  // MARK: - Meeting State Tests

  @Test func testFutureMeetingStates() {
    let now = Date()
    let futureStart = now.addingTimeInterval(600)  // 10 minutes from now
    let futureEnd = futureStart.addingTimeInterval(1800)  // 30 minutes long

    let meeting = createMeeting(startTime: futureStart, endTime: futureEnd)

    #expect(!meeting.isUpcoming)  // Not within 5-minute window
    #expect(!meeting.hasStarted)
    #expect(!meeting.hasEnded)
  }

  @Test func testUpcomingMeetingStates() {
    let now = Date()
    let soonStart = now.addingTimeInterval(240)  // 4 minutes from now
    let soonEnd = soonStart.addingTimeInterval(1800)  // 30 minutes long

    let meeting = createMeeting(startTime: soonStart, endTime: soonEnd)

    #expect(meeting.isUpcoming)  // Within 5-minute window
    #expect(!meeting.hasStarted)
    #expect(!meeting.hasEnded)
  }

  @Test func testUpcomingMeetingBoundary() {
    let now = Date()
    let exactlyFiveMinutes = now.addingTimeInterval(300)  // Exactly 5 minutes
    let endTime = exactlyFiveMinutes.addingTimeInterval(1800)

    let meeting = createMeeting(startTime: exactlyFiveMinutes, endTime: endTime)

    #expect(meeting.isUpcoming)  // Should be true at exactly 5 minutes
  }

  @Test func testInProgressMeetingStates() {
    let now = Date()
    let pastStart = now.addingTimeInterval(-600)  // Started 10 minutes ago
    let futureEnd = now.addingTimeInterval(1200)  // Ends in 20 minutes

    let meeting = createMeeting(startTime: pastStart, endTime: futureEnd)

    #expect(!meeting.isUpcoming)  // Not upcoming (already started)
    #expect(meeting.hasStarted)
    #expect(!meeting.hasEnded)
  }

  @Test func testEndedMeetingStates() {
    let now = Date()
    let pastStart = now.addingTimeInterval(-3600)  // Started 1 hour ago
    let pastEnd = now.addingTimeInterval(-1800)  // Ended 30 minutes ago

    let meeting = createMeeting(startTime: pastStart, endTime: pastEnd)

    #expect(!meeting.isUpcoming)
    #expect(meeting.hasStarted)  // It did start (in the past)
    #expect(meeting.hasEnded)
  }

  @Test func testMeetingJustStarted() {
    let now = Date()
    let justStarted = now.addingTimeInterval(-30)  // Started 30 seconds ago
    let futureEnd = now.addingTimeInterval(1770)  // Ends in ~29.5 minutes

    let meeting = createMeeting(startTime: justStarted, endTime: futureEnd)

    #expect(!meeting.isUpcoming)  // No longer upcoming
    #expect(meeting.hasStarted)
    #expect(!meeting.hasEnded)
  }

  @Test func testMeetingJustEnded() {
    let now = Date()
    let pastStart = now.addingTimeInterval(-1800)  // Started 30 minutes ago
    let justEnded = now.addingTimeInterval(-30)  // Ended 30 seconds ago

    let meeting = createMeeting(startTime: pastStart, endTime: justEnded)

    #expect(!meeting.isUpcoming)
    #expect(meeting.hasStarted)
    #expect(meeting.hasEnded)
  }

  // MARK: - Edge Cases

  @Test func testZeroDurationMeeting() {
    let startTime = Date()
    let endTime = startTime  // Same time = zero duration

    let meeting = createMeeting(startTime: startTime, endTime: endTime)

    #expect(meeting.duration == 0)
  }

  @Test func testNegativeDurationMeeting() {
    // This shouldn't happen in real scenarios, but test for robustness
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(-600)  // End before start

    let meeting = createMeeting(startTime: startTime, endTime: endTime)

    #expect(meeting.duration == -600)
  }

  // MARK: - Equatable Tests

  @Test func testMeetingEquality() {
    let id = UUID()
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(1800)

    let meeting1 = createMeeting(
      id: id,
      title: "Test Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: "https://zoom.us/j/123456789",
      organizerName: "John Doe"
    )

    let meeting2 = createMeeting(
      id: id,  // Same ID
      title: "Test Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: "https://zoom.us/j/123456789",
      organizerName: "John Doe"
    )

    #expect(meeting1 == meeting2)
  }

  @Test func testMeetingInequality() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(1800)

    let meeting1 = createMeeting(
      id: UUID(),
      title: "First Meeting",
      startTime: startTime,
      endTime: endTime
    )

    let meeting2 = createMeeting(
      id: UUID(),  // Different ID
      title: "Second Meeting",
      startTime: startTime,
      endTime: endTime
    )

    #expect(meeting1 != meeting2)
  }

  // MARK: - Sendable Conformance Tests

  @Test func testSendableConformance() {
    let meeting = createMeeting(
      startTime: Date(),
      endTime: Date().addingTimeInterval(1800)
    )

    // Test that we can send the meeting to another actor/task
    Task {
      let _ = meeting  // Should compile without warnings
    }

    // If this compiles, Sendable conformance is working
    #expect(Bool(true))
  }
}
