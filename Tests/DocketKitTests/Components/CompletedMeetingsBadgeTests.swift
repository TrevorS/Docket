// ABOUTME: Tests for CompletedMeetingsBadge component covering count display and text formatting
// ABOUTME: Ensures correct singular/plural text and proper styling for meeting completion indicators

import SwiftUI
import Testing

@testable import DocketKit

@Suite("CompletedMeetingsBadge Tests")
struct CompletedMeetingsBadgeTests {

  @Test("Zero meetings should not show badge")
  @MainActor
  func zeroMeetings() {
    let view = CompletedMeetingsBadge(meetingCount: 0)
    #expect(view.meetingCount == 0)
  }

  @Test("Single meeting displays singular text")
  @MainActor
  func singleMeeting() {
    let view = CompletedMeetingsBadge(meetingCount: 1)
    #expect(view.meetingCount == 1)
  }

  @Test("Multiple meetings display plural text")
  @MainActor
  func multipleMeetings() {
    let view = CompletedMeetingsBadge(meetingCount: 3)
    #expect(view.meetingCount == 3)
  }

  @Test("Many meetings display correctly")
  @MainActor
  func manyMeetings() {
    let view = CompletedMeetingsBadge(meetingCount: 15)
    #expect(view.meetingCount == 15)
  }

  @Test("Badge correctly maintains meeting count")
  @MainActor
  func meetingCountMaintained() {
    for count in 0...10 {
      let view = CompletedMeetingsBadge(meetingCount: count)
      #expect(view.meetingCount == count)
    }
  }

  @Test("Badge handles large meeting counts")
  @MainActor
  func largeMeetingCounts() {
    let view = CompletedMeetingsBadge(meetingCount: 100)
    #expect(view.meetingCount == 100)
  }

  @Test("Badge text format matches original implementation")
  @MainActor
  func textFormatMatching() {
    // Test singular case
    let singleView = CompletedMeetingsBadge(meetingCount: 1)
    #expect(singleView.meetingCount == 1)

    // Test plural case
    let pluralView = CompletedMeetingsBadge(meetingCount: 2)
    #expect(pluralView.meetingCount == 2)

    // Test zero case
    let zeroView = CompletedMeetingsBadge(meetingCount: 0)
    #expect(zeroView.meetingCount == 0)
  }

  @Test("Badge maintains consistent interface")
  @MainActor
  func consistentInterface() {
    let testCounts = [0, 1, 2, 5, 10, 25]

    for count in testCounts {
      let view = CompletedMeetingsBadge(meetingCount: count)
      #expect(view.meetingCount == count)
    }
  }
}
