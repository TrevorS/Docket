// ABOUTME: Individual meeting row component with time, status, and quick join functionality
// ABOUTME: Displays meeting information with visual status indicators and context-appropriate actions

import SwiftUI

struct MeetingRowView: View {
  let meeting: ZoomMeeting
  @State private var isJoining = false
  @State private var showCopyConfirmation = false
  @State private var isHovered = false

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 6) {
          meetingTitle
          meetingTime
          meetingDetails
        }

        Spacer()

        actionButtons
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 8)
      .onHover { isHovered = $0 }

      if showCopyConfirmation {
        copyConfirmationBanner
      }
    }
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
        .foregroundStyle(.secondary)

      Text(timeRangeText)
        .font(.subheadline.monospaced())
        .foregroundStyle(timeColor)

      if let duration = durationText {
        Text("•")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(duration)
          .font(.subheadline.monospaced())
          .foregroundStyle(timeColor)
      }
    }
  }

  private var meetingDetails: some View {
    VStack(alignment: .leading, spacing: 6) {
      // First row: Organizer and attendee count
      HStack(spacing: 12) {
        if let organizer = meeting.organizerName, !organizer.isEmpty {
          HStack(spacing: 4) {
            Image(systemName: "person.crop.circle")
              .font(.caption2)
              .foregroundStyle(.secondary)
            Text(organizer)
              .font(.caption2.monospaced())
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }

        if meeting.attendeeCount > 0 {
          HStack(spacing: 4) {
            Image(systemName: "person.2")
              .font(.caption2)
              .foregroundStyle(.secondary)
            Text(
              "\(meeting.attendeeCount) \(meeting.attendeeCount == 1 ? "person" : "people")"
            )
            .font(.caption2.monospaced())
            .foregroundStyle(.secondary)
          }
        }

        Spacer()
      }

    }
  }

  // MARK: - Action Buttons

  private var actionButtons: some View {
    HStack(spacing: 8) {
      if hasJoinUrl && isHovered {
        copyLinkButton
      }

      if shouldShowJoinButton {
        joinButton
      }
    }
  }

  private var shouldShowJoinButton: Bool {
    !meeting.hasEnded && hasJoinUrl
  }

  private var hasJoinUrl: Bool {
    !(meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
  }

  private var timeColor: Color {
    if meeting.hasEnded {
      return .secondary
    } else if meeting.hasStarted {
      return .green.opacity(0.8)
    } else if meeting.isUpcoming {
      return .orange.opacity(0.8)
    } else {
      return .blue.opacity(0.8)
    }
  }

  private var copyLinkButton: some View {
    Button(action: copyMeetingLink) {
      Image(systemName: "doc.on.clipboard")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .buttonStyle(.plain)
    .help("Copy meeting link")
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

  private var copyConfirmationBanner: some View {
    HStack {
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.green)
      Text("Meeting link copied")
        .font(.caption)
        .foregroundColor(.secondary)
      Spacer()
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 4)
    .background(Color.green.opacity(0.1))
    .transition(.opacity.combined(with: .move(edge: .top)))
  }

  private var joinButtonText: String {
    if isJoining {
      return "Joining..."
    } else {
      return "Join"
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

  private func copyMeetingLink() {
    guard let joinUrl = meeting.joinUrl, !joinUrl.isEmpty else { return }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(joinUrl, forType: .string)

    withAnimation(.easeInOut(duration: 0.3)) {
      showCopyConfirmation = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation(.easeInOut(duration: 0.3)) {
        showCopyConfirmation = false
      }
    }
  }

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
