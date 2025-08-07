// ABOUTME: Calendar business logic manager integrating EventKit with ZoomURLExtractor
// ABOUTME: Handles calendar access, event fetching, and ZoomMeeting conversion as single source of truth

@preconcurrency import EventKit
import Foundation
import Observation

// MARK: - Helper Functions for Debug Output

/// Convert EKCalendarType to human-readable string
private func calendarTypeString(_ type: EKCalendarType) -> String {
  switch type {
  case .local: return "Local"
  case .calDAV: return "CalDAV"
  case .exchange: return "Exchange"
  case .subscription: return "Subscription"
  case .birthday: return "Birthday"
  @unknown default: return "Unknown(\(type.rawValue))"
  }
}

/// Convert EKSourceType to human-readable string
private func calendarSourceTypeString(_ type: EKSourceType) -> String {
  switch type {
  case .local: return "Local"
  case .exchange: return "Exchange"
  case .calDAV: return "CalDAV"
  case .mobileMe: return "MobileMe"
  case .subscribed: return "Subscribed"
  case .birthdays: return "Birthdays"
  @unknown default: return "Unknown(\(type.rawValue))"
  }
}

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

  // MARK: - Initialization

  public init() {
    print("🚀 CalendarManager initializing...")
    updateAuthState()
    print("🚀 CalendarManager initialized with auth state: \(authState)")
  }

  // MARK: - Public API

  /// Request calendar access from the user
  /// - Returns: True if access was granted, false otherwise
  @MainActor
  public func requestAccess() async -> Bool {
    print("🔑 Requesting calendar access...")
    do {
      let granted = try await eventStore.requestFullAccessToEvents()
      print("🔑 Access request result: \(granted)")
      updateAuthState()
      print("🔑 Auth state after request: \(authState)")
      return granted
    } catch {
      let errorMsg = "Failed to request calendar access: \(error.localizedDescription)"
      print("🔑❌ Access request failed: \(errorMsg)")
      authState = .error(errorMsg)
      return false
    }
  }

  /// Refresh today's meetings from calendar
  /// - Throws: CalendarError for various failure scenarios
  @MainActor
  public func refreshMeetings() async throws {
    print("🔄 Starting refresh meetings - current auth state: \(authState)")

    guard authState == .fullAccess || authState == .authorized else {
      print("🔄❌ Access denied - cannot refresh. Auth state: \(authState)")
      throw CalendarError.accessDenied
    }

    print("🔄 Setting isRefreshing = true")
    isRefreshing = true
    defer {
      print("🔄 Setting isRefreshing = false")
      isRefreshing = false
    }

    do {
      print("🔄 Fetching today's events...")
      let events = try await fetchTodaysEvents()
      print("🔄 Converting \(events.count) events to meetings...")
      let zoomMeetings = convertEventsToMeetings(events)
      print("🔄 Found \(zoomMeetings.count) Zoom meetings, sorting...")
      let sortedMeetings = zoomMeetings.sorted { $0.startTime < $1.startTime }

      print("🔄 Updating meetings array with \(sortedMeetings.count) meetings")
      meetings = sortedMeetings
      lastRefresh = Date()
      print("🔄✅ Refresh completed successfully at \(lastRefresh!)")
    } catch {
      print("🔄❌ Refresh failed with error: \(error)")
      throw CalendarError.fetchFailed(error)
    }
  }

  // MARK: - Private Implementation

  /// Update authorization state based on current EventKit status
  public func updateAuthState() {
    let status = EKEventStore.authorizationStatus(for: .event)
    print("🔐 Current EKAuthorizationStatus: \(status) (raw: \(status.rawValue))")
    let newState = mapAuthorizationStatus(status)
    print("🔐 Mapped to CalendarAuthState: \(newState)")
    authState = newState
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

  /// Fetch this week's events from all available calendars
  private func fetchTodaysEvents() async throws -> [EKEvent] {
    let calendar = Calendar.current
    let now = Date()
    let startOfWeek =
      calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? calendar.startOfDay(for: now)
    let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!

    print("📅 Current time: \(now)")
    print("📅 Fetching events for THIS WEEK from \(startOfWeek) to \(endOfWeek)")
    print("📅 Available calendars: \(eventStore.calendars(for: .event).count)")

    // List all available calendars and accounts
    let sources = eventStore.sources
    print("📱 Available accounts/sources: \(sources.count)")
    for source in sources {
      let sourceTypeString =
        switch source.sourceType {
        case .local: "Local"
        case .exchange: "Exchange"
        case .calDAV: "CalDAV"
        case .mobileMe: "MobileMe"
        case .subscribed: "Subscribed"
        case .birthdays: "Birthdays"
        @unknown default: "Unknown(\(source.sourceType.rawValue))"
        }
      print("   🏢 Account: '\(source.title)' (Type: \(sourceTypeString))")
    }

    let allEventCalendars = eventStore.calendars(for: .event)
    print("📖 Available calendars: \(allEventCalendars.count) total")
    for (index, cal) in allEventCalendars.enumerated() {
      print("   📅 Calendar \(index + 1): '\(cal.title)'")
      print(
        "      - Source: '\(cal.source.title)' (\(calendarSourceTypeString(cal.source.sourceType)))"
      )
      print("      - Type: \(cal.type.rawValue) (\(calendarTypeString(cal.type)))")
      print("      - ID: \(cal.calendarIdentifier)")
      print("      - Subscribed: \(cal.isSubscribed)")
      print("      - AllowsContentModifications: \(cal.allowsContentModifications)")
    }

    // Create predicate for today's events - explicitly include ALL calendars
    let allCalendars = eventStore.calendars(for: .event)
    print("🔍 Searching in \(allCalendars.count) calendars:")
    for cal in allCalendars {
      print("   🔍 Will search: '\(cal.title)' from '\(cal.source.title)'")
    }

    let predicate = eventStore.predicateForEvents(
      withStart: startOfWeek,
      end: endOfWeek,
      calendars: allCalendars  // Explicitly pass all calendars instead of nil
    )

    // EventKit fetching is synchronous, but we're in async context
    let events = eventStore.events(matching: predicate)
    print("📋 Found \(events.count) total events this week")

    // Log ALL events for debugging with MAXIMUM detail
    for (index, event) in events.enumerated() {
      print("📅 Event \(index + 1): '\(event.title ?? "Untitled")'")
      print("   ⏰ Start: \(String(describing: event.startDate)) (All day: \(event.isAllDay))")
      print("   ⏰ End: \(String(describing: event.endDate))")
      print("   📍 Location: '\(event.location ?? "None")'")
      print("   🏗️ Structured Location: '\(event.structuredLocation?.title ?? "None")'")
      print(
        "   🏗️ Structured Geo: '\(event.structuredLocation?.geoLocation?.description ?? "None")'")
      print("   📝 Notes: '\(event.notes?.prefix(200) ?? "None")'")
      print("   🔗 URL: '\(event.url?.absoluteString ?? "None")'")
      print("   📅 Calendar: '\(event.calendar.title)' (Source: '\(event.calendar.source.title)')")
      print("   👤 Organizer: '\(event.organizer?.name ?? "None")'")
      print("   👥 Attendees: \(event.attendees?.count ?? 0)")
      print("   🆔 Event ID: \(event.eventIdentifier ?? "None")")
      print("   🔄 Recurrence: \(event.recurrenceRules?.description ?? "None")")
      print("   🚨 Status: \(event.status.rawValue)")
      print("   🔒 Availability: \(event.availability.rawValue)")
      print("   ---")
    }

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

      print("🔍 Found Zoom meeting: \(event.title ?? "Untitled") with URL: \(zoomUrl)")

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

    print("🎯 Converted \(zoomMeetings.count) Zoom meetings from \(events.count) total events")
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
