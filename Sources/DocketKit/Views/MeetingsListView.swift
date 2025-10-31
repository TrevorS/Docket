// ABOUTME: Main meetings list view using modern SwiftUI component architecture
// ABOUTME: Orchestrates day sections, loading states, and calendar permission handling
// ABOUTME: Content layer uses standard materials (List) below Liquid Glass functional layer (StatusBar, Toolbar)

import SwiftUI

public struct MeetingsListView: View {
  @Environment(AppModel.self) private var appModel
  @State private var calendarManager = CalendarManager()
  @State private var isRequestingPermission = false

  public init() {
  }

  public var body: some View {
    // DEPRECATED: This view is no longer used. The app now uses AppKit via MeetingsListViewController.
    // Kept as reference for SwiftUI patterns. Replaced by AppKit components in Week 3 migration.
    Text("MeetingsListView deprecated - using AppKit")
      .task {
        await requestCalendarAccessAndRefresh()
      }
  }

  // MARK: - Computed Properties

  private var filteredYesterdayMeetings: [Meeting] {
    calendarManager.yesterdayMeetings.filter {
      !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
    }
  }

  private var filteredTodayMeetings: [Meeting] {
    calendarManager.todayMeetings.filter {
      !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
    }
  }

  private var filteredTomorrowMeetings: [Meeting] {
    calendarManager.tomorrowMeetings.filter {
      !$0.shouldBeHidden(hideCompletedAfter5Min: appModel.hideCompletedMeetingsAfter5Min)
    }
  }

  private var shouldDisableScroll: Bool {
    // Disable scroll when we have few meetings that likely fit in view
    let totalMeetings =
      filteredYesterdayMeetings.count + filteredTodayMeetings.count
      + filteredTomorrowMeetings.count
    return totalMeetings <= 5  // Approximate threshold for when content fits without scroll
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
    VStack(spacing: 0) {
      List {
        if !filteredYesterdayMeetings.isEmpty {
          DaySectionView(title: "Yesterday", meetings: filteredYesterdayMeetings)
        }
        DaySectionView(title: "Today", meetings: filteredTodayMeetings)
        if !filteredTomorrowMeetings.isEmpty {
          DaySectionView(title: "Tomorrow", meetings: filteredTomorrowMeetings)
        }
      }
      .scrollContentBackground(.hidden)
      .scrollDisabled(shouldDisableScroll)
      .refreshable {
        try? await calendarManager.refreshMeetings()
      }

      // StatusBar removed - now using AppKit StatusBarViewImpl in MeetingsListViewController
      // This SwiftUI view is deprecated and kept only for reference
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
      // Start auto-refresh after successful permission grant
      calendarManager.startAutoRefresh()
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
      // Start auto-refresh after successful initial refresh
      calendarManager.startAutoRefresh()
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
        Logger.error("Manual refresh failed: \(error)")
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

  private func handleAppBecameActive() {
    // Resume auto-refresh when app becomes active
    calendarManager.resumeAutoRefresh()
  }

  private func handleAppResignedActive() {
    // Note: We intentionally do NOT pause auto-refresh when app becomes inactive
    // For a floating meeting widget, users want continuous updates even when working in other apps
    // Auto-refresh only pauses during system sleep (handled by CalendarManager's sleep/wake observers)
  }
}
