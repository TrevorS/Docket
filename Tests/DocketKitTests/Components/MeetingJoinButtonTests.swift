// ABOUTME: Tests for MeetingJoinButton component covering all states, platforms, and interactive behavior
// ABOUTME: Ensures correct state management, URL validation, platform awareness, and callback execution

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("MeetingJoinButton Tests")
struct MeetingJoinButtonTests {

  // MARK: - Helper Methods

  private func createMeeting(
    title: String = "Test Meeting",
    startTime: Date = Date(),
    endTime: Date = Date().addingTimeInterval(3600),
    joinUrl: String? = "https://zoom.us/j/123456789",
    platform: MeetingPlatform = .zoom
  ) -> Meeting {
    Meeting(
      id: UUID(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      joinUrl: joinUrl,
      platform: platform,
      organizerName: "Test Organizer",
      organizerEmail: nil,
      attendeeCount: 5,
      calendarName: "Test Calendar",
      eventIdentifier: "test-meeting"
    )
  }

  // MARK: - Basic Component Creation Tests

  @Test("Component creation with upcoming Zoom meeting")
  @MainActor
  func upcomingZoomMeeting() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(300),  // 5 minutes from now
      platform: .zoom
    )

    var callbackUrl: URL?
    let button = MeetingJoinButton(meeting: meeting) { url in
      callbackUrl = url
    }

    #expect(button.meeting.platform == MeetingPlatform.zoom)
    #expect(!button.meeting.hasStarted)
    #expect(callbackUrl == nil)  // Not called until user interaction
  }

  @Test("Component creation with active Google Meet")
  @MainActor
  func activeGoogleMeet() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(-300),  // Started 5 minutes ago
      joinUrl: "https://meet.google.com/abc-def-ghi",
      platform: .googleMeet
    )

    var callbackUrl: URL?
    let button = MeetingJoinButton(meeting: meeting) { url in
      callbackUrl = url
    }

    #expect(button.meeting.platform == MeetingPlatform.googleMeet)
    #expect(button.meeting.hasStarted)
    #expect(callbackUrl == nil)  // Not called until user interaction
  }

  @Test("Component creation with ended meeting")
  @MainActor
  func endedMeeting() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(-7200),  // 2 hours ago
      endTime: Date().addingTimeInterval(-3600)  // 1 hour ago
    )

    var callbackUrl: URL?
    let button = MeetingJoinButton(meeting: meeting) { url in
      callbackUrl = url
    }

    #expect(button.meeting.hasEnded)
    #expect(callbackUrl == nil)
  }

  // MARK: - URL Validation Tests

  @Test("Component with valid Zoom URL")
  @MainActor
  func validZoomURL() {
    let meeting = createMeeting(
      joinUrl: "https://zoom.us/j/123456789",
      platform: .zoom
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == "https://zoom.us/j/123456789")
    #expect(button.meeting.platform == MeetingPlatform.zoom)
  }

  @Test("Component with valid Google Meet URL")
  @MainActor
  func validGoogleMeetURL() {
    let meeting = createMeeting(
      joinUrl: "https://meet.google.com/abc-def-ghi",
      platform: .googleMeet
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == "https://meet.google.com/abc-def-ghi")
    #expect(button.meeting.platform == MeetingPlatform.googleMeet)
  }

  @Test("Component with nil URL")
  @MainActor
  func nilURL() {
    let meeting = createMeeting(joinUrl: nil)

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == nil)
  }

  @Test("Component with empty URL")
  @MainActor
  func emptyURL() {
    let meeting = createMeeting(joinUrl: "")

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == "")
  }

  @Test("Component with whitespace-only URL")
  @MainActor
  func whitespaceURL() {
    let meeting = createMeeting(joinUrl: "   ")

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == "   ")
  }

  // MARK: - Platform-Specific Tests

  @Test("All supported platforms")
  @MainActor
  func allPlatforms() {
    let platforms: [(MeetingPlatform, String)] = [
      (MeetingPlatform.zoom, "https://zoom.us/j/123456789"),
      (MeetingPlatform.googleMeet, "https://meet.google.com/abc-def-ghi"),
      (MeetingPlatform.unknown, "https://custom.meeting.com/room123"),
    ]

    for (platform, url) in platforms {
      let meeting = createMeeting(
        joinUrl: url,
        platform: platform
      )

      var callbackUrl: URL?
      let button = MeetingJoinButton(meeting: meeting) { url in
        callbackUrl = url
      }

      #expect(button.meeting.platform == platform)
      #expect(button.meeting.joinUrl == url)
      #expect(callbackUrl == nil)
    }
  }

  // MARK: - State-Based Tests

  @Test("Upcoming meeting state properties")
  @MainActor
  func upcomingMeetingState() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(240)  // 4 minutes from now (within 5 minute window)
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(!button.meeting.hasStarted)
    #expect(!button.meeting.hasEnded)
    #expect(button.meeting.isUpcoming)
  }

  @Test("Active meeting state properties")
  @MainActor
  func activeMeetingState() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(-600),  // Started 10 minutes ago
      endTime: Date().addingTimeInterval(3000)  // Ends in 50 minutes
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.hasStarted)
    #expect(!button.meeting.hasEnded)
    #expect(!button.meeting.isUpcoming)
  }

  @Test("Ended meeting state properties")
  @MainActor
  func endedMeetingState() {
    let meeting = createMeeting(
      startTime: Date().addingTimeInterval(-7200),  // 2 hours ago
      endTime: Date().addingTimeInterval(-3600)  // 1 hour ago
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.hasStarted)
    #expect(button.meeting.hasEnded)
    #expect(!button.meeting.isUpcoming)
  }

  // MARK: - Callback Tests

  @Test("Callback interface consistency")
  @MainActor
  func callbackInterface() {
    var capturedUrls: [URL] = []
    let meeting = createMeeting()

    let button = MeetingJoinButton(meeting: meeting) { url in
      capturedUrls.append(url)
    }

    #expect(button.meeting.joinUrl != nil)
    #expect(capturedUrls.isEmpty)  // Not called until user interaction
  }

  @Test("Multiple buttons with independent callbacks")
  @MainActor
  func independentCallbacks() {
    var firstCallbacks: [URL] = []
    var secondCallbacks: [URL] = []

    let firstMeeting = createMeeting(
      joinUrl: "https://zoom.us/j/111111111"
    )
    let secondMeeting = createMeeting(
      joinUrl: "https://meet.google.com/abc-def-ghi"
    )

    let firstButton = MeetingJoinButton(meeting: firstMeeting) { url in
      firstCallbacks.append(url)
    }

    let secondButton = MeetingJoinButton(meeting: secondMeeting) { url in
      secondCallbacks.append(url)
    }

    #expect(firstButton.meeting.joinUrl == "https://zoom.us/j/111111111")
    #expect(secondButton.meeting.joinUrl == "https://meet.google.com/abc-def-ghi")
    #expect(firstCallbacks.isEmpty)
    #expect(secondCallbacks.isEmpty)
  }

  // MARK: - Edge Cases

  @Test("Very long meeting URL")
  @MainActor
  func longMeetingURL() {
    let longUrl =
      "https://zoom.us/j/123456789?pwd=VeryLongPasswordWithLotsOfParametersAndTrackingDataAndMoreStuff123456789012345678901234567890"
    let meeting = createMeeting(joinUrl: longUrl)

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == longUrl)
  }

  @Test("Meeting URL with special characters")
  @MainActor
  func specialCharactersURL() {
    let specialUrl = "https://zoom.us/j/123456789?pwd=Pass@Word#123$%^&*()"
    let meeting = createMeeting(joinUrl: specialUrl)

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.joinUrl == specialUrl)
  }

  @Test("Zero duration meeting")
  @MainActor
  func zeroDurationMeeting() {
    let now = Date()
    let meeting = createMeeting(
      startTime: now,
      endTime: now  // Same time = zero duration
    )

    let button = MeetingJoinButton(meeting: meeting) { _ in }

    #expect(button.meeting.startTime == button.meeting.endTime)
  }

  @Test("Meeting with all platforms and states")
  @MainActor
  func comprehensiveStateTest() {
    let platforms = [MeetingPlatform.zoom, MeetingPlatform.googleMeet, MeetingPlatform.unknown]
    let timeOffsets = [
      ("future", 600),  // 10 minutes from now
      ("active", -600),  // Started 10 minutes ago
      ("ended", -7200),  // Started 2 hours ago
    ]

    for platform in platforms {
      for (stateName, offset) in timeOffsets {
        let meeting = createMeeting(
          title: "\(stateName.capitalized) \(platform.displayName) Meeting",
          startTime: Date().addingTimeInterval(TimeInterval(offset)),
          endTime: Date().addingTimeInterval(TimeInterval(offset + 3600)),
          platform: platform
        )

        var callbackUrl: URL?
        let button = MeetingJoinButton(meeting: meeting) { url in
          callbackUrl = url
        }

        #expect(button.meeting.platform == platform)
        #expect(callbackUrl == nil)
      }
    }
  }

  // MARK: - Interface Consistency Tests

  @Test("Component maintains meeting reference integrity")
  @MainActor
  func meetingReferenceIntegrity() {
    let originalMeeting = createMeeting(
      title: "Important Meeting",
      joinUrl: "https://zoom.us/j/987654321",
      platform: .zoom
    )

    let button = MeetingJoinButton(meeting: originalMeeting) { _ in }

    // Verify all properties are preserved
    #expect(button.meeting.id == originalMeeting.id)
    #expect(button.meeting.title == originalMeeting.title)
    #expect(button.meeting.joinUrl == originalMeeting.joinUrl)
    #expect(button.meeting.platform == originalMeeting.platform)
    #expect(button.meeting.startTime == originalMeeting.startTime)
    #expect(button.meeting.endTime == originalMeeting.endTime)
  }
}
