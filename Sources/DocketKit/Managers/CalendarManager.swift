// ABOUTME: Calendar business logic manager integrating EventKit with MeetingURLExtractor
// ABOUTME: Handles calendar access, event fetching, and Meeting conversion as single source of truth

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

  /// List of today's meetings with video meeting URLs, sorted chronologically
  public var meetings: [Meeting] = []

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
  private var sleepWakeObservers: [NSObjectProtocol] = []

  // MARK: - Computed Properties

  /// Yesterday's meetings (filtered from main meetings array)
  public var yesterdayMeetings: [Meeting] {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: yesterday)
    }
  }

  /// Today's meetings (filtered from main meetings array)
  public var todayMeetings: [Meeting] {
    let calendar = Calendar.current
    let today = Date()
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: today)
    }
  }

  /// Tomorrow's meetings (filtered from main meetings array)
  public var tomorrowMeetings: [Meeting] {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
    return meetings.filter { meeting in
      calendar.isDate(meeting.startTime, inSameDayAs: tomorrow)
    }
  }

  // MARK: - Initialization

  public init() {
    updateAuthState()
    setupSleepWakeNotifications()
  }

  deinit {
    // Clean up timer directly in deinit (avoid Task that outlives deinit)
    autoRefreshTimer?.invalidate()
    removeSleepWakeNotifications()
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
      Logger.error("Calendar access request failed: \(errorMsg)")
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
      let videoMeetings = convertEventsToMeetings(events)
      let sortedMeetings = videoMeetings.sorted { $0.startTime < $1.startTime }

      meetings = sortedMeetings
      lastRefresh = Date()
    } catch {
      Logger.error("Meeting refresh failed: \(error)")
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
      // Use a detached task to avoid timer callback context
      Task.detached {
        await self?.performAutoRefresh()
      }
    }

    isAutoRefreshActive = true
    Logger.success("Auto-refresh timer started (60-second interval)")
  }

  /// Stop the auto-refresh timer
  @MainActor
  public func stopAutoRefresh() {
    autoRefreshTimer?.invalidate()
    autoRefreshTimer = nil
    isAutoRefreshActive = false
    Logger.info("Auto-refresh timer stopped")
  }

  /// Resume auto-refresh if enabled (called when app becomes active)
  @MainActor
  public func resumeAutoRefresh() {
    guard isAutoRefreshEnabled && !isAutoRefreshActive else { return }
    startAutoRefresh()
    Logger.info("Auto-refresh resumed (app became active)")
  }

  /// Pause auto-refresh (called when app becomes inactive)
  @MainActor
  public func pauseAutoRefresh() {
    guard isAutoRefreshActive else { return }
    stopAutoRefresh()
    Logger.info("Auto-refresh paused (app became inactive)")
  }

  /// Perform auto-refresh (internal method called by timer)
  @MainActor
  private func performAutoRefresh() async {
    // Only auto-refresh if we have permission and not already refreshing
    guard (authState == .fullAccess || authState == .authorized) && !isRefreshing else {
      return
    }

    // Use DispatchQueue to break out of current execution context completely
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      guard let self = self else { return }

      Task { @MainActor in
        // Double-check conditions after delay
        guard (self.authState == .fullAccess || self.authState == .authorized) && !self.isRefreshing
        else {
          return
        }

        do {
          try await self.refreshMeetings()
          Logger.success("Auto-refresh completed successfully")
        } catch {
          Logger.error("Auto-refresh failed: \(error)")
          // Don't throw the error - auto-refresh should fail silently
        }
      }
    }
  }

  // MARK: - Private Implementation

  /// Extract email from EKParticipant using available workarounds
  /// Due to EventKit API limitations, this tries to extract email from URL components
  private func extractEmailFromParticipant(_ participant: EKParticipant) -> String? {
    // Try to get email from URL components
    // Note: This is unreliable but it's the best we can do with public EventKit API
    let urlString = participant.url.absoluteString

    // Check if the URL contains "mailto:" scheme which might have email
    if urlString.hasPrefix("mailto:") {
      let email = String(urlString.dropFirst(7))  // Remove "mailto:"
      if email.contains("@") && email.contains(".") {
        return email
      }
    }

    // Try to extract from URL path components
    if let path = participant.url.path.components(separatedBy: "/").last,
      path.contains("@") && path.contains(".") && !path.contains("principal")
    {
      return path
    }

    // Try to extract from URL query parameters
    if let query = participant.url.query, query.contains("@") {
      let components = URLComponents(url: participant.url, resolvingAgainstBaseURL: false)
      if let queryItems = components?.queryItems {
        for item in queryItems {
          if let value = item.value, value.contains("@") && value.contains(".") {
            return value
          }
        }
      }
    }

    return nil
  }

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

  /// Convert EKEvents to Meetings, filtering for those with video meeting URLs
  /// Made internal for testing purposes
  internal func convertEventsToMeetings(_ events: [EKEvent]) -> [Meeting] {
    let meetings = events.compactMap { event -> Meeting? in
      // Create adapter for MeetingURLExtractor
      let adapter = EKEventAdapter(event: event)

      // Use MeetingURLExtractor to find meeting URL with platform detection
      guard let (meetingUrl, platform) = MeetingURLExtractor.extractWithPlatform(from: adapter)
      else {
        return nil  // Skip events without meeting URLs
      }

      // Extract attendee details from EKParticipant array
      let attendeeDetails = (event.attendees ?? []).map {
        participant -> (name: String?, email: String?) in
        let name = participant.name
        let email = extractEmailFromParticipant(participant)

        // Debug logging
        Logger.debug(
          "Attendee - Name: '\(name ?? "nil")', Email: '\(email ?? "nil")', URL: '\(participant.url)'"
        )

        return (name: name, email: email)
      }

      // Debug logging for final attendee list
      Logger.debug(
        "Meeting '\(event.title ?? "Untitled")' has \(attendeeDetails.count) attendees extracted")

      return Meeting(
        id: UUID(),
        title: event.title ?? "Untitled Meeting",
        startTime: event.startDate,
        endTime: event.endDate,
        joinUrl: meetingUrl,
        platform: platform,
        organizerName: event.organizer?.name,
        organizerEmail: nil,  // EKParticipant doesn't expose email directly
        attendeeCount: event.attendees?.count ?? 0,
        attendees: attendeeDetails,
        calendarName: event.calendar.title,
        eventIdentifier: event.eventIdentifier
      )
    }

    return meetings
  }

  /// Convert CalendarEventLike objects with metadata to Meetings for testing purposes
  /// This method is internal and used for testing with mock events
  internal func convertCalendarEventsToMeetings(
    _ eventData: [(
      event: any CalendarEventLike, title: String, startDate: Date, endDate: Date,
      organizerName: String?, organizerEmail: String?, attendeeCount: Int, calendarTitle: String,
      eventIdentifier: String
    )]
  ) -> [Meeting] {
    return eventData.compactMap { data -> Meeting? in
      // Use MeetingURLExtractor to find meeting URL with platform detection
      guard let (meetingUrl, platform) = MeetingURLExtractor.extractWithPlatform(from: data.event)
      else {
        return nil  // Skip events without meeting URLs
      }

      return Meeting(
        id: UUID(),
        title: data.title,
        startTime: data.startDate,
        endTime: data.endDate,
        joinUrl: meetingUrl,
        platform: platform,
        organizerName: data.organizerName,
        organizerEmail: data.organizerEmail,
        attendeeCount: data.attendeeCount,
        attendees: [],  // Test method doesn't provide attendee details
        calendarName: data.calendarTitle,
        eventIdentifier: data.eventIdentifier
      )
    }
  }

  // MARK: - Sleep/Wake Notifications

  /// Set up system sleep/wake notifications to manage auto-refresh
  private func setupSleepWakeNotifications() {
    let notificationCenter = NSWorkspace.shared.notificationCenter

    // Computer will sleep - pause auto-refresh
    let willSleepObserver = notificationCenter.addObserver(
      forName: NSWorkspace.willSleepNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.handleSystemWillSleep()
      }
    }

    // Computer did wake - resume auto-refresh
    let didWakeObserver = notificationCenter.addObserver(
      forName: NSWorkspace.didWakeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.handleSystemDidWake()
      }
    }

    sleepWakeObservers = [willSleepObserver, didWakeObserver]
  }

  /// Remove sleep/wake notification observers
  private func removeSleepWakeNotifications() {
    let notificationCenter = NSWorkspace.shared.notificationCenter

    for observer in sleepWakeObservers {
      notificationCenter.removeObserver(observer)
    }

    sleepWakeObservers.removeAll()
  }

  /// Handle system going to sleep - pause auto-refresh to save resources
  @MainActor
  private func handleSystemWillSleep() {
    guard isAutoRefreshActive else { return }
    pauseAutoRefresh()
    Logger.info("System going to sleep - auto-refresh paused")
  }

  /// Handle system waking up - resume auto-refresh and perform immediate refresh
  @MainActor
  private func handleSystemDidWake() {
    guard isAutoRefreshEnabled else { return }

    // Resume auto-refresh timer
    resumeAutoRefresh()

    // Perform an immediate refresh since data might be stale
    Task {
      // Small delay to allow system to fully wake up
      try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds

      do {
        try await refreshMeetings()
        Logger.success("Wake-up refresh completed successfully")
      } catch {
        Logger.error("Wake-up refresh failed: \(error)")
      }
    }

    Logger.info("System woke up - auto-refresh resumed with immediate refresh")
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
