// ABOUTME: Tests for MeetingRowView component covering meeting display, action buttons, and URL handling
// ABOUTME: Ensures correct state-based rendering, button visibility logic, and action callback behavior

import SwiftUI
import Testing

@testable import DocketKit

struct MeetingRowViewTests {

  // MARK: - Basic Creation Tests

  @Test("MeetingRowView can be created with valid meeting")
  @MainActor
  func creationWithValidMeeting() {
    let view = MeetingRowView(meeting: PreviewData.upcomingMeeting)

    #expect(view.meeting.id == PreviewData.upcomingMeeting.id)
    #expect(view.meeting.title == PreviewData.upcomingMeeting.title)
  }

  @Test("MeetingRowView maintains meeting reference integrity")
  @MainActor
  func meetingReferenceIntegrity() {
    let originalMeeting = PreviewData.activeMeeting
    let view = MeetingRowView(meeting: originalMeeting)

    #expect(view.meeting.title == originalMeeting.title)
    #expect(view.meeting.startTime == originalMeeting.startTime)
    #expect(view.meeting.endTime == originalMeeting.endTime)
    #expect(view.meeting.platform == originalMeeting.platform)
  }

  // MARK: - URL Detection Tests

  @Test("hasJoinUrl returns true for valid URLs")
  @MainActor
  func hasJoinUrlWithValidUrl() {
    let view = MeetingRowView(meeting: PreviewData.upcomingMeeting)

    // PreviewData.upcomingMeeting has a valid Zoom URL
    #expect(view.hasJoinUrl == true)
  }

  @Test("hasJoinUrl returns false for nil URLs")
  @MainActor
  func hasJoinUrlWithNilUrl() {
    let view = MeetingRowView(meeting: PreviewData.meetingWithoutUrl)

    // PreviewData.meetingWithoutUrl has nil joinUrl
    #expect(view.hasJoinUrl == false)
  }

  @Test("hasJoinUrl returns false for empty string URLs")
  @MainActor
  func hasJoinUrlWithEmptyUrl() {
    let meetingWithEmptyUrl = Meeting(
      id: UUID(),
      title: "Empty URL Meeting",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      joinUrl: "",
      platform: .zoom,
      organizerName: "Test",
      organizerEmail: nil,
      attendeeCount: 1,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-empty"
    )

    let view = MeetingRowView(meeting: meetingWithEmptyUrl)

    #expect(view.hasJoinUrl == false)
  }

  @Test("hasJoinUrl returns false for whitespace-only URLs")
  @MainActor
  func hasJoinUrlWithWhitespaceUrl() {
    let meetingWithWhitespaceUrl = Meeting(
      id: UUID(),
      title: "Whitespace URL Meeting",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      joinUrl: "   \t\n   ",
      platform: .zoom,
      organizerName: "Test",
      organizerEmail: nil,
      attendeeCount: 1,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-whitespace"
    )

    let view = MeetingRowView(meeting: meetingWithWhitespaceUrl)

    #expect(view.hasJoinUrl == false)
  }

  // MARK: - Join Button Visibility Tests

  @Test("shouldShowJoinButton returns true for upcoming meetings with URLs")
  @MainActor
  func shouldShowJoinButtonUpcomingWithUrl() {
    let view = MeetingRowView(meeting: PreviewData.upcomingMeeting)

    // Upcoming meeting with URL should show join button
    #expect(view.shouldShowJoinButton == true)
  }

  @Test("shouldShowJoinButton returns true for active meetings with URLs")
  @MainActor
  func shouldShowJoinButtonActiveWithUrl() {
    let view = MeetingRowView(meeting: PreviewData.activeMeeting)

    // Active meeting with URL should show join button
    #expect(view.shouldShowJoinButton == true)
  }

  @Test("shouldShowJoinButton returns false for ended meetings")
  @MainActor
  func shouldShowJoinButtonEndedMeeting() {
    let view = MeetingRowView(meeting: PreviewData.endedMeeting)

    // Ended meetings should not show join button regardless of URL
    #expect(view.shouldShowJoinButton == false)
  }

  @Test("shouldShowJoinButton returns false for meetings without URLs")
  @MainActor
  func shouldShowJoinButtonNoUrl() {
    let view = MeetingRowView(meeting: PreviewData.meetingWithoutUrl)

    // Meetings without URLs should not show join button
    #expect(view.shouldShowJoinButton == false)
  }

  @Test("shouldShowJoinButton handles edge case of just-ended meeting")
  @MainActor
  func shouldShowJoinButtonJustEnded() {
    // Create a meeting that just ended (1 minute ago)
    let justEndedMeeting = Meeting(
      id: UUID(),
      title: "Just Ended Meeting",
      startTime: Date().addingTimeInterval(-3660),  // Started 61 minutes ago
      endTime: Date().addingTimeInterval(-60),  // Ended 1 minute ago
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: "Test",
      organizerEmail: nil,
      attendeeCount: 1,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-just-ended"
    )

    let view = MeetingRowView(meeting: justEndedMeeting)

    #expect(view.shouldShowJoinButton == false)
  }

  // MARK: - Component State Tests

  @Test("Component handles different meeting states correctly")
  @MainActor
  func componentMeetingStates() {
    let upcomingView = MeetingRowView(meeting: PreviewData.upcomingMeeting)
    let activeView = MeetingRowView(meeting: PreviewData.activeMeeting)
    let endedView = MeetingRowView(meeting: PreviewData.endedMeeting)

    // Test that each view correctly reflects its meeting state
    #expect(!upcomingView.meeting.hasEnded)
    #expect(!activeView.meeting.hasEnded)
    #expect(endedView.meeting.hasEnded)

    // Test URL availability
    #expect(upcomingView.hasJoinUrl == true)
    #expect(activeView.hasJoinUrl == true)
    // endedView may or may not have URL - depends on PreviewData

    // Test join button visibility
    #expect(upcomingView.shouldShowJoinButton == true)
    #expect(activeView.shouldShowJoinButton == true)
    #expect(endedView.shouldShowJoinButton == false)
  }

  @Test("Component handles different platforms correctly")
  @MainActor
  func componentPlatformHandling() {
    let zoomMeeting = PreviewData.upcomingMeeting  // Zoom meeting
    let googleMeetMeeting = PreviewData.googleMeetMeeting  // Google Meet meeting

    let zoomView = MeetingRowView(meeting: zoomMeeting)
    let googleView = MeetingRowView(meeting: googleMeetMeeting)

    #expect(zoomView.meeting.platform == .zoom)
    #expect(googleView.meeting.platform == .googleMeet)

    // Both should have URLs and show join buttons (assuming they're not ended)
    #expect(zoomView.hasJoinUrl == true)
    #expect(googleView.hasJoinUrl == true)
  }

  // MARK: - Action Handler Tests

  // Note: handleCopyAction is a private implementation detail handled by MeetingCopyButton component

  // MARK: - Integration Tests

  @Test("Component maintains consistency across multiple creations")
  @MainActor
  func componentConsistencyMultipleCreations() {
    let meeting = PreviewData.upcomingMeeting
    let view1 = MeetingRowView(meeting: meeting)
    let view2 = MeetingRowView(meeting: meeting)

    // Both views should have consistent behavior
    #expect(view1.hasJoinUrl == view2.hasJoinUrl)
    #expect(view1.shouldShowJoinButton == view2.shouldShowJoinButton)
    #expect(view1.meeting.id == view2.meeting.id)
  }

  @Test("Component handles long meeting titles appropriately")
  @MainActor
  func componentLongTitles() {
    let view = MeetingRowView(meeting: PreviewData.longTitleMeeting)

    // Should handle long titles without issues
    #expect(view.meeting.title == PreviewData.longTitleMeeting.title)
    #expect(view.hasJoinUrl == true)  // longTitleMeeting should have URL
  }

  @Test("Component handles minimal meeting data")
  @MainActor
  func componentMinimalMeetingData() {
    let view = MeetingRowView(meeting: PreviewData.minimalMeeting)

    // Should handle meetings with minimal information
    #expect(view.meeting.title == PreviewData.minimalMeeting.title)
    #expect(view.meeting.organizerName == nil)
    #expect(view.meeting.attendeeCount == 0)
  }

  // MARK: - Edge Cases

  @Test("Component handles future meeting dates correctly")
  @MainActor
  func componentFutureMeetingDates() {
    // Create a meeting far in the future
    let futureDate = Date().addingTimeInterval(86400 * 30)  // 30 days from now
    let futureMeeting = Meeting(
      id: UUID(),
      title: "Future Meeting",
      startTime: futureDate,
      endTime: futureDate.addingTimeInterval(3600),
      joinUrl: "https://zoom.us/j/future",
      platform: .zoom,
      organizerName: "Future Organizer",
      organizerEmail: nil,
      attendeeCount: 5,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-future"
    )

    let view = MeetingRowView(meeting: futureMeeting)

    #expect(!view.meeting.hasEnded)
    #expect(view.hasJoinUrl == true)
    #expect(view.shouldShowJoinButton == true)
  }

  @Test("Component handles complex URL formats")
  @MainActor
  func componentComplexUrlFormats() {
    let complexUrlMeeting = Meeting(
      id: UUID(),
      title: "Complex URL Meeting",
      startTime: Date().addingTimeInterval(3600),
      endTime: Date().addingTimeInterval(7200),
      joinUrl: "https://company.zoom.us/j/123456789?pwd=abcd1234&uname=user#success",
      platform: .zoom,
      organizerName: "Test",
      organizerEmail: nil,
      attendeeCount: 1,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-complex-url"
    )

    let view = MeetingRowView(meeting: complexUrlMeeting)

    #expect(view.hasJoinUrl == true)
    #expect(view.shouldShowJoinButton == true)
  }

  // MARK: - State Transition Tests

  @Test("Component properly evaluates meeting state transitions")
  @MainActor
  func componentStateTransitions() {
    let now = Date()

    // Meeting transitioning from upcoming to active
    let transitioningMeeting = Meeting(
      id: UUID(),
      title: "Transitioning Meeting",
      startTime: now.addingTimeInterval(-60),  // Started 1 minute ago
      endTime: now.addingTimeInterval(3540),  // Ends in 59 minutes
      joinUrl: "https://zoom.us/j/transition",
      platform: .zoom,
      organizerName: "Test",
      organizerEmail: nil,
      attendeeCount: 1,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-transition"
    )

    let view = MeetingRowView(meeting: transitioningMeeting)

    // Should be active and show join button
    #expect(view.meeting.hasStarted && !view.meeting.hasEnded)
    #expect(!view.meeting.hasEnded)
    #expect(view.shouldShowJoinButton == true)
  }
}
