// ABOUTME: Main meetings list view using modern SwiftUI component architecture
// ABOUTME: Orchestrates day sections, loading states, and calendar permission handling

import SwiftUI

struct MeetingsListView: View {
  @Environment(AppModel.self) private var appModel
  @State private var calendarManager = CalendarManager()
  @State private var isRequestingPermission = false
  @State private var isScrolling = false
  @State private var scrollFadeTimer: Timer?

  init() {
  }

  var body: some View {
    NavigationStack {
      Group {
        if isRequestingPermission {
          permissionLoadingView
        } else if calendarManager.meetings.isEmpty && calendarManager.lastRefresh == nil {
          // Only show loading view on initial load (no previous refresh), not during auto-refresh
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
          PinButton(
            isPinned: Binding(
              get: { appModel.alwaysOnTop },
              set: { appModel.alwaysOnTop = $0 }
            ))
        }
      }
    }
    .task {
      await requestCalendarAccessAndRefresh()
    }
    .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
      Task { @MainActor in
        handleAppBecameActive()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .appDidResignActive)) { _ in
      Task { @MainActor in
        handleAppResignedActive()
      }
    }
  }

  // MARK: - Computed Properties

  private var shouldDisableScroll: Bool {
    // Disable scroll when we have few meetings that likely fit in view
    let totalMeetings =
      calendarManager.yesterdayMeetings.count + calendarManager.todayMeetings.count
      + calendarManager.tomorrowMeetings.count
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
    ZStack {
      List {
        DaySectionView(title: "Yesterday", meetings: calendarManager.yesterdayMeetings)
        DaySectionView(title: "Today", meetings: calendarManager.todayMeetings)
        DaySectionView(title: "Tomorrow", meetings: calendarManager.tomorrowMeetings)
      }
      .scrollDisabled(shouldDisableScroll)
      .refreshable {
        try? await calendarManager.refreshMeetings()
      }
      .simultaneousGesture(
        DragGesture()
          .onChanged { _ in
            handleScrollStart()
          }
          .onEnded { _ in
            handleScrollEnd()
          }
      )

      VStack {
        Spacer()
        RefreshStatusView(
          lastRefresh: calendarManager.lastRefresh,
          isRefreshing: calendarManager.isRefreshing,
          isAutoRefreshEnabled: calendarManager.isAutoRefreshEnabled,
          isAutoRefreshActive: calendarManager.isAutoRefreshActive,
          onToggleAutoRefresh: {
            if calendarManager.isAutoRefreshActive {
              calendarManager.pauseAutoRefresh()
            } else {
              calendarManager.resumeAutoRefresh()
              // Trigger immediate refresh when resuming from pause
              Task {
                try? await calendarManager.refreshMeetings()
              }
            }
          }
        )
        .opacity(isScrolling ? 0.0 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isScrolling)
      }
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

  private func handleScrollStart() {
    // User started scrolling - fade out immediately
    scrollFadeTimer?.invalidate()
    withAnimation(.easeInOut(duration: 0.2)) {
      isScrolling = true
    }
  }

  private func handleScrollEnd() {
    // Start timer to fade back in after scroll stops
    scrollFadeTimer?.invalidate()
    scrollFadeTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
      Task { @MainActor in
        withAnimation(.easeInOut(duration: 0.3)) {
          isScrolling = false
        }
      }
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
        .overlay(alignment: .bottom) {
          RefreshStatusView(
            lastRefresh: mockCalendarManager.lastRefresh,
            isRefreshing: mockCalendarManager.isRefreshing,
            isAutoRefreshEnabled: mockCalendarManager.isAutoRefreshEnabled,
            isAutoRefreshActive: mockCalendarManager.isAutoRefreshActive
          ) {
            print("Toggle auto-refresh (preview)")
          }
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
