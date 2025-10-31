// ABOUTME: Tests for AppModel @Observable class and CalendarAuthState enum
// ABOUTME: Tests state management for user preferences and calendar authorization states

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
    #expect(appModel.alwaysOnTop == false)
    #expect(appModel.hideCompletedMeetingsAfter5Min == true)
  }

  // MARK: - User Preferences Tests

  @Test func testAlwaysOnTopProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.alwaysOnTop == false)

    // Test changing value
    appModel.alwaysOnTop = true
    #expect(appModel.alwaysOnTop == true)

    // Test changing back
    appModel.alwaysOnTop = false
    #expect(appModel.alwaysOnTop == false)
  }

  @Test func testHideCompletedMeetingsProperty() {
    let appModel = AppModel()

    // Test default value
    #expect(appModel.hideCompletedMeetingsAfter5Min == true)

    // Test changing value
    appModel.hideCompletedMeetingsAfter5Min = false
    #expect(appModel.hideCompletedMeetingsAfter5Min == false)

    // Test changing back
    appModel.hideCompletedMeetingsAfter5Min = true
    #expect(appModel.hideCompletedMeetingsAfter5Min == true)
  }

  // MARK: - Complex State Management Tests

  @Test func testMultiplePropertyChanges() {
    let appModel = AppModel()

    // Change multiple properties
    appModel.alwaysOnTop = true
    appModel.hideCompletedMeetingsAfter5Min = false

    // Verify all changes persisted
    #expect(appModel.alwaysOnTop == true)
    #expect(appModel.hideCompletedMeetingsAfter5Min == false)
  }

  // MARK: - Thread Safety Tests (Sendable Context)

  @Test func testAppModelInAsyncContext() async {
    let appModel = AppModel()

    // Test that we can use AppModel in async context
    await Task { @MainActor in
      appModel.alwaysOnTop = true
      appModel.hideCompletedMeetingsAfter5Min = false
    }.value

    // Verify changes were applied
    await Task { @MainActor in
      #expect(appModel.alwaysOnTop == true)
      #expect(appModel.hideCompletedMeetingsAfter5Min == false)
    }.value
  }
}
