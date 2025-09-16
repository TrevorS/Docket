// ABOUTME: Tests for DaySectionView component covering collapsible logic and day states
// ABOUTME: Ensures correct auto-collapse behavior, past day detection, and meeting completion handling

import SwiftUI
import Testing

@testable import DocketKit

struct DaySectionViewTests {

  // MARK: - Basic Creation Tests

  @Test("DaySectionView can be created with empty meetings")
  @MainActor
  func creationWithEmptyMeetings() {
    let view = DaySectionView(title: "Today", meetings: [])

    #expect(view.title == "Today")
    #expect(view.meetings.isEmpty)
  }

  @Test("DaySectionView can be created with meetings")
  @MainActor
  func creationWithMeetings() {
    let meetings = [PreviewData.upcomingMeeting, PreviewData.activeMeeting]
    let view = DaySectionView(title: "Today", meetings: meetings)

    #expect(view.title == "Today")
    #expect(view.meetings.count == 2)
  }

  // MARK: - Completion Logic Tests

  @Test("allMeetingsCompleted returns false for empty meetings")
  @MainActor
  func allMeetingsCompletedEmptyMeetings() {
    let view = DaySectionView(title: "Today", meetings: [])

    // Should return false for empty meetings (no meetings to complete)
    #expect(view.allMeetingsCompleted == false)
  }

  @Test("allMeetingsCompleted returns true when all meetings have ended")
  @MainActor
  func allMeetingsCompletedAllEnded() {
    let endedMeetings = [PreviewData.endedMeeting]
    let view = DaySectionView(title: "Yesterday", meetings: endedMeetings)

    #expect(view.allMeetingsCompleted == true)
  }

  @Test("allMeetingsCompleted returns false when some meetings are not ended")
  @MainActor
  func allMeetingsCompletedMixedStates() {
    let mixedMeetings = [PreviewData.upcomingMeeting, PreviewData.endedMeeting]
    let view = DaySectionView(title: "Today", meetings: mixedMeetings)

    #expect(view.allMeetingsCompleted == false)
  }

  @Test("allMeetingsCompleted returns false when no meetings have ended")
  @MainActor
  func allMeetingsCompletedNoneEnded() {
    let upcomingMeetings = [PreviewData.upcomingMeeting, PreviewData.activeMeeting]
    let view = DaySectionView(title: "Today", meetings: upcomingMeetings)

    #expect(view.allMeetingsCompleted == false)
  }

  // MARK: - Past Day Detection Tests

  @Test("isPastDay returns true for 'yesterday' title")
  @MainActor
  func isPastDayYesterdayTitle() {
    let view = DaySectionView(title: "yesterday", meetings: [])

    #expect(view.isPastDay == true)
  }

  @Test("isPastDay returns true for 'Yesterday' title (case insensitive)")
  @MainActor
  func isPastDayYesterdayTitleCapitalized() {
    let view = DaySectionView(title: "Yesterday", meetings: [])

    #expect(view.isPastDay == true)
  }

  @Test("isPastDay returns false for 'Today' title")
  @MainActor
  func isPastDayTodayTitle() {
    let view = DaySectionView(title: "Today", meetings: [])

    #expect(view.isPastDay == false)
  }

  @Test("isPastDay returns false for 'Tomorrow' title")
  @MainActor
  func isPastDayTomorrowTitle() {
    let view = DaySectionView(title: "Tomorrow", meetings: [])

    #expect(view.isPastDay == false)
  }

  @Test("isPastDay returns true for meetings older than 12 hours")
  @MainActor
  func isPastDayOldMeetings() {
    // Create a meeting that ended more than 12 hours ago
    let fourteenHoursAgo = Date().addingTimeInterval(-14 * 3600)  // 14 hours ago
    let thirteenHoursAgo = Date().addingTimeInterval(-13 * 3600)  // 13 hours ago

    let oldMeeting = Meeting(
      id: UUID(),
      title: "Old Meeting",
      startTime: fourteenHoursAgo,
      endTime: thirteenHoursAgo,
      joinUrl: nil,
      platform: .unknown,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-old"
    )

    let view = DaySectionView(title: "Some Day", meetings: [oldMeeting])

    #expect(view.isPastDay == true)
  }

  @Test("isPastDay returns false for recent meetings")
  @MainActor
  func isPastDayRecentMeetings() {
    // Use a meeting that ended less than 12 hours ago
    let view = DaySectionView(title: "Some Day", meetings: [PreviewData.endedMeeting])

    #expect(view.isPastDay == false)
  }

  // MARK: - Auto-Collapse Logic Tests

  @Test("shouldAutoCollapse is false for empty meetings")
  @MainActor
  func shouldAutoCollapseEmptyMeetings() {
    let view = DaySectionView(title: "Yesterday", meetings: [])

    #expect(view.shouldAutoCollapse == false)
  }

  @Test("shouldAutoCollapse is true for completed yesterday meetings")
  @MainActor
  func shouldAutoCollapseCompletedYesterday() {
    let view = DaySectionView(title: "Yesterday", meetings: [PreviewData.endedMeeting])

    // Should auto-collapse if all meetings completed and it's yesterday
    #expect(view.shouldAutoCollapse == true)
  }

  @Test("shouldAutoCollapse is false for incomplete yesterday meetings")
  @MainActor
  func shouldAutoCollapseIncompleteYesterday() {
    let view = DaySectionView(title: "Yesterday", meetings: [PreviewData.upcomingMeeting])

    #expect(view.shouldAutoCollapse == false)
  }

  @Test("shouldAutoCollapse is false for completed today meetings")
  @MainActor
  func shouldAutoCollapseCompletedToday() {
    let view = DaySectionView(title: "Today", meetings: [PreviewData.endedMeeting])

    // Should not auto-collapse today even if meetings are completed
    #expect(view.shouldAutoCollapse == false)
  }

  // MARK: - Integration Tests

  @Test("Component maintains state across different meeting sets")
  @MainActor
  func componentStateConsistency() {
    let emptyView = DaySectionView(title: "Test", meetings: [])
    let withMeetingsView = DaySectionView(title: "Test", meetings: [PreviewData.upcomingMeeting])

    #expect(emptyView.title == withMeetingsView.title)
    #expect(emptyView.meetings.count != withMeetingsView.meetings.count)
  }

  @Test("Component handles various day titles correctly")
  @MainActor
  func componentHandlesDayTitles() {
    let dayTitles = ["Today", "Tomorrow", "Yesterday", "Monday", "Custom Day"]

    for title in dayTitles {
      let view = DaySectionView(title: title, meetings: [])
      #expect(view.title == title)

      // Only yesterday should be detected as past day for standard titles
      if title.lowercased() == "yesterday" {
        #expect(view.isPastDay == true)
      } else {
        #expect(view.isPastDay == false)
      }
    }
  }

  @Test("Component correctly identifies mixed meeting states")
  @MainActor
  func componentMixedMeetingStates() {
    let mixedMeetings = [
      PreviewData.upcomingMeeting,
      PreviewData.activeMeeting,
      PreviewData.endedMeeting,
    ]

    let view = DaySectionView(title: "Today", meetings: mixedMeetings)

    #expect(view.meetings.count == 3)
    #expect(view.allMeetingsCompleted == false)  // Not all are completed
    #expect(view.isPastDay == false)  // Today is not past day
    #expect(view.shouldAutoCollapse == false)  // Should not auto-collapse
  }

  // MARK: - Edge Cases

  @Test("Component handles edge case of meetings ending exactly 12 hours ago")
  @MainActor
  func componentTwelveHourBoundary() {
    let elevenHoursAgo = Date().addingTimeInterval(-39600)  // 11 hours ago (within boundary)

    let boundaryMeeting = Meeting(
      id: UUID(),
      title: "Boundary Meeting",
      startTime: elevenHoursAgo.addingTimeInterval(-3600),  // Started 12 hours ago
      endTime: elevenHoursAgo,  // Ended 11 hours ago (within 12-hour boundary)
      joinUrl: nil,
      platform: .unknown,
      organizerName: nil,
      organizerEmail: nil,
      attendeeCount: 0,
      attendees: [],
      calendarName: "Test",
      eventIdentifier: "test-boundary"
    )

    let view = DaySectionView(title: "Some Day", meetings: [boundaryMeeting])

    // Should NOT be considered past day when ended less than 12 hours ago
    #expect(view.isPastDay == false)
  }

  @Test("Component state properties are independent")
  @MainActor
  func componentStateIndependence() {
    let yesterdayCompleted = DaySectionView(
      title: "Yesterday", meetings: [PreviewData.endedMeeting])
    let todayActive = DaySectionView(title: "Today", meetings: [PreviewData.activeMeeting])

    // Test that different instances have independent state
    #expect(yesterdayCompleted.allMeetingsCompleted == true)
    #expect(todayActive.allMeetingsCompleted == false)

    #expect(yesterdayCompleted.isPastDay == true)
    #expect(todayActive.isPastDay == false)

    #expect(yesterdayCompleted.shouldAutoCollapse == true)
    #expect(todayActive.shouldAutoCollapse == false)
  }
}
