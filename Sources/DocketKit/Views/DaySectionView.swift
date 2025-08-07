// ABOUTME: Reusable day section component displaying meetings for a specific day
// ABOUTME: Shows either a list of meetings or an empty state message with consistent styling

import SwiftUI

/// A reusable section component for displaying a day's meetings
struct DaySectionView: View {
  let title: String
  let meetings: [ZoomMeeting]

  var body: some View {
    Section(title) {
      if meetings.isEmpty {
        EmptyMeetingsDayView()
      } else {
        ForEach(meetings) { meeting in
          MeetingRowView(meeting: meeting)
            .listRowSeparator(.visible)
            .buttonStyle(.plain)
        }
      }
    }
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

#Preview("Multiple Days") {
  List {
    DaySectionView(title: "Yesterday", meetings: PreviewData.yesterdayMeetings)
    DaySectionView(title: "Today", meetings: PreviewData.todayMeetings)
    DaySectionView(title: "Tomorrow", meetings: PreviewData.tomorrowMeetings)
  }
}
