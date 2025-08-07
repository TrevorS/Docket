// ABOUTME: Calendar business logic manager integrating EventKit with ZoomURLExtractor
// ABOUTME: Handles calendar access, event fetching, and ZoomMeeting conversion as single source of truth

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
