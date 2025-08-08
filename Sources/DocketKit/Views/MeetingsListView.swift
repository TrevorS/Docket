// ABOUTME: Main meetings list view using modern SwiftUI component architecture
// ABOUTME: Orchestrates day sections, loading states, and calendar permission handling

import SwiftUI

struct MeetingsListView: View {
  @State private var calendarManager = CalendarManager()
  @State private var isRequestingPermission = false

  init() {
  }

  var body: some View {
    NavigationStack {
      Group {
        if isRequestingPermission {
          permissionLoadingView
        } else if calendarManager.isRefreshing && calendarManager.meetings.isEmpty {
          loadingView
        } else if calendarManager.meetings.isEmpty {
          emptyStateView
        } else {
          meetingsList
        }
      }
      .navigationTitle("Docket")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: refreshMeetings) {
            Image(systemName: "arrow.clockwise")
          }
          .disabled(calendarManager.isRefreshing || isRequestingPermission)
        }
      }
    }
    .task {
      await requestCalendarAccessAndRefresh()
    }
  }

  // MARK: - View Components

  private var permissionLoadingView: some View {
    LoadingStateView(
      message: "Requesting Calendar Access",
      systemImage: "calendar"
    )
  }

  private var loadingView: some View {
    LoadingStateView(message: "Loading Meetings")
  }

  private var emptyStateView: some View {
    EmptyStateView(
      authState: calendarManager.authState,
      onRetry: {
        Task {
          try? await calendarManager.refreshMeetings()
        }
      },
      onGrantAccess: {
        await handleGrantAccess()
      },
      onOpenSettings: openSystemSettings
    )
  }

  private var meetingsList: some View {
    List {
      DaySectionView(title: "Yesterday", meetings: calendarManager.yesterdayMeetings)
      DaySectionView(title: "Today", meetings: calendarManager.todayMeetings)
      DaySectionView(title: "Tomorrow", meetings: calendarManager.tomorrowMeetings)
    }
    .refreshable {
      try? await calendarManager.refreshMeetings()
    }
    .overlay(alignment: .bottom) {
      RefreshStatusView(
        lastRefresh: calendarManager.lastRefresh,
        isRefreshing: calendarManager.isRefreshing
      )
    }
  }

  // MARK: - Actions

  private func handleGrantAccess() async {
    isRequestingPermission = true
    defer { isRequestingPermission = false }

    let granted = await calendarManager.requestAccess()
    if granted
      && (calendarManager.authState == .fullAccess
        || calendarManager.authState == .authorized)
    {
      try? await calendarManager.refreshMeetings()
    }
  }

  private func requestCalendarAccessAndRefresh() async {
    isRequestingPermission = true
    defer {
      isRequestingPermission = false
    }

    let granted = await calendarManager.requestAccess()

    if granted
      && (calendarManager.authState == .fullAccess || calendarManager.authState == .authorized)
    {
      try? await calendarManager.refreshMeetings()
    }
  }

  private func refreshMeetings() {
    guard !calendarManager.isRefreshing else {
      return
    }

    Task {
      do {
        try await calendarManager.refreshMeetings()
      } catch {
        print("❌ Manual refresh failed: \(error)")
      }
    }
  }

  private func refreshAuthStateAndMeetings() async {
    // Update auth state to reflect any changes made in System Settings
    calendarManager.updateAuthState()

    // If we have permission, refresh meetings
    if calendarManager.authState == .fullAccess || calendarManager.authState == .authorized {
      try? await calendarManager.refreshMeetings()
    }
  }

  private func openSystemSettings() {
    if let settingsURL = URL(
      string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")
    {
      NSWorkspace.shared.open(settingsURL)
    }
  }
}

#Preview("With Meetings") {
  MeetingsListView()
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
        .overlay(alignment: .bottom) {
          RefreshStatusView(
            lastRefresh: mockCalendarManager.lastRefresh,
            isRefreshing: mockCalendarManager.isRefreshing
          )
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
