// ABOUTME: Individual meeting row component with time, status, and quick join functionality
// ABOUTME: Displays meeting information with visual status indicators and context-appropriate actions

import SwiftUI

struct MeetingRowView: View {
  let meeting: ZoomMeeting
  @State private var isJoining = false

  var body: some View {
    HStack(spacing: 12) {
      statusIndicator

      VStack(alignment: .leading, spacing: 4) {
        meetingTitle
        meetingTime
        meetingDetails
      }

      Spacer()

      if shouldShowJoinButton {
        joinButton
      }
    }
    .padding(.vertical, 8)
  }

  // MARK: - Status Indicator

  private var statusIndicator: some View {
    Circle()
      .fill(statusColor)
      .frame(width: 12, height: 12)
      .overlay {
        if meeting.isUpcoming {
          Circle()
            .stroke(statusColor.opacity(0.3), lineWidth: 8)
            .scaleEffect(isUpcoming ? 1.5 : 1.0)
            .opacity(isUpcoming ? 0 : 1)
            .animation(
              .easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: isUpcoming)
        }
      }
  }

  private var statusColor: Color {
    if meeting.hasEnded {
      return .secondary
    } else if meeting.hasStarted {
      return .green
    } else if meeting.isUpcoming {
      return .orange
    } else {
      return .secondary
    }
  }

  private var isUpcoming: Bool {
    meeting.isUpcoming
  }

  // MARK: - Meeting Information

  private var meetingTitle: some View {
    Text(meeting.title)
      .font(.headline)
      .foregroundStyle(meeting.hasEnded ? .secondary : .primary)
      .lineLimit(2)
  }

  private var meetingTime: some View {
    HStack(spacing: 4) {
      Image(systemName: "clock")
        .font(.caption)

      Text(timeRangeText)
        .font(.caption)

      if let duration = durationText {
        Text("•")
          .font(.caption)
        Text(duration)
          .font(.caption)
      }
    }
    .foregroundStyle(.secondary)
  }

  private var meetingDetails: some View {
    HStack(spacing: 12) {
      if !meeting.calendarName.isEmpty {
        Label {
          Text(meeting.calendarName)
        } icon: {
          Image(systemName: "calendar")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
      }

      if let organizer = meeting.organizerName, !organizer.isEmpty {
        Label {
          Text(organizer)
        } icon: {
          Image(systemName: "person")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
      }

      if meeting.attendeeCount > 0 {
        Label {
          Text("\(meeting.attendeeCount)")
        } icon: {
          Image(systemName: "person.2")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
      }
    }
  }

  // MARK: - Join Button

  private var shouldShowJoinButton: Bool {
    !meeting.hasEnded && !(meeting.joinUrl?.isEmpty ?? true)
  }

  private var joinButton: some View {
    Button(action: joinMeeting) {
      HStack(spacing: 4) {
        if isJoining {
          ProgressView()
            .scaleEffect(0.8)
        } else {
          Image(systemName: meeting.hasStarted ? "video.fill" : "video")
        }

        Text(joinButtonText)
          .font(.caption.weight(.semibold))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(joinButtonColor, in: RoundedRectangle(cornerRadius: 6))
      .foregroundColor(.white)
    }
    .disabled(isJoining)
    .buttonStyle(.plain)
  }

  private var joinButtonText: String {
    if isJoining {
      return "Joining..."
    } else if meeting.hasStarted {
      return "Join"
    } else {
      return "Preview"
    }
  }

  private var joinButtonColor: Color {
    if meeting.hasStarted {
      return .green
    } else {
      return .blue
    }
  }

  // MARK: - Helper Properties

  private var timeRangeText: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short

    let startTime = formatter.string(from: meeting.startTime)
    let endTime = formatter.string(from: meeting.endTime)

    return "\(startTime) - \(endTime)"
  }

  private var durationText: String? {
    let duration = meeting.endTime.timeIntervalSince(meeting.startTime)
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

  // MARK: - Actions

  private func joinMeeting() {
    guard let joinUrl = meeting.joinUrl, !joinUrl.isEmpty else { return }

    isJoining = true

    Task {
      defer {
        DispatchQueue.main.async {
          isJoining = false
        }
      }

      guard let url = URL(string: joinUrl) else {
        print("❌ Invalid meeting URL: \(joinUrl)")
        return
      }

      let success = await MainActor.run {
        NSWorkspace.shared.open(url)
      }

      if !success {
        print("❌ Failed to open meeting URL: \(joinUrl)")
      }
    }
  }
}

#Preview("Active Meeting") {
  List {
    MeetingRowView(meeting: PreviewData.activeMeeting)
  }
}

#Preview("Upcoming Meeting") {
  List {
    MeetingRowView(meeting: PreviewData.upcomingMeeting)
  }
}

#Preview("Ended Meeting") {
  List {
    MeetingRowView(meeting: PreviewData.endedMeeting)
  }
}

#Preview("Meeting Without URL") {
  List {
    MeetingRowView(meeting: PreviewData.meetingWithoutUrl)
  }
}

#Preview("Long Title Meeting") {
  List {
    MeetingRowView(meeting: PreviewData.longTitleMeeting)
  }
}

#Preview("Multiple States") {
  List {
    MeetingRowView(meeting: PreviewData.upcomingMeeting)
    MeetingRowView(meeting: PreviewData.activeMeeting)
    MeetingRowView(meeting: PreviewData.endedMeeting)
    MeetingRowView(meeting: PreviewData.longTitleMeeting)
    MeetingRowView(meeting: PreviewData.minimalMeeting)
  }
}
