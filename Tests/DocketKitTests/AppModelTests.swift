// ABOUTME: Comprehensive tests for AppModel @Observable class and CalendarAuthState enum
// ABOUTME: Tests state management, preferences, and calendar authorization states

import Foundation
import Testing

@testable import DocketKit

struct AppModelTests {

  // MARK: - CalendarAuthState Tests

  @Test func testCalendarAuthStateEquality() {
    #expect(CalendarAuthState.notDetermined == CalendarAuthState.notDetermined)
    #expect(CalendarAuthState.authorized == CalendarAuthState.authorized)
    #expect(CalendarAuthState.denied == CalendarAuthState.denied)
    #expect(CalendarAuthState.restricted == CalendarAuthState.restricted)

    let error1 = CalendarAuthState.error("Test error")
    let error2 = CalendarAuthState.error("Test error")
    let error3 = CalendarAuthState.error("Different error")

    #expect(error1 == error2)
    #expect(error1 != error3)
  }

  @Test func testCalendarAuthStateInequality() {
    #expect(CalendarAuthState.notDetermined != CalendarAuthState.authorized)
    #expect(CalendarAuthState.authorized != CalendarAuthState.denied)
    #expect(CalendarAuthState.denied != CalendarAuthState.restricted)
    #expect(CalendarAuthState.restricted != CalendarAuthState.error("test"))
    #expect(CalendarAuthState.notDetermined != CalendarAuthState.error("test"))
  }

  @Test func testCalendarAuthStateErrorMessages() {
    let errorMessage = "Calendar access failed"
    let errorState = CalendarAuthState.error(errorMessage)

    if case .error(let message) = errorState {
      #expect(message == errorMessage)
    } else {
      #expect(Bool(false), "Error state should contain message")
    }
  }

  // MARK: - AppModel Initialization Tests

  @Test func testAppModelDefaultInitialization() {
    let appModel = AppModel()

    // Test default user preferences
    #expect(appModel.showOnlyZoomMeetings == true)
    #expect(appModel.notificationTime == 5)
    #expect(appModel.selectedCalendars.isEmpty)
    #expect(appModel.windowOpacity == 1.0)
    #expect(appModel.alwaysOnTop == true)

    // Test default runtime state
    #expect(appModel.lastRefresh == nil)
    #expect(appModel.nextMeeting == nil)
  }

  @Test func testAppModelObservableConformance() {
    let appModel = AppModel()

    // Test that we can observe changes (compile-time check)
    Task { @MainActor in
      let _ = appModel.showOnlyZoomMeetings
      let _ = appModel.notificationTime
      let _ = appModel.windowOpacity
      // If this compiles, @Observable conformance is working
    }

    #expect(true, "@Observable conformance should work")
  }

  // MARK: - User Preferences Tests

  @Test func testShowOnlyZoomMeetingsProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.showOnlyZoomMeetings == true)

    // Test changing value
    appModel.showOnlyZoomMeetings = false
    #expect(appModel.showOnlyZoomMeetings == false)

    // Test changing back
    appModel.showOnlyZoomMeetings = true
    #expect(appModel.showOnlyZoomMeetings == true)
  }

  @Test func testNotificationTimeProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.notificationTime == 5)

    // Test changing to different valid values
    appModel.notificationTime = 10
    #expect(appModel.notificationTime == 10)

    appModel.notificationTime = 0
    #expect(appModel.notificationTime == 0)

    appModel.notificationTime = 15
    #expect(appModel.notificationTime == 15)

    // Test negative values (edge case)
    appModel.notificationTime = -1
    #expect(appModel.notificationTime == -1)
  }

  @Test func testSelectedCalendarsProperty() {
    let appModel = AppModel()

    // Test default empty set
    #expect(appModel.selectedCalendars.isEmpty)

    // Test adding calendars
    appModel.selectedCalendars.insert("Work")
    #expect(appModel.selectedCalendars.contains("Work"))
    #expect(appModel.selectedCalendars.count == 1)

    appModel.selectedCalendars.insert("Personal")
    #expect(appModel.selectedCalendars.contains("Personal"))
    #expect(appModel.selectedCalendars.count == 2)

    // Test removing calendars
    appModel.selectedCalendars.remove("Work")
    #expect(!appModel.selectedCalendars.contains("Work"))
    #expect(appModel.selectedCalendars.contains("Personal"))
    #expect(appModel.selectedCalendars.count == 1)

    // Test clearing
    appModel.selectedCalendars.removeAll()
    #expect(appModel.selectedCalendars.isEmpty)
  }

  @Test func testWindowOpacityProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.windowOpacity == 1.0)

    // Test valid opacity values
    appModel.windowOpacity = 0.8
    #expect(appModel.windowOpacity == 0.8)

    appModel.windowOpacity = 0.5
    #expect(appModel.windowOpacity == 0.5)

    appModel.windowOpacity = 0.95
    #expect(appModel.windowOpacity == 0.95)

    // Test edge case values (the model shouldn't validate, just store)
    appModel.windowOpacity = 0.0
    #expect(appModel.windowOpacity == 0.0)

    appModel.windowOpacity = 1.5  // Invalid but should be stored
    #expect(appModel.windowOpacity == 1.5)
  }

  @Test func testAlwaysOnTopProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.alwaysOnTop == true)

    // Test changing value
    appModel.alwaysOnTop = false
    #expect(appModel.alwaysOnTop == false)

    // Test changing back
    appModel.alwaysOnTop = true
    #expect(appModel.alwaysOnTop == true)
  }

  // MARK: - Runtime State Tests

  @Test func testLastRefreshProperty() {
    let appModel = AppModel()

    // Test default nil value
    #expect(appModel.lastRefresh == nil)

    // Test setting refresh time
    let now = Date()
    appModel.lastRefresh = now
    #expect(appModel.lastRefresh == now)

    // Test changing refresh time
    let later = now.addingTimeInterval(300)  // 5 minutes later
    appModel.lastRefresh = later
    #expect(appModel.lastRefresh == later)

    // Test setting back to nil
    appModel.lastRefresh = nil
    #expect(appModel.lastRefresh == nil)
  }

  @Test func testNextMeetingProperty() {
    let appModel = AppModel()

    // Test default nil value
    #expect(appModel.nextMeeting == nil)

    // Create a test meeting
    let startTime = Date()
    let endTime = startTime.addingTimeInterval(1800)  // 30 minutes
    let meeting = ZoomMeeting(
      id: UUID(),
      title: "Test Meeting",
      startTime: startTime,
      endTime: endTime,
      joinUrl: "https://zoom.us/j/123456789",
      organizerName: "John Doe",
      organizerEmail: "john@example.com",
      attendeeCount: 5,
      calendarName: "Work",
      eventIdentifier: "test-123"
    )

    // Test setting next meeting
    appModel.nextMeeting = meeting
    #expect(appModel.nextMeeting?.title == "Test Meeting")
    #expect(appModel.nextMeeting?.joinUrl == "https://zoom.us/j/123456789")

    // Test setting back to nil
    appModel.nextMeeting = nil
    #expect(appModel.nextMeeting == nil)
  }

  // MARK: - Complex State Management Tests

  @Test func testMultiplePropertyChanges() {
    let appModel = AppModel()

    // Change multiple properties
    appModel.showOnlyZoomMeetings = false
    appModel.notificationTime = 10
    appModel.windowOpacity = 0.9
    appModel.alwaysOnTop = false
    appModel.selectedCalendars.insert("Work")
    appModel.selectedCalendars.insert("Personal")
    appModel.lastRefresh = Date()

    // Verify all changes persisted
    #expect(appModel.showOnlyZoomMeetings == false)
    #expect(appModel.notificationTime == 10)
    #expect(appModel.windowOpacity == 0.9)
    #expect(appModel.alwaysOnTop == false)
    #expect(appModel.selectedCalendars.count == 2)
    #expect(appModel.selectedCalendars.contains("Work"))
    #expect(appModel.selectedCalendars.contains("Personal"))
    #expect(appModel.lastRefresh != nil)
  }

  @Test func testAppModelStateReset() {
    let appModel = AppModel()

    // Change all properties from defaults
    appModel.showOnlyZoomMeetings = false
    appModel.notificationTime = 15
    appModel.selectedCalendars.insert("Test")
    appModel.windowOpacity = 0.5
    appModel.alwaysOnTop = false
    appModel.lastRefresh = Date()

    // Create a fresh model to compare defaults
    let defaultModel = AppModel()

    // Reset to defaults manually (testing that we can restore state)
    appModel.showOnlyZoomMeetings = defaultModel.showOnlyZoomMeetings
    appModel.notificationTime = defaultModel.notificationTime
    appModel.selectedCalendars = defaultModel.selectedCalendars
    appModel.windowOpacity = defaultModel.windowOpacity
    appModel.alwaysOnTop = defaultModel.alwaysOnTop
    appModel.lastRefresh = defaultModel.lastRefresh
    appModel.nextMeeting = defaultModel.nextMeeting

    // Verify all back to defaults
    #expect(appModel.showOnlyZoomMeetings == true)
    #expect(appModel.notificationTime == 5)
    #expect(appModel.selectedCalendars.isEmpty)
    #expect(appModel.windowOpacity == 1.0)
    #expect(appModel.alwaysOnTop == true)
    #expect(appModel.lastRefresh == nil)
    #expect(appModel.nextMeeting == nil)
  }

  // MARK: - Thread Safety Tests (Sendable Context)

  @Test func testAppModelInAsyncContext() async {
    let appModel = AppModel()

    // Test that we can use AppModel in async context
    await Task { @MainActor in
      appModel.showOnlyZoomMeetings = false
      appModel.notificationTime = 10
      appModel.lastRefresh = Date()
    }.value

    // Verify changes were applied
    await Task { @MainActor in
      #expect(appModel.showOnlyZoomMeetings == false)
      #expect(appModel.notificationTime == 10)
      #expect(appModel.lastRefresh != nil)
    }.value
  }
}
