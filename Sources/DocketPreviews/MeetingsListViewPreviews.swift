// ABOUTME: Preview definitions for MeetingsListView in a separate framework to avoid executable target constraints
// ABOUTME: This allows SwiftUI previews to work without ENABLE_DEBUG_DYLIB requirements

import DocketKit
import SwiftUI

#Preview("With Meetings") {
  MeetingsListView()
    .environment(AppModel())
}

#Preview("With Mock Data") {
  struct MockMeetingsListView: View {
    @State private var mockCalendarManager = PreviewData.MockCalendarManager()

    var body: some View {
      NavigationStack {
        List {
          DaySectionView(title: "Yesterday", meetings: mockCalendarManager.yesterdayMeetings)
          DaySectionView(title: "Today", meetings: mockCalendarManager.todayMeetings)
          DaySectionView(title: "Tomorrow", meetings: mockCalendarManager.tomorrowMeetings)
        }
        .refreshable {
          // Mock implementation
        }
        .navigationTitle("Docket")
      }
    }
  }

  return MockMeetingsListView()
}

#Preview("Loading State") {
  NavigationStack {
    LoadingStateView(message: "Loading Meetings")
      .navigationTitle("Docket")
  }
}

#Preview("Empty State - No Access") {
  NavigationStack {
    EmptyStateView(
      authState: .notDetermined,
      onRetry: {},
      onGrantAccess: {},
      onOpenSettings: {}
    )
    .navigationTitle("Meetings")
  }
}

#Preview("Calendar Access Denied") {
  NavigationStack {
    EmptyStateView(
      authState: .denied,
      onRetry: { print("Retry tapped") },
      onGrantAccess: { print("Grant access tapped") },
      onOpenSettings: { print("Open settings tapped") }
    )
    .navigationTitle("Docket")
  }
}

#Preview("Calendar Error State") {
  NavigationStack {
    EmptyStateView(
      authState: .error(
        "Failed to connect to calendar service. Please check your calendar settings."),
      onRetry: { print("Retry tapped") },
      onGrantAccess: { print("Grant access tapped") },
      onOpenSettings: { print("Open settings tapped") }
    )
    .navigationTitle("Docket")
  }
}

#Preview("Dark Mode with Meetings") {
  @Previewable @State var mockCalendarManager = PreviewData.MockCalendarManager()

  NavigationStack {
    List {
      DaySectionView(title: "Today", meetings: mockCalendarManager.todayMeetings)
      DaySectionView(title: "Tomorrow", meetings: mockCalendarManager.tomorrowMeetings)
    }
    .navigationTitle("Docket")
    .listStyle(.plain)
  }
  .preferredColorScheme(.dark)
}

#Preview("Interactive Calendar States") {
  @Previewable @State var selectedState = 0
  let states = [
    ("Authorized", CalendarAuthState.authorized),
    ("Full Access", CalendarAuthState.fullAccess),
    ("Not Determined", CalendarAuthState.notDetermined),
    ("Denied", CalendarAuthState.denied),
    ("Write Only", CalendarAuthState.writeOnly),
    ("Restricted", CalendarAuthState.restricted),
    ("Error", CalendarAuthState.error("Connection failed")),
  ]

  VStack {
    Picker("Calendar State", selection: $selectedState) {
      ForEach(0..<states.count, id: \.self) { index in
        Text(states[index].0).tag(index)
      }
    }
    .pickerStyle(.segmented)
    .padding()

    Divider()

    Group {
      if states[selectedState].1 == .fullAccess || states[selectedState].1 == .authorized {
        // Show meetings list for full access
        NavigationStack {
          List {
            DaySectionView(title: "Today", meetings: PreviewData.todayMeetings)
          }
          .navigationTitle("Docket")
          .listStyle(.plain)
        }
      } else {
        // Show empty state for other auth states
        EmptyStateView(
          authState: states[selectedState].1,
          onRetry: { print("Retry: \(states[selectedState].0)") },
          onGrantAccess: { print("Grant access: \(states[selectedState].0)") },
          onOpenSettings: { print("Open settings: \(states[selectedState].0)") }
        )
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview("Hide Completed Feature - Enabled") {
  struct HideCompletedDemo: View {
    @State private var appModel = AppModel()

    var body: some View {
      // Create meetings: some active, some completed >5min ago, some completed <5min ago
      let recentlyEndedMeeting = Meeting(
        id: UUID(),
        title: "Just Ended (3 min ago)",
        startTime: Date().addingTimeInterval(-1800),
        endTime: Date().addingTimeInterval(-180),
        joinUrl: "https://zoom.us/j/recent123",
        platform: .zoom,
        organizerName: "Team Lead",
        organizerEmail: "lead@company.com",
        attendeeCount: 5,
        attendees: [],
        calendarName: "Work Calendar",
        eventIdentifier: "preview-recent-ended"
      )

      let oldEndedMeeting = Meeting(
        id: UUID(),
        title: "Ended Long Ago (10 min ago) - HIDDEN",
        startTime: Date().addingTimeInterval(-3600),
        endTime: Date().addingTimeInterval(-600),
        joinUrl: "https://zoom.us/j/old123",
        platform: .zoom,
        organizerName: "Manager",
        organizerEmail: "manager@company.com",
        attendeeCount: 3,
        attendees: [],
        calendarName: "Work Calendar",
        eventIdentifier: "preview-old-ended"
      )

      NavigationStack {
        List {
          DaySectionView(
            title: "Today",
            meetings: [
              oldEndedMeeting,
              recentlyEndedMeeting,
              PreviewData.activeMeeting,
              PreviewData.upcomingMeeting,
            ].filter {
              !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
            }
          )
        }
        .navigationTitle("Docket")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            HStack(spacing: 8) {
              HideCompletedButton(
                isHiding: Binding(
                  get: { appModel.hideCompletedMeetingsAfter5Min },
                  set: { appModel.hideCompletedMeetingsAfter5Min = $0 }
                ))
              PinButton(isPinned: .constant(false))
            }
          }
        }
      }
      .environment(appModel)
      .frame(width: 600, height: 500)
    }
  }

  return HideCompletedDemo()
}

#Preview("Hide Completed Feature - Interactive") {
  struct InteractiveHidingDemo: View {
    @State private var appModel = AppModel()

    var body: some View {
      // Create meetings with various end times
      let justEnded = Meeting(
        id: UUID(),
        title: "Just Ended (1 min ago)",
        startTime: Date().addingTimeInterval(-1800),
        endTime: Date().addingTimeInterval(-60),
        joinUrl: "https://zoom.us/j/just123",
        platform: .zoom,
        organizerName: "Team",
        organizerEmail: "team@company.com",
        attendeeCount: 4,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "just-ended"
      )

      let ended6MinAgo = Meeting(
        id: UUID(),
        title: "Ended 6 Min Ago",
        startTime: Date().addingTimeInterval(-2160),
        endTime: Date().addingTimeInterval(-360),
        joinUrl: "https://zoom.us/j/six123",
        platform: .googleMeet,
        organizerName: "Lead",
        organizerEmail: "lead@company.com",
        attendeeCount: 8,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "ended-6-min"
      )

      let ended15MinAgo = Meeting(
        id: UUID(),
        title: "Ended 15 Min Ago",
        startTime: Date().addingTimeInterval(-3600),
        endTime: Date().addingTimeInterval(-900),
        joinUrl: "https://zoom.us/j/fifteen123",
        platform: .zoom,
        organizerName: "Manager",
        organizerEmail: "mgr@company.com",
        attendeeCount: 12,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "ended-15-min"
      )

      let allMeetings = [justEnded, ended6MinAgo, ended15MinAgo, PreviewData.activeMeeting]
      let visibleCount = allMeetings.filter {
        !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
      }.count

      VStack(spacing: 0) {
        // Status bar showing what's hidden
        HStack {
          Text("Hiding: ")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(appModel.hideCompletedMeetingsAfter5Min ? "ON" : "OFF")
            .font(.caption.bold())
            .foregroundStyle(appModel.hideCompletedMeetingsAfter5Min ? .green : .orange)

          Spacer()

          Text("Shown: ")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(visibleCount) of 4")
            .font(.caption.bold())
            .foregroundStyle(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))

        NavigationStack {
          List {
            DaySectionView(
              title: "Today",
              meetings: allMeetings.filter {
                !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
              }
            )
          }
          .navigationTitle("Docket")
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              HStack(spacing: 8) {
                HideCompletedButton(
                  isHiding: Binding(
                    get: { appModel.hideCompletedMeetingsAfter5Min },
                    set: { appModel.hideCompletedMeetingsAfter5Min = $0 }
                  ))
                PinButton(isPinned: .constant(false))
              }
            }
          }
        }
      }
      .environment(appModel)
      .frame(width: 600, height: 550)
    }
  }

  return InteractiveHidingDemo()
}

#Preview("Section Hiding - Yesterday/Tomorrow Hidden") {
  struct SectionHidingDemo: View {
    @State private var appModel = AppModel()

    var body: some View {
      // Yesterday meetings - all ended >5 min ago (will be hidden)
      let yesterdayOld1 = Meeting(
        id: UUID(),
        title: "Yesterday Meeting 1",
        startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
          .addingTimeInterval(32400),
        endTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(
          36000),
        joinUrl: "https://zoom.us/j/yesterday1",
        platform: .zoom,
        organizerName: "Team",
        organizerEmail: "team@company.com",
        attendeeCount: 5,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "yesterday-1"
      )

      let yesterdayOld2 = Meeting(
        id: UUID(),
        title: "Yesterday Meeting 2",
        startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
          .addingTimeInterval(39600),
        endTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(
          43200),
        joinUrl: "https://zoom.us/j/yesterday2",
        platform: .googleMeet,
        organizerName: "Manager",
        organizerEmail: "manager@company.com",
        attendeeCount: 3,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "yesterday-2"
      )

      // Tomorrow meetings - not ended yet (will show)
      let tomorrowFuture = Meeting(
        id: UUID(),
        title: "Tomorrow Meeting",
        startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
          .addingTimeInterval(32400),
        endTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.addingTimeInterval(
          36000),
        joinUrl: "https://zoom.us/j/tomorrow1",
        platform: .zoom,
        organizerName: "Lead",
        organizerEmail: "lead@company.com",
        attendeeCount: 8,
        attendees: [],
        calendarName: "Work",
        eventIdentifier: "tomorrow-1"
      )

      let yesterdayFiltered = [yesterdayOld1, yesterdayOld2].filter {
        !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
      }

      let tomorrowFiltered = [tomorrowFuture].filter {
        !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
      }

      VStack(spacing: 0) {
        // Status indicator
        HStack {
          Image(systemName: appModel.hideCompletedMeetingsAfter5Min ? "eye.slash" : "eye")
            .foregroundColor(appModel.hideCompletedMeetingsAfter5Min ? .secondary : .blue)
          Text(
            appModel.hideCompletedMeetingsAfter5Min
              ? "Yesterday section hidden (all meetings >5min old)" : "All sections visible"
          )
          .font(.caption)
          .foregroundStyle(.secondary)

          Spacer()

          Text(
            "Sections: \(yesterdayFiltered.isEmpty ? 0 : 1) + 1 + \(tomorrowFiltered.isEmpty ? 0 : 1)"
          )
          .font(.caption.bold())
          .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))

        NavigationStack {
          List {
            if !yesterdayFiltered.isEmpty {
              DaySectionView(title: "Yesterday", meetings: yesterdayFiltered)
            }
            DaySectionView(title: "Today", meetings: [PreviewData.activeMeeting])
            if !tomorrowFiltered.isEmpty {
              DaySectionView(title: "Tomorrow", meetings: tomorrowFiltered)
            }
          }
          .navigationTitle("Docket")
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              HStack(spacing: 8) {
                HideCompletedButton(
                  isHiding: Binding(
                    get: { appModel.hideCompletedMeetingsAfter5Min },
                    set: { appModel.hideCompletedMeetingsAfter5Min = $0 }
                  ))
                PinButton(isPinned: .constant(false))
              }
            }
          }
        }
      }
      .environment(appModel)
      .frame(width: 650, height: 550)
    }
  }

  return SectionHidingDemo()
}
