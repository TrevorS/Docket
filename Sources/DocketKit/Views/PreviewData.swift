// ABOUTME: Mock data infrastructure for Xcode previews
// ABOUTME: Provides consistent sample meetings in different states for testing UI components

import Foundation

/// Mock data infrastructure for SwiftUI previews
public enum PreviewData {

  // MARK: - Sample Meetings

  /// Meeting that started 30 minutes ago and is currently active
  public static let activeMeeting = Meeting(
    id: UUID(),
    title: "Team Standup - Engineering",
    startTime: Date().addingTimeInterval(-1800),  // Started 30 minutes ago
    endTime: Date().addingTimeInterval(1800),  // Ends in 30 minutes
    joinUrl: "https://us06web.zoom.us/j/89557978975?pwd=b35gu4QOvkmB1Hag40zewC2hqUjEW0.1",
    platform: .zoom,
    organizerName: "Sarah Johnson",
    organizerEmail: "sarah@company.com",
    attendeeCount: 8,
    attendees: [
      (name: "John Smith", email: "john@company.com"),
      (name: "Alice Brown", email: "alice@company.com"),
      (name: "Bob Wilson", email: nil),
      (name: "Carol Davis", email: "carol@company.com"),
      (name: nil, email: "dave@company.com"),
      (name: "Eve Johnson", email: "eve@company.com"),
      (name: "Frank Miller", email: "frank@company.com"),
      (name: "Grace Lee", email: "grace@company.com")
    ],
    calendarName: "Work Calendar",
    eventIdentifier: "preview-active"
  )

  /// Meeting starting in 2 minutes (upcoming)
  public static let upcomingMeeting = Meeting(
    id: UUID(),
    title: "Client Review Meeting",
    startTime: Date().addingTimeInterval(120),  // Starts in 2 minutes
    endTime: Date().addingTimeInterval(3720),  // Ends in 1 hour 2 minutes
    joinUrl: "https://zoom.us/j/123456789?pwd=abcd1234",
    platform: .zoom,
    organizerName: "Michael Chen",
    organizerEmail: "mike@company.com",
    attendeeCount: 5,
    attendees: [
      (name: "Client A", email: "client@external.com"),
      (name: "Client B", email: "clientb@external.com"),
      (name: "Project Manager", email: "pm@company.com"),
      (name: "Designer", email: nil),
      (name: "Developer", email: "dev@company.com")
    ],
    calendarName: "Work Calendar",
    eventIdentifier: "preview-upcoming"
  )

  /// Meeting that ended 1 hour ago
  public static let endedMeeting = Meeting(
    id: UUID(),
    title: "Design System Review",
    startTime: Date().addingTimeInterval(-7200),  // Started 2 hours ago
    endTime: Date().addingTimeInterval(-3600),  // Ended 1 hour ago
    joinUrl: "https://company.zoom.us/j/987654321",
    platform: .zoom,
    organizerName: "Emma Thompson",
    organizerEmail: "emma@company.com",
    attendeeCount: 12,
    attendees: [
      (name: "Design Lead", email: "design@company.com"),
      (name: "UX Researcher", email: "research@company.com"),
      (name: "Frontend Dev", email: "frontend@company.com"),
      (name: "Product Owner", email: "product@company.com"),
      (name: "QA Engineer", email: nil),
      (name: nil, email: "stakeholder@company.com"),
      (name: "Brand Manager", email: "brand@company.com"),
      (name: "Marketing", email: "marketing@company.com"),
      (name: "Engineering Manager", email: "em@company.com"),
      (name: "Accessibility Expert", email: "a11y@company.com"),
      (name: "Content Strategist", email: "content@company.com"),
      (name: "Tech Writer", email: "docs@company.com")
    ],
    calendarName: "Design Calendar",
    eventIdentifier: "preview-ended"
  )

  /// Meeting without a Zoom URL
  public static let meetingWithoutUrl = Meeting(
    id: UUID(),
    title: "All Hands Meeting",
    startTime: Date().addingTimeInterval(3600),  // Starts in 1 hour
    endTime: Date().addingTimeInterval(5400),  // Ends in 1.5 hours
    joinUrl: nil,
    platform: .unknown,
    organizerName: "CEO Office",
    organizerEmail: "ceo@company.com",
    attendeeCount: 150,
    attendees: [],  // Too many attendees to list individually
    calendarName: "Company Calendar",
    eventIdentifier: "preview-no-url"
  )

  /// Meeting with a very long title to test UI wrapping
  public static let longTitleMeeting = Meeting(
    id: UUID(),
    title:
      "Q4 Planning Session: Engineering Roadmap, Technical Debt Review, and Resource Allocation Discussion",
    startTime: Date().addingTimeInterval(7200),  // Starts in 2 hours
    endTime: Date().addingTimeInterval(10800),  // Ends in 3 hours
    joinUrl: "https://zoom.us/j/555666777",
    platform: .zoom,
    organizerName: "Planning Committee",
    organizerEmail: "planning@company.com",
    attendeeCount: 25,
    attendees: [
      (name: "Engineering Lead", email: "eng-lead@company.com"),
      (name: "Product Director", email: "prod-dir@company.com"),
      (name: "Tech Lead A", email: "tech-a@company.com"),
      (name: "Tech Lead B", email: nil),
      (name: "Architect", email: "architect@company.com")
      // Only showing first 5 of 25 attendees for brevity
    ],
    calendarName: "Planning Calendar",
    eventIdentifier: "preview-long-title"
  )

  /// Meeting with minimal information
  public static let minimalMeeting = Meeting(
    id: UUID(),
    title: "Quick Check-in",
    startTime: Date().addingTimeInterval(1800),  // Starts in 30 minutes
    endTime: Date().addingTimeInterval(2700),  // Ends in 45 minutes
    joinUrl: "https://zoom.us/j/111222333",
    platform: .zoom,
    organizerName: nil,
    organizerEmail: nil,
    attendeeCount: 0,
    attendees: [],
    calendarName: "",
    eventIdentifier: "preview-minimal"
  )

  // MARK: - Sample Meeting Groups

  /// Yesterday's meetings (for day section testing)
  public static let yesterdayMeetings: [Meeting] = [
    Meeting(
      id: UUID(),
      title: "Sprint Retrospective",
      startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(
        36000),  // Yesterday 10 AM
      endTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.addingTimeInterval(
        39600),  // Yesterday 11 AM
      joinUrl: "https://zoom.us/j/retro123",
      platform: .zoom,
      organizerName: "Scrum Master",
      organizerEmail: "scrum@company.com",
      attendeeCount: 6,
      attendees: [
        (name: "Developer A", email: "dev-a@company.com"),
        (name: "Developer B", email: "dev-b@company.com"),
        (name: "QA Engineer", email: nil),
        (name: "Product Owner", email: "po@company.com"),
        (name: "Designer", email: "designer@company.com"),
        (name: "Tech Lead", email: "tl@company.com")
      ],
      calendarName: "Agile Calendar",
      eventIdentifier: "preview-yesterday-1"
    )
  ]

  /// Today's meetings (for day section testing)
  public static let todayMeetings: [Meeting] = [
    activeMeeting,
    upcomingMeeting,
    Meeting(
      id: UUID(),
      title: "Product Demo",
      startTime: Date().addingTimeInterval(14400),  // 4 hours from now
      endTime: Date().addingTimeInterval(16200),  // 4.5 hours from now
      joinUrl: "https://zoom.us/j/demo456",
      platform: .zoom,
      organizerName: "Product Team",
      organizerEmail: "product@company.com",
      attendeeCount: 20,
      attendees: [
        (name: "Stakeholder A", email: "stakeholder1@company.com"),
        (name: "Stakeholder B", email: "stakeholder2@company.com"),
        (name: "Customer Success", email: "cs@company.com")
        // Only showing first 3 of 20 attendees
      ],
      calendarName: "Product Calendar",
      eventIdentifier: "preview-today-3"
    ),
  ]

  /// Tomorrow's meetings (for day section testing)
  public static let tomorrowMeetings: [Meeting] = [
    Meeting(
      id: UUID(),
      title: "Architecture Review",
      startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.addingTimeInterval(
        32400),  // Tomorrow 9 AM
      endTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.addingTimeInterval(
        36000),  // Tomorrow 10 AM
      joinUrl: "https://zoom.us/j/arch789",
      platform: .zoom,
      organizerName: "Tech Lead",
      organizerEmail: "tech@company.com",
      attendeeCount: 8,
      attendees: [],
      calendarName: "Engineering Calendar",
      eventIdentifier: "preview-tomorrow-1"
    ),
    Meeting(
      id: UUID(),
      title: "1:1 with Manager",
      startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.addingTimeInterval(
        50400),  // Tomorrow 2 PM
      endTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())!.addingTimeInterval(
        52200),  // Tomorrow 2:30 PM
      joinUrl: "https://zoom.us/j/oneone123",
      platform: .zoom,
      organizerName: "Engineering Manager",
      organizerEmail: "manager@company.com",
      attendeeCount: 2,
      attendees: [
        (name: "You", email: nil),
        (name: "Manager", email: "manager@company.com")
      ],
      calendarName: "Personal Calendar",
      eventIdentifier: "preview-tomorrow-2"
    ),
  ]

  /// Completed meetings (for testing collapse functionality)
  public static let completedMeetings: [Meeting] = [
    Meeting(
      id: UUID(),
      title: "Morning Standup",
      startTime: Date().addingTimeInterval(-14400),  // Started 4 hours ago
      endTime: Date().addingTimeInterval(-13500),  // Ended 3.75 hours ago
      joinUrl: "https://zoom.us/j/morning123",
      platform: .zoom,
      organizerName: "Scrum Master",
      organizerEmail: "scrum@company.com",
      attendeeCount: 8,
      attendees: [],
      calendarName: "Agile Calendar",
      eventIdentifier: "preview-completed-1"
    ),
    Meeting(
      id: UUID(),
      title: "Budget Review",
      startTime: Date().addingTimeInterval(-10800),  // Started 3 hours ago
      endTime: Date().addingTimeInterval(-7200),  // Ended 2 hours ago
      joinUrl: "https://zoom.us/j/budget456",
      platform: .zoom,
      organizerName: "Finance Team",
      organizerEmail: "finance@company.com",
      attendeeCount: 6,
      attendees: [],
      calendarName: "Finance Calendar",
      eventIdentifier: "preview-completed-2"
    ),
    Meeting(
      id: UUID(),
      title: "Team Lunch Planning",
      startTime: Date().addingTimeInterval(-5400),  // Started 1.5 hours ago
      endTime: Date().addingTimeInterval(-3600),  // Ended 1 hour ago
      joinUrl: "https://zoom.us/j/lunch789",
      platform: .zoom,
      organizerName: "Team Lead",
      organizerEmail: "team@company.com",
      attendeeCount: 12,
      attendees: [],
      calendarName: "Social Calendar",
      eventIdentifier: "preview-completed-3"
    ),
  ]

  /// Google Meet meeting example
  public static let googleMeetMeeting = Meeting(
    id: UUID(),
    title: "Weekly Team Sync - Google Meet",
    startTime: Date().addingTimeInterval(900),  // Starts in 15 minutes
    endTime: Date().addingTimeInterval(2700),  // Ends in 45 minutes
    joinUrl: "https://meet.google.com/abc-defg-hij",
    platform: .googleMeet,
    organizerName: "Team Lead",
    organizerEmail: "teamlead@company.com",
    attendeeCount: 6,
    attendees: [
      (name: "Alex Chen", email: "alex@company.com"),
      (name: "Maria Garcia", email: "maria@company.com"),
      (name: "James Wilson", email: nil),
      (name: "Lisa Park", email: "lisa@company.com"),
      (name: "Ryan Davis", email: "ryan@company.com"),
      (name: "Sophie Brown", email: "sophie@company.com")
    ],
    calendarName: "Work Calendar",
    eventIdentifier: "preview-google-meet"
  )

  /// All sample meetings combined for testing
  public static let allMeetings: [Meeting] = [
    activeMeeting,
    upcomingMeeting,
    endedMeeting,
    longTitleMeeting,
    minimalMeeting,
    googleMeetMeeting,
  ]

  // MARK: - Mock CalendarManager

  /// Mock CalendarManager for preview purposes
  @Observable
  public final class MockCalendarManager {
    public var authState: CalendarAuthState = .fullAccess
    public var meetings: [Meeting] = PreviewData.allMeetings
    public var lastRefresh: Date? = Date().addingTimeInterval(-300)  // 5 minutes ago
    public var isRefreshing: Bool = false
    public var isAutoRefreshEnabled: Bool = true
    public var isAutoRefreshActive: Bool = false

    public var yesterdayMeetings: [Meeting] { PreviewData.yesterdayMeetings }
    public var todayMeetings: [Meeting] { PreviewData.todayMeetings }
    public var tomorrowMeetings: [Meeting] { PreviewData.tomorrowMeetings }

    public init() {}

    public func requestAccess() async -> Bool {
      return true
    }

    public func refreshMeetings() async throws {
      // Mock implementation for previews
    }

    public func updateAuthState() {
      // Mock implementation for previews
    }
  }
}
