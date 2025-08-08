// ABOUTME: Reusable day section component displaying meetings for a specific day
// ABOUTME: Shows either a list of meetings or an empty state message with consistent styling
// ABOUTME: Supports collapsing when all meetings are completed for better UX

import SwiftUI

/// A reusable section component for displaying a day's meetings
struct DaySectionView: View {
  let title: String
  let meetings: [ZoomMeeting]
  @State private var isExpanded: Bool = true

  private var allMeetingsCompleted: Bool {
    !meetings.isEmpty && meetings.allSatisfy { $0.hasEnded }
  }

  private var isPastDay: Bool {
    // Yesterday and any other past days should auto-collapse
    // Check if this is a past day by looking at the title or meeting dates
    if title.lowercased() == "yesterday" {
      return true
    }

    // Also check if all meetings are from a past day (more than 12 hours old)
    if !meetings.isEmpty {
      let twelveHoursAgo = Date().addingTimeInterval(-43200)  // 12 hours
      return meetings.allSatisfy { $0.endTime < twelveHoursAgo }
    }

    return false
  }

  private var shouldAutoCollapse: Bool {
    allMeetingsCompleted && isExpanded && (isPastDay || title.lowercased() == "yesterday")
  }

  var body: some View {
    Section {
      if meetings.isEmpty {
        EmptyMeetingsDayView()
      } else if allMeetingsCompleted && !isExpanded {
        collapsedDayView
      } else {
        ForEach(meetings) { meeting in
          MeetingRowView(meeting: meeting)
            .listRowSeparator(.visible)
            .buttonStyle(.plain)
        }
      }
    } header: {
      sectionHeader
    }
    .onAppear {
      if shouldAutoCollapse {
        // Auto-collapse past days on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          withAnimation(.easeInOut(duration: 0.5)) {
            isExpanded = false
          }
        }
      }
    }
    .onChange(of: allMeetingsCompleted) { _, completed in
      if completed && isExpanded && isPastDay {
        // Auto-collapse past days after a short delay when all meetings are done
        // Today's completed meetings require manual collapse for user awareness
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation(.easeInOut(duration: 0.5)) {
            isExpanded = false
          }
        }
      }
    }
  }

  private var sectionHeader: some View {
    Group {
      if allMeetingsCompleted {
        // Clickable header for completed days
        Button(action: toggleExpansion) {
          HStack {
            Text(title)
              .font(.headline.weight(.semibold))
              .foregroundColor(.primary)

            Spacer()

            completedBadge

            chevronIndicator
          }
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isExpanded ? "Collapse completed meetings" : "Expand completed meetings")
      } else {
        // Non-clickable header for active days
        HStack {
          Text(title)
            .font(.headline.weight(.semibold))
            .foregroundColor(.primary)

          Spacer()
        }
      }
    }
  }

  private var chevronIndicator: some View {
    Image(systemName: "chevron.down")
      .font(.caption.weight(.semibold))
      .foregroundColor(.secondary)
      .rotationEffect(.degrees(isExpanded ? 180 : 0))
      .animation(.easeInOut(duration: 0.2), value: isExpanded)
  }

  private func toggleExpansion() {
    withAnimation(.easeInOut(duration: 0.3)) {
      isExpanded.toggle()
    }
  }

  private var completedBadge: some View {
    HStack(spacing: 4) {
      Image(systemName: "checkmark.circle.fill")
        .font(.caption)
        .foregroundColor(.green)

      Text("Completed • \(meetings.count) \(meetings.count == 1 ? "meeting" : "meetings")")
        .font(.caption.weight(.medium))
        .foregroundColor(.secondary)
    }
  }

  private var collapsedDayView: some View {
    // Empty collapsed view since meeting count is now in header
    EmptyView()
  }
}

#Preview("With Meetings") {
  List {
    DaySectionView(title: "Today", meetings: PreviewData.todayMeetings)
  }
}

#Preview("Empty Day") {
  List {
    DaySectionView(title: "Yesterday", meetings: [])
  }
}

#Preview("Completed Day (Auto-Collapse)") {
  List {
    DaySectionView(title: "Yesterday", meetings: PreviewData.completedMeetings)
  }
}

#Preview("Multiple Days with Completed") {
  List {
    DaySectionView(title: "Yesterday", meetings: PreviewData.completedMeetings)
    DaySectionView(title: "Today", meetings: PreviewData.todayMeetings)
    DaySectionView(title: "Tomorrow", meetings: PreviewData.tomorrowMeetings)
  }
}
