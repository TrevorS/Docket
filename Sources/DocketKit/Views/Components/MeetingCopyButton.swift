// ABOUTME: Interactive copy button for meeting URLs with hover effects and clipboard functionality
// ABOUTME: Provides visual feedback on hover and triggers copy action via callback pattern

import SwiftUI

struct MeetingCopyButton: View {
  let meetingUrl: String?
  let onCopy: (String) -> Void

  @State private var isHovered = false
  @State private var showGlow = false

  var body: some View {
    Button(action: performCopy) {
      Image(systemName: "doc.on.clipboard")
        .font(.caption)
        .foregroundColor(isHovered ? .primary : .secondary)
        .symbolEffect(.bounce, options: .speed(2), value: showGlow)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    .buttonStyle(.plain)
    .help("Copy meeting link")
    .onHover { isHovered = $0 }
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

    // Trigger subtle pulse
    withAnimation(.easeInOut(duration: 0.1)) {
      showGlow = true
    }

    // Auto-hide quickly
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      withAnimation(.easeInOut(duration: 0.1)) {
        showGlow = false
      }
    }

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

#Preview("Hovered State") {
  VStack(spacing: 16) {
    MeetingCopyButton(
      meetingUrl: "https://meet.google.com/abc-def-ghi",
      onCopy: { url in
        // URL copied to clipboard
      }
    )
    .padding()
    Text("Hover over the copy button to see the effect")
      .font(.caption)
      .foregroundStyle(.secondary)
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
