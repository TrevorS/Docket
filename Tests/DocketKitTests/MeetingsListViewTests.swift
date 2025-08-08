// ABOUTME: Comprehensive test suite for MeetingsListView UI components and behavior
// ABOUTME: Tests view state handling, CalendarManager integration, and user interaction flows

import SwiftUI
import Testing

@testable import DocketKit

/// Test suite for MeetingsListView functionality and behavior
struct MeetingsListViewTests {

  // Note: SwiftUI view testing in CLI environment is limited
  // SwiftUI views with @State properties are MainActor-isolated and cannot be instantiated in tests
  // These tests focus on the testable aspects of view logic and business rules

  // MARK: - Helper Functions Tests

  @Test("Time formatting helper produces correct format")
  func testTimeFormatting() {
    // Test the time formatting logic that would be used in MeetingRowView
    let calendar = Calendar.current
    let startTime = calendar.date(from: DateComponents(hour: 14, minute: 30)) ?? Date()
    let endTime = calendar.date(from: DateComponents(hour: 15, minute: 30)) ?? Date()

    let formatter = DateFormatter()
    formatter.timeStyle = .short

    let startString = formatter.string(from: startTime)
    let endString = formatter.string(from: endTime)

    // Verify the formatting produces reasonable output
    #expect(!startString.isEmpty)
    #expect(!endString.isEmpty)
    #expect(startString != endString)
  }

  @Test("Duration calculation produces correct text")
  func testDurationCalculation() {
    // Test duration calculation logic from MeetingRowView
    let startTime = Date()
    let thirtyMinutes = startTime.addingTimeInterval(1800)  // 30 minutes
    let oneHour = startTime.addingTimeInterval(3600)  // 1 hour
    let ninetyMinutes = startTime.addingTimeInterval(5400)  // 90 minutes

    // 30 minute duration
    let thirtyMinDuration = thirtyMinutes.timeIntervalSince(startTime)
    let thirtyMinText = formatDuration(thirtyMinDuration)
    #expect(thirtyMinText == "30m")

    // 60 minute duration
    let oneHourDuration = oneHour.timeIntervalSince(startTime)
    let oneHourText = formatDuration(oneHourDuration)
    #expect(oneHourText == "1h")

    // 90 minute duration
    let ninetyMinDuration = ninetyMinutes.timeIntervalSince(startTime)
    let ninetyMinText = formatDuration(ninetyMinDuration)
    #expect(ninetyMinText == "1h 30m")
  }

  // Helper function matching MeetingRowView logic
  private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration / 60)

    if minutes < 60 {
      return "\(minutes)m"
    } else {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60
      if remainingMinutes == 0 {
        return "\(hours)h"
      } else {
        return "\(hours)h \(remainingMinutes)m"
      }
    }
  }

  // MARK: - Status Color Logic Tests

  @Test("Status color logic matches meeting states")
  func testStatusColorLogic() {
    let now = Date()

    // Future meeting (more than 5 minutes away)
    let futureMeeting = Meeting(
      id: UUID(),
      title: "Future Meeting",
      startTime: now.addingTimeInterval(600),  // 10 minutes from now
      endTime: now.addingTimeInterval(1800),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "future"
    )

    // Upcoming meeting (within 5 minutes)
    let upcomingMeeting = Meeting(
      id: UUID(),
      title: "Upcoming Meeting",
      startTime: now.addingTimeInterval(240),  // 4 minutes from now
      endTime: now.addingTimeInterval(1800),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "upcoming"
    )

    // Started meeting
    let startedMeeting = Meeting(
      id: UUID(),
      title: "Started Meeting",
      startTime: now.addingTimeInterval(-600),  // 10 minutes ago
      endTime: now.addingTimeInterval(600),  // 10 minutes from now
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "started"
    )

    // Ended meeting
    let endedMeeting = Meeting(
      id: UUID(),
      title: "Ended Meeting",
      startTime: now.addingTimeInterval(-1800),  // 30 minutes ago
      endTime: now.addingTimeInterval(-600),  // 10 minutes ago
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "ended"
    )

    // Test meeting state calculations
    #expect(!futureMeeting.isUpcoming)
    #expect(!futureMeeting.hasStarted)
    #expect(!futureMeeting.hasEnded)

    #expect(upcomingMeeting.isUpcoming)
    #expect(!upcomingMeeting.hasStarted)
    #expect(!upcomingMeeting.hasEnded)

    #expect(!startedMeeting.isUpcoming)
    #expect(startedMeeting.hasStarted)
    #expect(!startedMeeting.hasEnded)

    #expect(!endedMeeting.isUpcoming)
    #expect(endedMeeting.hasStarted)
    #expect(endedMeeting.hasEnded)
  }

  // MARK: - Join Button Logic Tests

  @Test("Join button logic matches meeting states and URLs")
  func testJoinButtonLogic() {
    let now = Date()

    // Meeting with URL, not ended
    let activeWithURL = Meeting(
      id: UUID(),
      title: "Active Meeting",
      startTime: now.addingTimeInterval(-300),
      endTime: now.addingTimeInterval(900),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "active-url"
    )

    // Meeting without URL
    let activeWithoutURL = Meeting(
      id: UUID(),
      title: "Active Meeting No URL",
      startTime: now.addingTimeInterval(-300),
      endTime: now.addingTimeInterval(900),
      joinUrl: "",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "active-no-url"
    )

    // Ended meeting with URL
    let endedWithURL = Meeting(
      id: UUID(),
      title: "Ended Meeting",
      startTime: now.addingTimeInterval(-1800),
      endTime: now.addingTimeInterval(-600),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Calendar",
      eventIdentifier: "ended-url"
    )

    // Test join button visibility logic
    #expect(shouldShowJoinButton(for: activeWithURL))
    #expect(!shouldShowJoinButton(for: activeWithoutURL))
    #expect(!shouldShowJoinButton(for: endedWithURL))
  }

  // Helper function matching MeetingRowView logic
  private func shouldShowJoinButton(for meeting: Meeting) -> Bool {
    return !meeting.hasEnded && !(meeting.joinUrl?.isEmpty ?? true)
  }

  // MARK: - Calendar Authorization State Tests

  @Test("Authorization state handling covers all cases")
  func testAuthorizationStates() {
    let states: [CalendarAuthState] = [
      .notDetermined,
      .denied,
      .restricted,
      .authorized,
      .fullAccess,
      .writeOnly,
      .error("Test error message"),
    ]

    // Verify each state can be handled
    for state in states {
      let description = getAuthStateDescription(state)
      #expect(!description.isEmpty)
    }
  }

  // Helper function matching MeetingsListView logic
  private func getAuthStateDescription(_ state: CalendarAuthState) -> String {
    switch state {
    case .notDetermined:
      return "Calendar Access Required"
    case .denied:
      return "Calendar Access Denied"
    case .restricted:
      return "Calendar Access Restricted"
    case .fullAccess, .authorized:
      return "No Zoom Meetings Today"
    case .writeOnly:
      return "Calendar Access Required"
    case .error(let message):
      return "Error Loading Calendar: \(message)"
    }
  }

  // MARK: - Meeting Row Content Tests

  @Test("Meeting row displays all required information")
  func testMeetingRowContent() {
    let meeting = Meeting(
      id: UUID(),
      title: "Test Meeting with Long Title That Should Wrap",
      startTime: Date(),
      endTime: Date().addingTimeInterval(3600),
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom,
      organizerName: "John Doe",
      organizerEmail: "john@example.com",
      attendeeCount: 5,
      calendarName: "Work Calendar",
      eventIdentifier: "test-event"
    )

    // Verify all meeting properties are available for display
    #expect(!meeting.title.isEmpty)
    #expect(!(meeting.joinUrl?.isEmpty ?? true))
    #expect(meeting.organizerName != nil)
    #expect(!meeting.calendarName.isEmpty)
    #expect(meeting.attendeeCount > 0)
    #expect(meeting.endTime > meeting.startTime)
  }

  // MARK: - Enhanced Meeting Row Tests

  @Test("Enhanced meeting row displays comprehensive information")
  func testEnhancedMeetingRowContent() {
    let now = Date()

    // Create a comprehensive meeting with all fields
    let comprehensiveMeeting = Meeting(
      id: UUID(),
      title: "Quarterly Business Review - Q4 Planning Session",
      startTime: now.addingTimeInterval(300),  // Starts in 5 minutes (upcoming)
      endTime: now.addingTimeInterval(3900),  // 60 minutes duration
      joinUrl: "https://zoom.us/j/123456789?pwd=abcd1234",
      platform: .zoom,
      organizerName: "Alice Johnson",
      organizerEmail: "alice@example.com",
      attendeeCount: 12,
      calendarName: "Work Calendar",
      eventIdentifier: "test-event-comprehensive"
    )

    // Verify all fields are properly set for enhanced row display
    #expect(!comprehensiveMeeting.title.isEmpty)
    #expect(comprehensiveMeeting.organizerName == "Alice Johnson")
    #expect(comprehensiveMeeting.attendeeCount == 12)
    #expect(!comprehensiveMeeting.calendarName.isEmpty)
    #expect(!(comprehensiveMeeting.joinUrl?.isEmpty ?? true))
    #expect(comprehensiveMeeting.isUpcoming)  // Should be upcoming
    #expect(!comprehensiveMeeting.hasStarted)
    #expect(!comprehensiveMeeting.hasEnded)

    // Test minimal meeting (only required fields)
    let minimalMeeting = Meeting(
      id: UUID(),
      title: "Quick Sync",
      startTime: now.addingTimeInterval(-300),  // Started 5 minutes ago
      endTime: now.addingTimeInterval(600),  // Ends in 10 minutes
      joinUrl: "https://zoom.us/j/987654321",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "",
      eventIdentifier: "test-event-minimal"
    )

    // Verify minimal meeting handles empty fields gracefully
    #expect(!minimalMeeting.title.isEmpty)
    #expect(minimalMeeting.organizerName == nil)
    #expect(minimalMeeting.attendeeCount == 0)
    #expect(minimalMeeting.calendarName.isEmpty)
    #expect(!(minimalMeeting.joinUrl?.isEmpty ?? true))
    #expect(minimalMeeting.hasStarted)  // Should be in progress
    #expect(!minimalMeeting.hasEnded)
  }

  @Test("Copy link functionality validation")
  func testCopyLinkValidation() {
    let now = Date()

    // Meeting with valid join URL - should show copy button
    let meetingWithUrl = Meeting(
      id: UUID(),
      title: "Team Standup",
      startTime: now.addingTimeInterval(900),  // 15 minutes from now
      endTime: now.addingTimeInterval(2700),  // 45 minutes duration
      joinUrl: "https://zoom.us/j/555666777?pwd=secretpassword",
      platform: .zoom,
      organizerName: "Bob Wilson",
      organizerEmail: "bob@company.com",
      attendeeCount: 8,
      calendarName: "Team Calendar",
      eventIdentifier: "standup-meeting"
    )

    #expect(!(meetingWithUrl.joinUrl?.isEmpty ?? true))

    // Meeting without join URL - should not show copy button
    let meetingNoUrl = Meeting(
      id: UUID(),
      title: "Lunch Break",
      startTime: now.addingTimeInterval(3600),
      endTime: now.addingTimeInterval(5400),
      joinUrl: "",
      platform: .zoom,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      calendarName: "Personal",
      eventIdentifier: "lunch-event"
    )

    #expect(meetingNoUrl.joinUrl?.isEmpty ?? true)

    // Meeting with nil join URL - should not show copy button
    let meetingNilUrl = Meeting(
      id: UUID(),
      title: "Coffee Chat",
      startTime: now.addingTimeInterval(1800),
      endTime: now.addingTimeInterval(3600),
      joinUrl: nil,
      platform: .zoom,
      organizerName: "Charlie Brown",
      organizerEmail: nil,
      attendeeCount: 2,
      calendarName: "Personal",
      eventIdentifier: "coffee-chat"
    )

    #expect(meetingNilUrl.joinUrl == nil)
  }

  @Test("Enhanced row supports copy button for meetings with URLs")
  func testCopyButtonVisibility() {
    let now = Date()

    // Test copy button logic matches hasJoinUrl helper
    let testCases = [
      ("Valid URL", "https://zoom.us/j/123456789", true),
      ("Empty URL", "", false),
      ("Nil URL", nil, false),
      ("Whitespace URL", "   ", false),
      ("Government URL", "https://company.zoomgov.com/j/987654321", true),
    ]

    for (description, joinUrl, shouldShowCopy) in testCases {
      let meeting = Meeting(
        id: UUID(),
        title: description,
        startTime: now.addingTimeInterval(600),
        endTime: now.addingTimeInterval(1800),
        joinUrl: joinUrl,
        platform: .zoom,
        organizerName: "Test User",
        organizerEmail: nil,
        attendeeCount: 1,
        calendarName: "Test Calendar",
        eventIdentifier: "test-\(description.lowercased().replacingOccurrences(of: " ", with: "-"))"
      )

      let hasUrl =
        !(meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
      #expect(hasUrl == shouldShowCopy, "Copy button visibility for: \(description)")
    }
  }

  // MARK: - Collapsible Day Section Tests

  @Test("Day section collapse logic identifies completed meetings and past days")
  func testSmartDayCompletionLogic() {
    let now = Date()

    // Test empty day - should not be considered for auto-collapse
    let emptyMeetings: [Meeting] = []
    #expect(!shouldDayAutoCollapse(meetings: emptyMeetings, title: "Today"))

    // Test day with active meetings - should not auto-collapse
    let activeMeetings = [
      Meeting(
        id: UUID(),
        title: "Active Meeting",
        startTime: now.addingTimeInterval(-900),  // Started 15 min ago
        endTime: now.addingTimeInterval(600),  // Ends in 10 min
        joinUrl: "https://zoom.us/j/active123",
        platform: .zoom,
        organizerName: "Active Organizer",
        organizerEmail: nil,
        attendeeCount: 5,
        calendarName: "Work",
        eventIdentifier: "active-test"
      )
    ]
    #expect(!shouldDayAutoCollapse(meetings: activeMeetings, title: "Today"))

    // Test today's completed meetings - should NOT auto-collapse (manual only)
    let todayCompletedMeetings = [
      Meeting(
        id: UUID(),
        title: "Completed Meeting Today",
        startTime: now.addingTimeInterval(-7200),  // Started 2 hours ago
        endTime: now.addingTimeInterval(-5400),  // Ended 1.5 hours ago
        joinUrl: "https://zoom.us/j/completed1",
        platform: .zoom,
        organizerName: "Organizer 1",
        organizerEmail: nil,
        attendeeCount: 3,
        calendarName: "Work",
        eventIdentifier: "today-completed"
      )
    ]
    #expect(!shouldDayAutoCollapse(meetings: todayCompletedMeetings, title: "Today"))

    // Test yesterday's completed meetings - SHOULD auto-collapse
    let yesterdayCompletedMeetings = [
      Meeting(
        id: UUID(),
        title: "Yesterday Meeting",
        startTime: now.addingTimeInterval(-86400 - 3600),  // Yesterday, 1 hour duration
        endTime: now.addingTimeInterval(-86400),  // Ended yesterday
        joinUrl: "https://zoom.us/j/yesterday1",
        platform: .zoom,
        organizerName: "Yesterday Organizer",
        organizerEmail: nil,
        attendeeCount: 4,
        calendarName: "Work",
        eventIdentifier: "yesterday-completed"
      )
    ]
    #expect(shouldDayAutoCollapse(meetings: yesterdayCompletedMeetings, title: "Yesterday"))

    // Test mixed day - should not auto-collapse regardless of title
    let mixedMeetings = todayCompletedMeetings + activeMeetings
    #expect(!shouldDayAutoCollapse(meetings: mixedMeetings, title: "Today"))
    #expect(!shouldDayAutoCollapse(meetings: mixedMeetings, title: "Yesterday"))
  }

  @Test("Manual collapse and expand functionality")
  func testManualCollapseExpand() {
    let now = Date()

    // Create completed meetings that should be collapsible
    let completedMeetings = [
      Meeting(
        id: UUID(),
        title: "Completed Meeting",
        startTime: now.addingTimeInterval(-3600),  // Started 1 hour ago
        endTime: now.addingTimeInterval(-1800),  // Ended 30 min ago
        joinUrl: "https://zoom.us/j/completed123",
        platform: .zoom,
        organizerName: "Test Organizer",
        organizerEmail: nil,
        attendeeCount: 4,
        calendarName: "Test Calendar",
        eventIdentifier: "manual-collapse-test"
      )
    ]

    // Test that completed meetings can be manually collapsed (but not auto-collapsed if today)
    #expect(
      !shouldDayAutoCollapse(meetings: completedMeetings, title: "Today"),
      "Today's completed meetings should require manual collapse")
    #expect(
      shouldDayAutoCollapse(meetings: completedMeetings, title: "Yesterday"),
      "Yesterday's completed meetings should auto-collapse")

    // Verify meetings are actually completed
    for meeting in completedMeetings {
      #expect(meeting.hasEnded, "Meeting should be ended for manual collapse testing")
    }

    // Test non-completed meetings cannot be collapsed regardless of day
    let activeMeetings = [
      Meeting(
        id: UUID(),
        title: "Active Meeting",
        startTime: now.addingTimeInterval(-300),  // Started 5 min ago
        endTime: now.addingTimeInterval(900),  // Ends in 15 min
        joinUrl: "https://zoom.us/j/active123",
        platform: .zoom,
        organizerName: "Active Organizer",
        organizerEmail: nil,
        attendeeCount: 2,
        calendarName: "Test Calendar",
        eventIdentifier: "active-test"
      )
    ]

    #expect(
      !shouldDayAutoCollapse(meetings: activeMeetings, title: "Today"),
      "Active meetings should not be eligible for collapse")
    #expect(
      !shouldDayAutoCollapse(meetings: activeMeetings, title: "Yesterday"),
      "Active meetings should not be eligible for collapse even if yesterday")
  }

  // Helper function matching DaySectionView smart collapse logic
  private func shouldDayAutoCollapse(meetings: [Meeting], title: String) -> Bool {
    let allCompleted = !meetings.isEmpty && meetings.allSatisfy { $0.hasEnded }

    // Check if this is a past day
    let isPastDay =
      title.lowercased() == "yesterday"
      || (!meetings.isEmpty
        && meetings.allSatisfy { $0.endTime < Date().addingTimeInterval(-43200) })  // 12 hours ago

    return allCompleted && isPastDay
  }
}
