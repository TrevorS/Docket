// ABOUTME: Displays completed meetings badge with checkmark icon and meeting count
// ABOUTME: Shows proper singular/plural text formatting and green checkmark styling

import SwiftUI

/// A view that displays a badge indicating completed meetings count
struct CompletedMeetingsBadge: View {
  let meetingCount: Int

  var body: some View {
    if meetingCount > 0 {
      HStack(spacing: 4) {
        Image(systemName: "checkmark.circle.fill")
          .font(.caption)
          .foregroundColor(.green)

        Text("Completed • \(meetingCount) \(meetingCount == 1 ? "meeting" : "meetings")")
          .font(.caption.weight(.medium))
          .foregroundColor(.secondary)
      }
    } else {
      EmptyView()
    }
  }
}

#Preview("Single Meeting") {
  CompletedMeetingsBadge(meetingCount: 1)
    .padding()
}

#Preview("Multiple Meetings") {
  CompletedMeetingsBadge(meetingCount: 5)
    .padding()
}

#Preview("Many Meetings (10+)") {
  CompletedMeetingsBadge(meetingCount: 12)
    .padding()
}

#Preview("Zero Meetings") {
  CompletedMeetingsBadge(meetingCount: 0)
    .frame(minWidth: 100, minHeight: 20)  // Give it visible size for preview
    .background(Color.gray.opacity(0.1))  // Make empty space visible in preview
    .overlay(
      Text("EmptyView()").font(.caption).foregroundColor(.secondary)
    )
    .padding()
}

#Preview("All Count Variations") {
  VStack(alignment: .leading, spacing: 8) {
    CompletedMeetingsBadge(meetingCount: 0)
    CompletedMeetingsBadge(meetingCount: 1)
    CompletedMeetingsBadge(meetingCount: 2)
    CompletedMeetingsBadge(meetingCount: 5)
    CompletedMeetingsBadge(meetingCount: 10)
    CompletedMeetingsBadge(meetingCount: 25)
  }
  .padding()
}
