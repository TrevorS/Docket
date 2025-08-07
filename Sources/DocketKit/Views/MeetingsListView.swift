// ABOUTME: Main list view that displays today's Zoom meetings with status indicators and actions
// ABOUTME: Consumes CalendarManager as @Observable data source with comprehensive state handling

import SwiftUI

struct MeetingsListView: View {
  @State private var calendarManager = CalendarManager()
  @State private var selectedMeeting: ZoomMeeting?
  @State private var isRequestingPermission = false

  init() {
    print("📱 MeetingsListView: Initializing...")
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
      .navigationTitle("This Week's Meetings")
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
      print("📱 MeetingsListView: .task triggered, requesting calendar access...")
      await requestCalendarAccessAndRefresh()
    }
    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification))
    { _ in
      print("📱 MeetingsListView: App became active, refreshing...")
      Task {
        await refreshAuthStateAndMeetings()
      }
    }
  }

  // MARK: - View Components

  private var permissionLoadingView: some View {
    ContentUnavailableView {
      Label("Requesting Calendar Access", systemImage: "calendar")
    } description: {
      Text("Please grant calendar access in the system dialog to view your meetings.")
    }
    .symbolEffect(.pulse, isActive: true)
  }

  private var loadingView: some View {
    ContentUnavailableView {
      Label("Loading Meetings", systemImage: "calendar.badge.clock")
    } description: {
      Text("Fetching today's meetings from your calendar...")
    }
    .symbolEffect(.pulse, isActive: true)
  }

  private var emptyStateView: some View {
    Group {
      switch calendarManager.authState {
      case .denied:
        ContentUnavailableView {
          Label("Calendar Access Denied", systemImage: "calendar")
        } description: {
          Text("Please grant calendar access in System Settings to see your Zoom meetings.")
        } actions: {
          Button("Open Settings") {
            openSystemSettings()
          }
          .buttonStyle(.borderedProminent)
        }

      case .restricted:
        ContentUnavailableView {
          Label("Calendar Access Restricted", systemImage: "calendar")
        } description: {
          Text("Calendar access is restricted by system policies.")
        }

      case let .error(message):
        ContentUnavailableView {
          Label("Error Loading Calendar", systemImage: "exclamationmark.triangle")
        } description: {
          Text(message)
        } actions: {
          Button("Try Again") {
            Task {
              try? await calendarManager.refreshMeetings()
            }
          }
          .buttonStyle(.borderedProminent)
        }

      case .fullAccess, .authorized:
        ContentUnavailableView {
          Label("No Zoom Meetings This Week", systemImage: "calendar")
        } description: {
          Text("You don't have any Zoom meetings scheduled for this week.")
        } actions: {
          Button("Refresh") {
            Task {
              try? await calendarManager.refreshMeetings()
            }
          }
          .buttonStyle(.bordered)
        }

      case .notDetermined, .writeOnly:
        ContentUnavailableView {
          Label("Calendar Access Required", systemImage: "calendar")
        } description: {
          Text("Grant calendar access to see your Zoom meetings.")
        } actions: {
          Button("Grant Access") {
            Task {
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
          }
          .disabled(isRequestingPermission)
          .buttonStyle(.borderedProminent)
        }
      }
    }
  }

  private var meetingsList: some View {
    List(calendarManager.meetings, selection: $selectedMeeting) { meeting in
      MeetingRowView(meeting: meeting)
        .listRowSeparator(.visible)
    }
    .refreshable {
      try? await calendarManager.refreshMeetings()
    }
    .overlay(alignment: .bottom) {
      if let lastRefresh = calendarManager.lastRefresh {
        refreshStatusView(lastRefresh: lastRefresh)
      }
    }
  }

  private func refreshStatusView(lastRefresh: Date) -> some View {
    HStack {
      Image(systemName: "clock")
        .foregroundStyle(.secondary)
      Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
        .font(.caption)
        .foregroundStyle(.secondary)

      if calendarManager.isRefreshing {
        Spacer()
        ProgressView()
          .scaleEffect(0.8)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    .padding()
  }

  // MARK: - Actions

  private func requestCalendarAccessAndRefresh() async {
    print("📱 MeetingsListView: Starting calendar access request...")
    isRequestingPermission = true
    defer {
      isRequestingPermission = false
      print("📱 MeetingsListView: Finished calendar access request")
    }

    let granted = await calendarManager.requestAccess()
    print(
      "📱 MeetingsListView: Access granted: \(granted), auth state: \(calendarManager.authState)")

    if granted
      && (calendarManager.authState == .fullAccess || calendarManager.authState == .authorized)
    {
      print("📱 MeetingsListView: Access granted, refreshing meetings...")
      try? await calendarManager.refreshMeetings()
    } else {
      print("📱 MeetingsListView: Access not granted or insufficient, skipping refresh")
    }
  }

  private func refreshMeetings() {
    guard !calendarManager.isRefreshing else {
      print("⏳ Refresh already in progress, skipping")
      return
    }

    Task {
      do {
        print("🔄 Manual refresh requested")
        try await calendarManager.refreshMeetings()
        print("✅ Manual refresh completed")
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

#Preview {
  MeetingsListView()
}
