// ABOUTME: Calendar business logic manager integrating EventKit with ZoomURLExtractor
// ABOUTME: Handles calendar access, event fetching, and ZoomMeeting conversion as single source of truth

import AppKit
@preconcurrency import EventKit
import Foundation
import Observation

/// Main business logic manager for calendar integration and meeting data management
@Observable
public final class CalendarManager: @unchecked Sendable {

  // MARK: - Dependencies

  private let eventStore = EKEventStore()

  // MARK: - Published State

  /// Current calendar authorization state
  public var authState: CalendarAuthState = .notDetermined

  /// List of today's meetings with Zoom URLs, sorted chronologically
  public var meetings: [ZoomMeeting] = []

  /// Timestamp of last successful refresh
  public var lastRefresh: Date?

  /// Whether a refresh operation is currently in progress
  public var isRefreshing: Bool = false

  /// Whether auto-refresh is enabled (60-second timer)
  public var isAutoRefreshEnabled: Bool = true

  /// Whether auto-refresh is currently active (not paused)
  public var isAutoRefreshActive: Bool = false

  // MARK: - Private State

  private var autoRefreshTimer: Timer?
  private var appLifecycleObservers: [NSObjectProtocol] = []

  // MARK: - Computed Properties

  /// Yesterday's meetings (filtered from main meetings array)
  public var yesterdayMeetings: [ZoomMeeting] {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: yesterday)
    }
  }

  /// Today's meetings (filtered from main meetings array)
  public var todayMeetings: [ZoomMeeting] {
    let calendar = Calendar.current
    let today = Date()
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: today)
    }
  }

  /// Tomorrow's meetings (filtered from main meetings array)
  public var tomorrowMeetings: [ZoomMeeting] {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: tomorrow)
    }
  }

  // MARK: - Initialization

  public init() {
    updateAuthState()
    setupAppLifecycleMonitoring()
  }

  deinit {
    // Clean up timer directly in deinit (avoid Task that outlives deinit)
    autoRefreshTimer?.invalidate()
    removeAppLifecycleObservers()
  }

  // MARK: - Public API

  /// Request calendar access from the user
  /// - Returns: True if access was granted, false otherwise
  @MainActor
  public func requestAccess() async -> Bool {
    do {
      let granted = try await eventStore.requestFullAccessToEvents()
      updateAuthState()
      return granted
    } catch {
      let errorMsg = "Failed to request calendar access: \(error.localizedDescription)"
      print("❌ Calendar access request failed: \(errorMsg)")
      authState = .error(errorMsg)
      return false
    }
  }

  /// Refresh today's meetings from calendar
  /// - Throws: CalendarError for various failure scenarios
  @MainActor
  public func refreshMeetings() async throws {
    guard authState == .fullAccess || authState == .authorized else {
      throw CalendarError.accessDenied
    }

    isRefreshing = true
    defer {
      isRefreshing = false
    }

    do {
      let events = try await fetchThreeDayEvents()
      let zoomMeetings = convertEventsToMeetings(events)
      let sortedMeetings = zoomMeetings.sorted { $0.startTime < $1.startTime }

      meetings = sortedMeetings
      lastRefresh = Date()
    } catch {
      print("❌ Meeting refresh failed: \(error)")
      throw CalendarError.fetchFailed(error)
    }
  }

  // MARK: - Auto-Refresh Management

  /// Start the auto-refresh timer (60-second interval)
  @MainActor
  public func startAutoRefresh() {
    guard isAutoRefreshEnabled else { return }

    stopAutoRefresh()  // Stop any existing timer

    autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) {
      [weak self] _ in
      Task { @MainActor in
        await self?.performAutoRefresh()
      }
    }

    isAutoRefreshActive = true
    print("✅ Auto-refresh timer started (60-second interval)")
  }

  /// Stop the auto-refresh timer
  @MainActor
  public func stopAutoRefresh() {
    autoRefreshTimer?.invalidate()
    autoRefreshTimer = nil
    isAutoRefreshActive = false
    print("⏹ Auto-refresh timer stopped")
  }

  /// Resume auto-refresh if enabled (called when app becomes active)
  @MainActor
  public func resumeAutoRefresh() {
    guard isAutoRefreshEnabled && !isAutoRefreshActive else { return }
    startAutoRefresh()
    print("▶️ Auto-refresh resumed (app became active)")
  }

  /// Pause auto-refresh (called when app becomes inactive)
  @MainActor
  public func pauseAutoRefresh() {
    guard isAutoRefreshActive else { return }
    stopAutoRefresh()
    print("⏸ Auto-refresh paused (app became inactive)")
  }

  /// Toggle auto-refresh enabled state
  @MainActor
  public func toggleAutoRefresh() {
    isAutoRefreshEnabled.toggle()

    if isAutoRefreshEnabled {
      startAutoRefresh()
    } else {
      stopAutoRefresh()
    }

    print("🔄 Auto-refresh \(isAutoRefreshEnabled ? "enabled" : "disabled")")
  }

  /// Perform auto-refresh (internal method called by timer)
  @MainActor
  private func performAutoRefresh() async {
    // Only auto-refresh if we have permission and not already refreshing
    guard (authState == .fullAccess || authState == .authorized) && !isRefreshing else {
      return
    }

    // Defer the actual refresh to the next run loop to avoid reentrant table view operations
    await Task { @MainActor in
      do {
        try await refreshMeetings()
        print("🔄 Auto-refresh completed successfully")
      } catch {
        print("❌ Auto-refresh failed: \(error)")
        // Don't throw the error - auto-refresh should fail silently
      }
    }.value
  }

  // MARK: - App Lifecycle Management

  private func setupAppLifecycleMonitoring() {
    let activeObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.resumeAutoRefresh()
      }
    }

    let inactiveObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.willResignActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.pauseAutoRefresh()
      }
    }

    appLifecycleObservers = [activeObserver, inactiveObserver]
    print("📱 App lifecycle monitoring setup complete")
  }

  private func removeAppLifecycleObservers() {
    appLifecycleObservers.forEach { observer in
      NotificationCenter.default.removeObserver(observer)
    }
    appLifecycleObservers.removeAll()
    print("📱 App lifecycle observers removed")
  }

  // MARK: - Private Implementation

  /// Update authorization state based on current EventKit status
  public func updateAuthState() {
    let status = EKEventStore.authorizationStatus(for: .event)
    authState = mapAuthorizationStatus(status)
  }

  /// Map EKAuthorizationStatus to CalendarAuthState
  private func mapAuthorizationStatus(_ status: EKAuthorizationStatus) -> CalendarAuthState {
    switch status {
    case .notDetermined:
      return .notDetermined
    case .fullAccess:
      return .fullAccess
    case .denied:
      return .denied
    case .restricted:
      return .restricted
    case .writeOnly:
      return .writeOnly
    @unknown default:
      return .error("Unknown authorization status: \(status)")
    }
  }

  /// Fetch 3-day events (yesterday + today + tomorrow) from all available calendars
  private func fetchThreeDayEvents() async throws -> [EKEvent] {
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)
    let startDate = calendar.date(byAdding: .day, value: -1, to: todayStart)!  // Yesterday start
    let endDate = calendar.date(byAdding: .day, value: 2, to: todayStart)!  // Day after tomorrow start

    // Create predicate for 3-day events - explicitly include ALL calendars
    let allCalendars = eventStore.calendars(for: .event)

    let predicate = eventStore.predicateForEvents(
      withStart: startDate,
      end: endDate,
      calendars: allCalendars  // Explicitly pass all calendars instead of nil
    )

    // EventKit fetching is synchronous, but we're in async context
    let events = eventStore.events(matching: predicate)

    return events
  }

  /// Convert EKEvents to ZoomMeetings, filtering for those with Zoom URLs
  /// Made internal for testing purposes
  internal func convertEventsToMeetings(_ events: [EKEvent]) -> [ZoomMeeting] {
    let zoomMeetings = events.compactMap { event -> ZoomMeeting? in
      // Create adapter for ZoomURLExtractor
      let adapter = EKEventAdapter(event: event)

      // Use ZoomURLExtractor to find Zoom URL
      guard let zoomUrl = ZoomURLExtractor.extract(from: adapter) else {
        return nil  // Skip events without Zoom URLs
      }

      return ZoomMeeting(
        id: UUID(),
        title: event.title ?? "Untitled Meeting",
        startTime: event.startDate,
        endTime: event.endDate,
        joinUrl: zoomUrl,
        organizerName: event.organizer?.name,
        organizerEmail: nil,  // EKParticipant doesn't expose email directly
        attendeeCount: event.attendees?.count ?? 0,
        calendarName: event.calendar.title,
        eventIdentifier: event.eventIdentifier
      )
    }

    return zoomMeetings
  }

  /// Convert CalendarEventLike objects with metadata to ZoomMeetings for testing purposes
  /// This method is internal and used for testing with mock events
  internal func convertCalendarEventsToMeetings(
    _ eventData: [(
      event: any CalendarEventLike, title: String, startDate: Date, endDate: Date,
      organizerName: String?, organizerEmail: String?, attendeeCount: Int, calendarTitle: String,
      eventIdentifier: String
    )]
  ) -> [ZoomMeeting] {
    return eventData.compactMap { data -> ZoomMeeting? in
      // Use ZoomURLExtractor to find Zoom URL
      guard let zoomUrl = ZoomURLExtractor.extract(from: data.event) else {
        return nil  // Skip events without Zoom URLs
      }

      return ZoomMeeting(
        id: UUID(),
        title: data.title,
        startTime: data.startDate,
        endTime: data.endDate,
        joinUrl: zoomUrl,
        organizerName: data.organizerName,
        organizerEmail: data.organizerEmail,
        attendeeCount: data.attendeeCount,
        calendarName: data.calendarTitle,
        eventIdentifier: data.eventIdentifier
      )
    }
  }
}

// MARK: - Error Types

/// Errors that can occur during calendar operations
public enum CalendarError: Error, LocalizedError {
  case accessDenied
  case fetchFailed(Error)
  case invalidEvent

  public var errorDescription: String? {
    switch self {
    case .accessDenied:
      return "Calendar access denied or insufficient"
    case .fetchFailed(let error):
      return "Failed to fetch calendar events: \(error.localizedDescription)"
    case .invalidEvent:
      return "Invalid calendar event data"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .accessDenied:
      return "Grant calendar access in System Settings > Privacy & Security"
    case .fetchFailed:
      return "Check your internet connection and try again"
    case .invalidEvent:
      return "Verify the calendar event has valid data"
    }
  }
}
