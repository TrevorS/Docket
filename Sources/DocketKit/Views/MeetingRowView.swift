// ABOUTME: Individual meeting row component with time, status, and quick join functionality
// ABOUTME: Displays meeting information with visual status indicators and context-appropriate actions

import SwiftUI

struct MeetingRowView: View {
  let meeting: Meeting
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

      CopyConfirmationBanner(isVisible: $showCopyConfirmation)
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

        MeetingDetailsView(
          organizerName: meeting.organizerName,
          attendeeCount: meeting.attendeeCount
        )
      }

    }
  }

  // MARK: - Action Buttons

  private var actionButtons: some View {
    HStack(spacing: 8) {
      if hasJoinUrl {
        MeetingCopyButton(
          meetingUrl: meeting.joinUrl,
          onCopy: handleCopyAction
        )
        .opacity(isHovered ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
      }

      if shouldShowJoinButton {
        MeetingJoinButton(
          meeting: meeting,
          onJoin: handleJoinAction
        )
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

  // MARK: - Helper Properties

  // MARK: - Actions

  private func handleCopyAction(_ url: String) {
    withAnimation(.easeInOut(duration: 0.3)) {
      showCopyConfirmation = true
    }
  }

  private func handleJoinAction(_ url: URL) {
    let success = NSWorkspace.shared.open(url)
    if !success {
      print("❌ Failed to open meeting URL: \(url)")
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
