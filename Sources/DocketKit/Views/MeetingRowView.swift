// ABOUTME: SwiftUI wrapper around AppKit MeetingRowView component
// ABOUTME: Bridges SwiftUI views to AppKit implementation during migration

import AppKit
import SwiftUI

/// SwiftUI view that wraps the AppKit MeetingRowView
public struct MeetingRowView: View {
  let meeting: Meeting
  let onJoin: ((URL) -> Void)?
  let onCopy: ((String) -> Void)?

  public init(meeting: Meeting, onJoin: ((URL) -> Void)? = nil, onCopy: ((String) -> Void)? = nil) {
    self.meeting = meeting
    self.onJoin = onJoin
    self.onCopy = onCopy
  }

  public var body: some View {
    MeetingRowViewRepresentable(
      meeting: meeting,
      onJoin: onJoin,
      onCopy: onCopy
    )
  }

  /// Check if the meeting has a valid join URL
  public var hasJoinUrl: Bool {
    !(meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
  }

  /// Check if the join button should be displayed
  public var shouldShowJoinButton: Bool {
    !meeting.hasEnded && hasJoinUrl
  }
}

/// NSViewRepresentable that bridges to the AppKit MeetingRowView
private struct MeetingRowViewRepresentable: NSViewRepresentable {
  let meeting: Meeting
  let onJoin: ((URL) -> Void)?
  let onCopy: ((String) -> Void)?

  func makeNSView(context: Context) -> MeetingRowViewImpl {
    let rowView = MeetingRowViewImpl(
      meeting: meeting,
      onJoin: { url in
        if let onJoin = self.onJoin {
          onJoin(url)
        } else {
          _ = NSWorkspace.shared.open(url)
        }
      },
      onCopy: { text in
        self.onCopy?(text)
      }
    )
    return rowView
  }

  func updateNSView(_ nsView: MeetingRowViewImpl, context: Context) {
    // Update as needed
  }
}

#Preview {
  MeetingRowView(meeting: PreviewData.todayMeetings[0])
    .frame(height: 160)
}
