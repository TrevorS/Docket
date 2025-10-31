// ABOUTME: Reusable day section component displaying meetings for a specific day
// ABOUTME: Shows either a list of meetings or an empty state message with consistent styling
// ABOUTME: Simplified header design - collapse/expand removed (now using status bar eye button)

import SwiftUI

/// A reusable section component for displaying a day's meetings
public struct DaySectionView: View {
  let title: String
  let meetings: [Meeting]

  public init(title: String, meetings: [Meeting]) {
    self.title = title
    self.meetings = meetings
  }

  public var body: some View {
    Section {
      if meetings.isEmpty {
        EmptyMeetingsDayView()
      } else {
        ForEach(meetings, id: \.id) { meeting in
          MeetingRowView(meeting: meeting)
            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .buttonStyle(.plain)
        }
      }
    } header: {
      sectionHeader
    }
    .listSectionSeparator(.hidden)
  }

  private var sectionHeader: some View {
    Text(title)
      .font(.headline.weight(.semibold))
      .foregroundColor(.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 12)
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
