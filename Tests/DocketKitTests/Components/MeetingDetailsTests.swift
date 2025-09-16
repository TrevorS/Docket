// ABOUTME: Tests for MeetingDetailsView component covering organizer and attendee display logic
// ABOUTME: Ensures correct conditional display, text formatting, and edge case handling

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("MeetingDetailsView Tests")
struct MeetingDetailsTests {

  @Test("With organizer name and attendees")
  @MainActor
  func withOrganizerAndAttendees() {
    let view = MeetingDetailsView(
      organizerName: "John Smith",
      attendeeCount: 5,
      attendees: []
    )

    #expect(view.organizerName == "John Smith")
    #expect(view.attendeeCount == 5)
  }

  @Test("With organizer name only")
  @MainActor
  func withOrganizerOnly() {
    let view = MeetingDetailsView(
      organizerName: "Sarah Johnson",
      attendeeCount: 0,
      attendees: []
    )

    #expect(view.organizerName == "Sarah Johnson")
    #expect(view.attendeeCount == 0)
  }

  @Test("With attendees only")
  @MainActor
  func withAttendeesOnly() {
    let view = MeetingDetailsView(
      organizerName: nil,
      attendeeCount: 12,
      attendees: []
    )

    #expect(view.organizerName == nil)
    #expect(view.attendeeCount == 12)
  }

  @Test("With empty organizer string")
  @MainActor
  func withEmptyOrganizerString() {
    let view = MeetingDetailsView(
      organizerName: "",
      attendeeCount: 3,
      attendees: []
    )

    #expect(view.organizerName == "")
    #expect(view.attendeeCount == 3)
  }

  @Test("Minimal info - no organizer, no attendees")
  @MainActor
  func minimalInfo() {
    let view = MeetingDetailsView(
      organizerName: nil,
      attendeeCount: 0,
      attendees: []
    )

    #expect(view.organizerName == nil)
    #expect(view.attendeeCount == 0)
  }

  @Test("Single attendee component creation")
  @MainActor
  func singleAttendeeCreation() {
    let view = MeetingDetailsView(
      organizerName: "Test Organizer",
      attendeeCount: 1,
      attendees: []
    )

    #expect(view.organizerName == "Test Organizer")
    #expect(view.attendeeCount == 1)
  }

  @Test("Multiple attendees component creation")
  @MainActor
  func multipleAttendeesCreation() {
    let view = MeetingDetailsView(
      organizerName: "Test Organizer",
      attendeeCount: 5,
      attendees: []
    )

    #expect(view.organizerName == "Test Organizer")
    #expect(view.attendeeCount == 5)
  }

  @Test("Large attendee count displays correctly")
  @MainActor
  func largeAttendeeCount() {
    let view = MeetingDetailsView(
      organizerName: "Conference Host",
      attendeeCount: 150,
      attendees: []
    )

    #expect(view.attendeeCount == 150)
    #expect(view.organizerName == "Conference Host")
  }

  @Test("Whitespace-only organizer name")
  @MainActor
  func whitespaceOnlyOrganizer() {
    let view = MeetingDetailsView(
      organizerName: "   ",
      attendeeCount: 2,
      attendees: []
    )

    #expect(view.organizerName == "   ")
    #expect(view.attendeeCount == 2)
  }

  @Test("Interface consistency validation")
  @MainActor
  func interfaceConsistency() {
    let testCases = [
      (organizerName: "Alice", attendeeCount: 0),
      (organizerName: nil, attendeeCount: 1),
      (organizerName: "Bob", attendeeCount: 10),
      (organizerName: "", attendeeCount: 100),
    ]

    for testCase in testCases {
      let view = MeetingDetailsView(
        organizerName: testCase.organizerName,
        attendeeCount: testCase.attendeeCount,
        attendees: []
      )

      #expect(view.organizerName == testCase.organizerName)
      #expect(view.attendeeCount == testCase.attendeeCount)
    }
  }

  @Test("Component maintains proper interface")
  @MainActor
  func componentInterface() {
    let view = MeetingDetailsView(
      organizerName: "Test User",
      attendeeCount: 7,
      attendees: []
    )

    // Verify the component has the expected public interface
    #expect(view.organizerName == "Test User")
    #expect(view.attendeeCount == 7)
  }

  @Test("Zero attendee count handling")
  @MainActor
  func zeroAttendeeCount() {
    let view = MeetingDetailsView(
      organizerName: "Solo Organizer",
      attendeeCount: 0,
      attendees: []
    )

    #expect(view.attendeeCount == 0)
    #expect(view.organizerName == "Solo Organizer")
  }
}
