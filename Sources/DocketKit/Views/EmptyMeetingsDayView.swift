// ABOUTME: Empty state component for days without meetings
// ABOUTME: Displays a subtle "No meetings" message with consistent styling across day sections

import SwiftUI

/// Empty state view for days with no meetings
struct EmptyMeetingsDayView: View {
  var body: some View {
    Text("No meetings")
      .foregroundStyle(.secondary)
      .font(.callout)
  }
}

#Preview("Empty Day State") {
  List {
    Section("Today") {
      EmptyMeetingsDayView()
    }
    Section("Tomorrow") {
      EmptyMeetingsDayView()
    }
  }
}
