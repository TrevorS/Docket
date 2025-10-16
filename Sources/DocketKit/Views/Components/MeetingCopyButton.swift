// ABOUTME: Simple copy button for meeting URLs with clipboard functionality
// ABOUTME: Copies URL to clipboard without animation complexity

import SwiftUI

struct MeetingCopyButton: View {
  let meetingUrl: String?
  let onCopy: (String) -> Void

  var body: some View {
    Button(action: performCopy) {
      Image(systemName: "doc.on.clipboard")
        .font(.caption)
        .foregroundStyle(Color.secondary)
    }
    .buttonStyle(.plain)
    .background(.clear)
    .help("Copy meeting link")
    .disabled(!canCopy)
  }

  private var canCopy: Bool {
    guard let url = meetingUrl else { return false }
    return !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func performCopy() {
    guard let url = meetingUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty else {
      return
    }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(url, forType: .string)

    onCopy(url)
  }
}

#Preview("Normal State") {
  VStack(spacing: 16) {
    MeetingCopyButton(
      meetingUrl: "https://zoom.us/j/123456789",
      onCopy: { url in
        // URL copied to clipboard
      }
    )
    .padding()
  }
}

#Preview("Disabled State") {
  VStack(spacing: 16) {
    MeetingCopyButton(
      meetingUrl: nil,
      onCopy: { url in
        // Preview callback
      }
    )
    .padding()

    MeetingCopyButton(
      meetingUrl: "   ",
      onCopy: { url in
        // Preview callback
      }
    )
    .padding()

    Text("Buttons above should be disabled (no URL or empty)")
      .font(.caption)
      .foregroundStyle(.secondary)
  }
}
