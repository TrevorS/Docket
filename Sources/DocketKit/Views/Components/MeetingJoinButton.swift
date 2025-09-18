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
    // Use platform-specific color, but keep the meeting state logic
    let platformColor = meeting.platform.color

    // For active meetings, we could enhance the color or keep platform branding
    // For now, maintain platform consistency throughout meeting lifecycle
    return platformColor
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

#Preview {
  VStack(spacing: 16) {
    Text("MeetingJoinButton")
      .font(.headline)

    HStack(spacing: 16) {
      VStack {
        Text("Zoom")
          .font(.caption)
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "Team Standup",
            startTime: Date().addingTimeInterval(300),
            endTime: Date().addingTimeInterval(3900),
            joinUrl: "https://zoom.us/j/123456789",
            platform: .zoom,
            organizerName: "John Doe",
            organizerEmail: nil,
            attendeeCount: 5,
            calendarName: "Work",
            eventIdentifier: "zoom-example"
          ),
          onJoin: { _ in }
        )
      }

      VStack {
        Text("Google Meet")
          .font(.caption)
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "Design Review",
            startTime: Date().addingTimeInterval(600),
            endTime: Date().addingTimeInterval(4200),
            joinUrl: "https://meet.google.com/abc-def-ghi",
            platform: .googleMeet,
            organizerName: "Jane Smith",
            organizerEmail: nil,
            attendeeCount: 8,
            calendarName: "Work",
            eventIdentifier: "meet-example"
          ),
          onJoin: { _ in }
        )
      }

      VStack {
        Text("No URL")
          .font(.caption)
        MeetingJoinButton(
          meeting: Meeting(
            id: UUID(),
            title: "In-Person Meeting",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            joinUrl: nil,
            platform: .unknown,
            organizerName: nil,
            organizerEmail: nil,
            attendeeCount: 0,
            calendarName: "Calendar",
            eventIdentifier: "disabled-example"
          ),
          onJoin: { _ in }
        )
      }
    }
    .padding()

    Text("Platform-specific colors: Zoom (blue), Google Meet (green)")
      .font(.caption)
      .foregroundStyle(.secondary)
  }
}
