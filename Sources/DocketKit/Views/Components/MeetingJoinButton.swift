// ABOUTME: Complex interactive join button with multi-state logic and platform-specific styling
// ABOUTME: Handles meeting states (upcoming/active/ended), hover effects, loading states, and async join operations

import SwiftUI

struct MeetingJoinButton: View {
  let meeting: Meeting
  let onJoin: (URL) -> Void

  @State private var isJoining = false
  @State private var isHovered = false

  var body: some View {
    Button(action: performJoin) {
      HStack(spacing: 4) {
        if isJoining {
          ProgressView()
            .scaleEffect(0.8)
        } else {
          Image(systemName: meeting.hasStarted ? "video.fill" : "video")
        }

        Text(buttonText)
          .font(.caption.weight(.semibold))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(backgroundColor, in: RoundedRectangle(cornerRadius: 6))
      .foregroundColor(.white)
      .scaleEffect(isHovered ? 1.05 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    .disabled(isJoining || shouldDisable)
    .buttonStyle(.plain)
    .help(tooltipText)
    .onHover { isHovered = $0 }
  }

  private var buttonText: String {
    if isJoining {
      return "Joining..."
    } else {
      return "Join"
    }
  }

  private var baseColor: Color {
    if meeting.hasStarted {
      return .green
    } else {
      return .blue
    }
  }

  private var backgroundColor: Color {
    let color = baseColor
    if isHovered {
      return color.opacity(0.9)
    } else {
      return color
    }
  }

  private var tooltipText: String {
    if shouldDisable {
      return "No meeting URL available"
    } else if meeting.hasStarted {
      return "Join active \(meeting.platform.displayName) meeting"
    } else {
      return "Join \(meeting.platform.displayName) meeting"
    }
  }

  private var shouldDisable: Bool {
    guard let joinUrl = meeting.joinUrl else { return true }
    return joinUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func performJoin() {
    guard let joinUrlString = meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
      !joinUrlString.isEmpty,
      let url = URL(string: joinUrlString)
    else {
      return
    }

    isJoining = true

    Task {
      defer {
        Task { @MainActor in
          isJoining = false
        }
      }

      await MainActor.run {
        onJoin(url)
      }
    }
  }
}

#Preview("Upcoming Zoom Meeting") {
  VStack(spacing: 16) {
    MeetingJoinButton(
      meeting: Meeting(
        id: UUID(),
        title: "Upcoming Zoom Call",
        startTime: Date().addingTimeInterval(300),  // 5 minutes from now
        endTime: Date().addingTimeInterval(3900),  // 65 minutes from now
        joinUrl: "https://zoom.us/j/123456789",
        platform: .zoom,
        organizerName: "John Doe",
        organizerEmail: nil,
        attendeeCount: 5,
        calendarName: "Work",
        eventIdentifier: "test-upcoming"
      ),
      onJoin: { url in
        print("Joining: \(url)")
      }
    )
    .padding()
  }
}

#Preview("Active Google Meet") {
  VStack(spacing: 16) {
    MeetingJoinButton(
      meeting: Meeting(
        id: UUID(),
        title: "Active Google Meet",
        startTime: Date().addingTimeInterval(-300),  // Started 5 minutes ago
        endTime: Date().addingTimeInterval(3300),  // Ends in 55 minutes
        joinUrl: "https://meet.google.com/abc-def-ghi",
        platform: .googleMeet,
        organizerName: "Jane Smith",
        organizerEmail: nil,
        attendeeCount: 12,
        calendarName: "Work",
        eventIdentifier: "test-active"
      ),
      onJoin: { url in
        print("Joining active meeting: \(url)")
      }
    )
    .padding()
  }
}

#Preview("No URL Available") {
  VStack(spacing: 16) {
    MeetingJoinButton(
      meeting: Meeting(
        id: UUID(),
        title: "Meeting Without URL",
        startTime: Date().addingTimeInterval(600),
        endTime: Date().addingTimeInterval(4200),
        joinUrl: nil,
        platform: .unknown,
        organizerName: nil,
        organizerEmail: nil,
        attendeeCount: 0,
        calendarName: "Calendar",
        eventIdentifier: "test-no-url"
      ),
      onJoin: { url in
        print("This should not be called")
      }
    )
    .padding()

    Text("Button above should be disabled (no URL)")
      .font(.caption)
      .foregroundStyle(.secondary)
  }
}

#Preview("All States") {
  VStack(spacing: 12) {
    Text("Different Meeting States")
      .font(.headline)

    HStack(spacing: 12) {
      VStack {
        Text("Upcoming")
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "Future Meeting",
            startTime: Date().addingTimeInterval(600),
            endTime: Date().addingTimeInterval(4200),
            joinUrl: "https://zoom.us/j/111111111",
            platform: .zoom,
            organizerName: nil,
            organizerEmail: nil,
            attendeeCount: 3,
            calendarName: "Work",
            eventIdentifier: "test-future"
          ),
          onJoin: { _ in }
        )
      }

      VStack {
        Text("Active")
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "Current Meeting",
            startTime: Date().addingTimeInterval(-600),
            endTime: Date().addingTimeInterval(3000),
            joinUrl: "https://meet.google.com/xyz-abc-def",
            platform: .googleMeet,
            organizerName: nil,
            organizerEmail: nil,
            attendeeCount: 8,
            calendarName: "Work",
            eventIdentifier: "test-current"
          ),
          onJoin: { _ in }
        )
      }

      VStack {
        Text("Disabled")
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "No URL",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            joinUrl: "",
            platform: .unknown,
            organizerName: nil,
            organizerEmail: nil,
            attendeeCount: 0,
            calendarName: "Work",
            eventIdentifier: "test-disabled"
          ),
          onJoin: { _ in }
        )
      }
    }
    .padding()
  }
}
