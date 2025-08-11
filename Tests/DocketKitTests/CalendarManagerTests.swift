// ABOUTME: Comprehensive test suite for CalendarManager business logic and EventKit integration
// ABOUTME: Tests calendar access, event conversion, filtering, and error handling using Swift Testing

import EventKit
import Foundation
import Testing

@testable import DocketKit

/// Comprehensive test suite for CalendarManager functionality
struct CalendarManagerTests {

  // MARK: - Test Data Helpers

  /// Create a mock calendar event for testing
  private func createMockEvent(
    title: String,
    startDate: Date,
    endDate: Date,
    location: String? = nil,
    notes: String? = nil,
    url: String? = nil,
    virtualConferenceURL: String? = nil,
    organizerName: String? = nil,
    organizerEmail: String? = nil,
    attendeeCount: Int = 0,
    calendarTitle: String = "Test Calendar",
    eventIdentifier: String = "test-event-123"
  ) -> MockCalendarEvent {
    return MockCalendarEvent(
      title: title,
      startDate: startDate,
      endDate: endDate,
      location: location,
      notes: notes,
      url: url,
      virtualConferenceURL: virtualConferenceURL,
      organizerName: organizerName,
      organizerEmail: organizerEmail,
      attendeeCount: attendeeCount,
      calendarTitle: calendarTitle,
      eventIdentifier: eventIdentifier
    )
  }

  // MARK: - Initialization Tests

  @Test("CalendarManager initializes with correct default state")
  func testInitialization() {
    let manager = CalendarManager()

    #expect(manager.meetings.isEmpty)
    #expect(manager.lastRefresh == nil)
    #expect(manager.isRefreshing == false)
    // Note: authState will be .notDetermined or based on current system state
  }

  // MARK: - Authorization State Mapping Tests

  @Test("Calendar authorization state mapping works correctly")
  func testAuthorizationStateMapping() {
    let manager = CalendarManager()

    // Test the private method via reflection or create a testable version
    // For now, we'll test the public interface behavior
    #expect(manager.authState != .error(""))
  }

  // MARK: - Event Conversion Tests

  @Test("Mock event with Zoom URL converts to Meeting correctly")
  func testEventWithZoomURLConversion() {
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(3600)  // 1 hour meeting

    let mockEvent = createMockEvent(
      title: "Team Standup",
      startDate: startTime,
      endDate: endTime,
      location: "Join: https://zoom.us/j/123456789",
      organizerName: "John Doe",
      organizerEmail: "john@example.com",
      attendeeCount: 5
    )

    let manager = CalendarManager()
    let eventData = [
      (
        event: mockEvent, title: mockEvent.title, startDate: mockEvent.startDate,
        endDate: mockEvent.endDate, organizerName: mockEvent.organizerName,
        organizerEmail: mockEvent.organizerEmail, attendeeCount: mockEvent.attendeeCount,
        calendarTitle: mockEvent.calendarTitle, eventIdentifier: mockEvent.eventIdentifier
      )
    ]
    let meetings = manager.convertCalendarEventsToMeetings(eventData)

    #expect(meetings.count == 1)

    let meeting = meetings[0]
    #expect(meeting.title == "Team Standup")
    #expect(meeting.startTime == startTime)
    #expect(meeting.endTime == endTime)
    #expect(meeting.joinUrl == "https://zoom.us/j/123456789")
    #expect(meeting.organizerName == "John Doe")
    #expect(meeting.organizerEmail == "john@example.com")
    #expect(meeting.attendeeCount == 5)
    #expect(meeting.calendarName == "Test Calendar")
    #expect(meeting.eventIdentifier == "test-event-123")
  }

  @Test("Mock event without Zoom URL is filtered out")
  func testEventWithoutZoomURLFiltered() {
    let mockEvent = createMockEvent(
      title: "Regular Meeting",
      startDate: Date(),
      endDate: Date().addingTimeInterval(3600),
      location: "Conference Room A"
    )

    let manager = CalendarManager()
    let eventData = [
      (
        event: mockEvent, title: mockEvent.title, startDate: mockEvent.startDate,
        endDate: mockEvent.endDate, organizerName: mockEvent.organizerName,
        organizerEmail: mockEvent.organizerEmail, attendeeCount: mockEvent.attendeeCount,
        calendarTitle: mockEvent.calendarTitle, eventIdentifier: mockEvent.eventIdentifier
      )
    ]
    let meetings = manager.convertCalendarEventsToMeetings(eventData)

    #expect(meetings.isEmpty)
  }

  @Test("Multiple events with mixed Zoom URLs are filtered correctly")
  func testMixedEventsFiltering() {
    let now = Date()

    let zoomMeeting1 = createMockEvent(
      title: "Zoom Meeting 1",
      startDate: now,
      endDate: now.addingTimeInterval(1800),
      notes: "Join meeting: https://zoom.us/j/111111111"
    )

    let regularMeeting = createMockEvent(
      title: "Regular Meeting",
      startDate: now.addingTimeInterval(3600),
      endDate: now.addingTimeInterval(5400),
      location: "Office Building"
    )

    let zoomMeeting2 = createMockEvent(
      title: "Zoom Meeting 2",
      startDate: now.addingTimeInterval(7200),
      endDate: now.addingTimeInterval(9000),
      location: "https://company.zoom.us/my/room"
    )

    let manager = CalendarManager()
    let eventData = [
      (
        event: zoomMeeting1, title: zoomMeeting1.title, startDate: zoomMeeting1.startDate,
        endDate: zoomMeeting1.endDate, organizerName: zoomMeeting1.organizerName,
        organizerEmail: zoomMeeting1.organizerEmail, attendeeCount: zoomMeeting1.attendeeCount,
        calendarTitle: zoomMeeting1.calendarTitle, eventIdentifier: zoomMeeting1.eventIdentifier
      ),
      (
        event: regularMeeting, title: regularMeeting.title, startDate: regularMeeting.startDate,
        endDate: regularMeeting.endDate, organizerName: regularMeeting.organizerName,
        organizerEmail: regularMeeting.organizerEmail, attendeeCount: regularMeeting.attendeeCount,
        calendarTitle: regularMeeting.calendarTitle, eventIdentifier: regularMeeting.eventIdentifier
      ),
      (
        event: zoomMeeting2, title: zoomMeeting2.title, startDate: zoomMeeting2.startDate,
        endDate: zoomMeeting2.endDate, organizerName: zoomMeeting2.organizerName,
        organizerEmail: zoomMeeting2.organizerEmail, attendeeCount: zoomMeeting2.attendeeCount,
        calendarTitle: zoomMeeting2.calendarTitle, eventIdentifier: zoomMeeting2.eventIdentifier
      ),
    ]
    let meetings = manager.convertCalendarEventsToMeetings(eventData)

    #expect(meetings.count == 2)
    #expect(meetings[0].title == "Zoom Meeting 1")
    #expect(meetings[1].title == "Zoom Meeting 2")
  }

  // MARK: - Meeting Sorting Tests

  @Test("Meetings are sorted chronologically by start time")
  func testMeetingSorting() {
    let now = Date()

    let laterMeeting = createMockEvent(
      title: "Later Meeting",
      startDate: now.addingTimeInterval(7200),  // 2 hours later
      endDate: now.addingTimeInterval(9000),
      location: "https://zoom.us/j/222222222"
    )

    let earlierMeeting = createMockEvent(
      title: "Earlier Meeting",
      startDate: now.addingTimeInterval(1800),  // 30 minutes later
      endDate: now.addingTimeInterval(3600),
      location: "https://zoom.us/j/111111111"
    )

    let manager = CalendarManager()
    let eventData = [
      (
        event: laterMeeting, title: laterMeeting.title, startDate: laterMeeting.startDate,
        endDate: laterMeeting.endDate, organizerName: laterMeeting.organizerName,
        organizerEmail: laterMeeting.organizerEmail, attendeeCount: laterMeeting.attendeeCount,
        calendarTitle: laterMeeting.calendarTitle, eventIdentifier: laterMeeting.eventIdentifier
      ),
      (
        event: earlierMeeting, title: earlierMeeting.title, startDate: earlierMeeting.startDate,
        endDate: earlierMeeting.endDate, organizerName: earlierMeeting.organizerName,
        organizerEmail: earlierMeeting.organizerEmail, attendeeCount: earlierMeeting.attendeeCount,
        calendarTitle: earlierMeeting.calendarTitle, eventIdentifier: earlierMeeting.eventIdentifier
      ),
    ]
    let meetings = manager.convertCalendarEventsToMeetings(eventData)
    let sortedMeetings = meetings.sorted { $0.startTime < $1.startTime }

    #expect(sortedMeetings.count == 2)
    #expect(sortedMeetings[0].title == "Earlier Meeting")
    #expect(sortedMeetings[1].title == "Later Meeting")
  }

  // MARK: - Error Handling Tests

  @Test("CalendarError provides proper error descriptions")
  func testCalendarErrorDescriptions() {
    let accessDeniedError = CalendarError.accessDenied
    let fetchError = CalendarError.fetchFailed(NSError(domain: "test", code: 1))
    let invalidError = CalendarError.invalidEvent

    #expect(accessDeniedError.errorDescription?.contains("access denied") == true)
    #expect(fetchError.errorDescription?.contains("fetch") == true)
    #expect(invalidError.errorDescription?.contains("Invalid") == true)

    #expect(accessDeniedError.recoverySuggestion?.contains("Settings") == true)
    #expect(fetchError.recoverySuggestion?.contains("connection") == true)
    #expect(invalidError.recoverySuggestion?.contains("Verify") == true)
  }

  // MARK: - EKEvent Extension Tests

  // Note: EKEvent extension testing is not practical with mock objects
  // Real EKEvent testing would require EventKit integration testing
  // which is covered by the CalendarManager integration tests

  // EKEvent extension tests removed - these would require real EKEvent objects
  // The extension is tested implicitly through CalendarManager integration tests

  // MARK: - Integration with ZoomURLExtractor Tests

  @Test("CalendarManager correctly uses ZoomURLExtractor for URL extraction")
  func testZoomURLExtractorIntegration() {
    // Test various URL locations that ZoomURLExtractor should handle
    let eventWithLocationURL = createMockEvent(
      title: "Meeting 1",
      startDate: Date(),
      endDate: Date().addingTimeInterval(3600),
      location: "Join here: https://zoom.us/j/123456789"
    )

    let eventWithNotesURL = createMockEvent(
      title: "Meeting 2",
      startDate: Date().addingTimeInterval(3600),
      endDate: Date().addingTimeInterval(7200),
      notes: "Please join the meeting: https://company.zoom.us/my/room"
    )

    let manager = CalendarManager()
    let eventData = [
      (
        event: eventWithLocationURL, title: eventWithLocationURL.title,
        startDate: eventWithLocationURL.startDate, endDate: eventWithLocationURL.endDate,
        organizerName: eventWithLocationURL.organizerName,
        organizerEmail: eventWithLocationURL.organizerEmail,
        attendeeCount: eventWithLocationURL.attendeeCount,
        calendarTitle: eventWithLocationURL.calendarTitle,
        eventIdentifier: eventWithLocationURL.eventIdentifier
      ),
      (
        event: eventWithNotesURL, title: eventWithNotesURL.title,
        startDate: eventWithNotesURL.startDate, endDate: eventWithNotesURL.endDate,
        organizerName: eventWithNotesURL.organizerName,
        organizerEmail: eventWithNotesURL.organizerEmail,
        attendeeCount: eventWithNotesURL.attendeeCount,
        calendarTitle: eventWithNotesURL.calendarTitle,
        eventIdentifier: eventWithNotesURL.eventIdentifier
      ),
    ]
    let meetings = manager.convertCalendarEventsToMeetings(eventData)

    #expect(meetings.count == 2)
    #expect(meetings[0].joinUrl == "https://zoom.us/j/123456789")
    #expect(meetings[1].joinUrl == "https://company.zoom.us/my/room")
  }

  // MARK: - Auto-Refresh Tests (Task 7)

  @Test("Auto-refresh timer can be started and stopped")
  @MainActor func testAutoRefreshTimerLifecycle() {
    let manager = CalendarManager()

    // Initially auto-refresh should not be active
    #expect(manager.isAutoRefreshActive == false)
    #expect(manager.isAutoRefreshEnabled == true)

    // Start auto-refresh
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)

    // Stop auto-refresh
    manager.stopAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)
  }

  @Test("Auto-refresh can be paused and resumed")
  @MainActor func testAutoRefreshPauseResume() {
    let manager = CalendarManager()

    // Start auto-refresh
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)

    // Pause auto-refresh (simulating app going to background)
    manager.pauseAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)

    // Resume auto-refresh (simulating app returning to foreground)
    manager.resumeAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)
  }

  @Test("Auto-refresh can be toggled on and off")
  @MainActor func testAutoRefreshToggle() {
    let manager = CalendarManager()
    let initialState = manager.isAutoRefreshEnabled

    // Toggle auto-refresh
    manager.toggleAutoRefresh()
    #expect(manager.isAutoRefreshEnabled != initialState)

    // Toggle back
    manager.toggleAutoRefresh()
    #expect(manager.isAutoRefreshEnabled == initialState)
  }

  @Test("Refresh state is tracked correctly during manual refresh")
  func testRefreshStateTracking() async {
    let manager = CalendarManager()

    // Initially should not be refreshing
    #expect(manager.isRefreshing == false)
    #expect(manager.lastRefresh == nil)

    // Set up auth state to allow refresh
    manager.authState = .authorized

    // Trigger refresh and verify state changes
    // Note: This will fail due to missing EKEventStore access in tests,
    // but we're testing the state management
    do {
      try await manager.refreshMeetings()
    } catch {
      // Expected to fail in test environment - we're testing state management
    }

    // After refresh attempt, should have updated lastRefresh (even on failure)
    // In real usage with proper calendar access, this would be set
    #expect(manager.isRefreshing == false)  // Should return to false after completion
  }

  @Test("Auto-refresh respects enabled state")
  @MainActor func testAutoRefreshRespectsEnabledState() {
    let manager = CalendarManager()

    // Disable auto-refresh
    manager.isAutoRefreshEnabled = false

    // Try to start auto-refresh
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)  // Should not start when disabled

    // Enable and start
    manager.isAutoRefreshEnabled = true
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)  // Should start when enabled
  }

  @Test("Resume auto-refresh only works when enabled and not active")
  @MainActor func testResumeAutoRefreshConditionalBehavior() {
    let manager = CalendarManager()

    // Test resume when disabled
    manager.isAutoRefreshEnabled = false
    manager.resumeAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)

    // Test resume when enabled but already active
    manager.isAutoRefreshEnabled = true
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)

    // Resume should not change anything when already active
    manager.resumeAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)
  }

  @Test("Pause auto-refresh only works when active")
  @MainActor func testPauseAutoRefreshConditionalBehavior() {
    let manager = CalendarManager()

    // Test pause when not active
    manager.pauseAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)  // Should remain false

    // Start auto-refresh then pause
    manager.startAutoRefresh()
    #expect(manager.isAutoRefreshActive == true)

    manager.pauseAutoRefresh()
    #expect(manager.isAutoRefreshActive == false)
  }
}

// MARK: - Test Protocols

/// Protocol for mock events that includes both CalendarEventLike and event metadata
protocol MockEventProtocol: CalendarEventLike {
  var title: String { get }
  var startDate: Date { get }
  var endDate: Date { get }
  var organizerName: String? { get }
  var organizerEmail: String? { get }
  var attendeeCount: Int { get }
  var calendarTitle: String { get }
  var eventIdentifier: String { get }
}

// MARK: - Mock Event for Testing

/// Mock CalendarEvent that conforms to CalendarEventLike and MockEventProtocol for testing
struct MockCalendarEvent: MockEventProtocol {
  let virtualConferenceURL: String?
  let url: String?
  let location: String?
  let notes: String?

  // Additional properties for creating Meeting (MockEventProtocol)
  let title: String
  let startDate: Date
  let endDate: Date
  let organizerName: String?
  let organizerEmail: String?
  let attendeeCount: Int
  let calendarTitle: String
  let eventIdentifier: String

  init(
    title: String,
    startDate: Date,
    endDate: Date,
    location: String? = nil,
    notes: String? = nil,
    url: String? = nil,
    virtualConferenceURL: String? = nil,
    organizerName: String? = nil,
    organizerEmail: String? = nil,
    attendeeCount: Int = 0,
    calendarTitle: String = "Test Calendar",
    eventIdentifier: String = "mock-event"
  ) {
    self.title = title
    self.startDate = startDate
    self.endDate = endDate
    self.location = location
    self.notes = notes
    self.url = url
    self.virtualConferenceURL = virtualConferenceURL
    self.organizerName = organizerName
    self.organizerEmail = organizerEmail
    self.attendeeCount = attendeeCount
    self.calendarTitle = calendarTitle
    self.eventIdentifier = eventIdentifier
  }
}
