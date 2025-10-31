// ABOUTME: Tests for DaySectionView component covering basic functionality
// ABOUTME: Simplified tests after removing collapse/expand (now handled by status bar eye button)

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

  // MARK: - Title Tests

  @Test("Component handles various day titles correctly")
  @MainActor
  func componentHandlesDayTitles() {
    let dayTitles = ["Today", "Tomorrow", "Yesterday", "Monday", "Custom Day"]

    for title in dayTitles {
      let view = DaySectionView(title: title, meetings: [])
      #expect(view.title == title)
    }
  }

  // MARK: - Meeting Content Tests

  @Test("Component maintains state across different meeting sets")
  @MainActor
  func componentStateConsistency() {
    let emptyView = DaySectionView(title: "Test", meetings: [])
    let withMeetingsView = DaySectionView(title: "Test", meetings: [PreviewData.upcomingMeeting])

    #expect(emptyView.title == withMeetingsView.title)
    #expect(emptyView.meetings.count != withMeetingsView.meetings.count)
  }

  @Test("Component correctly maintains mixed meeting states")
  @MainActor
  func componentMixedMeetingStates() {
    let mixedMeetings = [
      PreviewData.upcomingMeeting,
      PreviewData.activeMeeting,
      PreviewData.endedMeeting,
    ]

    let view = DaySectionView(title: "Today", meetings: mixedMeetings)

    #expect(view.meetings.count == 3)
    #expect(view.title == "Today")
  }

  @Test("Component state properties are independent")
  @MainActor
  func componentStateIndependence() {
    let yesterdayCompleted = DaySectionView(
      title: "Yesterday", meetings: [PreviewData.endedMeeting])
    let todayActive = DaySectionView(title: "Today", meetings: [PreviewData.activeMeeting])

    // Test that different instances have independent state
    #expect(yesterdayCompleted.title == "Yesterday")
    #expect(todayActive.title == "Today")
    #expect(yesterdayCompleted.meetings.count == 1)
    #expect(todayActive.meetings.count == 1)
  }
}
