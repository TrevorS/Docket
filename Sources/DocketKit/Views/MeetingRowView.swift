// ABOUTME: Individual meeting row component with time, status, and quick join functionality
// ABOUTME: Displays meeting information with visual status indicators and context-appropriate actions

import SwiftUI

struct MeetingRowView: View {
  let meeting: Meeting
  @State private var isJoining = false
  @State private var showCopyConfirmation = false
  @State private var isHovered = false
  @State private var isCopyButtonHovered = false
  @State private var isJoinButtonHovered = false

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
      .lineLimit(1)
      .truncationMode(.tail)
  }

  private var meetingTime: some View {
    MeetingTimeView(meeting: meeting)
  }

  private var meetingDetails: some View {
    VStack(alignment: .leading, spacing: 6) {
      // First row: Platform indicator, organizer and attendee count
      HStack(spacing: 12) {
        // Platform indicator
        PlatformIndicatorView(platform: meeting.platform)

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
      if hasJoinUrl {
        copyLinkButton
          .opacity(isHovered ? 1.0 : 0.0)
          .animation(.easeInOut(duration: 0.2), value: isHovered)
      }

      if shouldShowJoinButton {
        joinButton
      }
    }
    .frame(minWidth: 80, alignment: .trailing)  // Reserve consistent space to prevent layout shifts
  }

  private var shouldShowJoinButton: Bool {
    !meeting.hasEnded && hasJoinUrl
  }

  private var hasJoinUrl: Bool {
    !(meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
  }

  private var copyLinkButton: some View {
    Button(action: copyMeetingLink) {
      Image(systemName: "doc.on.clipboard")
        .font(.caption)
        .foregroundColor(isCopyButtonHovered ? .primary : .secondary)
        .scaleEffect(isCopyButtonHovered ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isCopyButtonHovered)
    }
    .buttonStyle(.plain)
    .help("Copy meeting link")
    .onHover { isCopyButtonHovered = $0 }
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
      .background(joinButtonBackgroundColor, in: RoundedRectangle(cornerRadius: 6))
      .foregroundColor(.white)
      .scaleEffect(isJoinButtonHovered ? 1.05 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: isJoinButtonHovered)
    }
    .disabled(isJoining)
    .buttonStyle(.plain)
    .help(joinButtonTooltip)
    .onHover { isJoinButtonHovered = $0 }
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

  private var joinButtonBackgroundColor: Color {
    let baseColor = joinButtonColor
    if isJoinButtonHovered {
      return baseColor.opacity(0.9)
    } else {
      return baseColor
    }
  }

  private var joinButtonTooltip: String {
    if meeting.hasStarted {
      return "Join active \(meeting.platform.displayName) meeting"
    } else {
      return "Join \(meeting.platform.displayName) meeting"
    }
  }

  // MARK: - Helper Properties

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
