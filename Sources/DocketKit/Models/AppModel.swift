// ABOUTME: Global app state management using @Observable pattern for SwiftUI integration
// ABOUTME: Manages user preferences, runtime state, and calendar authorization status

import Foundation
import Observation

// MARK: - Calendar Authorization State

/// Represents the current state of calendar access authorization
public enum CalendarAuthState: Equatable, Sendable {
  case notDetermined
  case authorized
  case fullAccess
  case writeOnly
  case denied
  case restricted
  case error(String)

  public static func == (lhs: CalendarAuthState, rhs: CalendarAuthState) -> Bool {
    switch (lhs, rhs) {
    case (.notDetermined, .notDetermined),
      (.authorized, .authorized),
      (.fullAccess, .fullAccess),
      (.writeOnly, .writeOnly),
      (.denied, .denied),
      (.restricted, .restricted):
      return true
    case (.error(let lhsMessage), .error(let rhsMessage)):
      return lhsMessage == rhsMessage
    default:
      return false
    }
  }
}

// MARK: - App Model

/// Global observable app state for managing user preferences and runtime data
@Observable
public final class AppModel: @unchecked Sendable {

  // MARK: - User Preferences

  /// Whether to show only meetings with video meeting URLs
  public var showOnlyVideoMeetings: Bool = true

  /// Set of enabled meeting platforms to display
  public var enabledPlatforms: Set<MeetingPlatform> = [.zoom, .googleMeet]

  /// Minutes before meeting to show notification (5 minute default)
  public var notificationTime: Int = 5

  /// Set of selected calendar names to display
  public var selectedCalendars: Set<String> = []

  /// Window opacity level (0.0 to 1.0)
  public var windowOpacity: Double = 1.0

  /// Whether window should always stay on top
  private var _alwaysOnTop: Bool = false
  public var alwaysOnTop: Bool {
    get { _alwaysOnTop }
    set {
      _alwaysOnTop = newValue
      NotificationCenter.default.post(
        name: Notification.Name("alwaysOnTopDidChange"),
        object: nil,
        userInfo: ["alwaysOnTop": newValue]
      )
    }
  }

  // MARK: - Runtime State

  /// Timestamp of last successful meeting refresh
  public var lastRefresh: Date?

  /// Next upcoming meeting (used for quick access)
  public var nextMeeting: Meeting?

  // MARK: - Platform Filtering

  /// Check if a meeting platform is enabled for display
  /// - Parameter platform: The meeting platform to check
  /// - Returns: True if the platform is enabled
  public func isPlatformEnabled(_ platform: MeetingPlatform) -> Bool {
    return enabledPlatforms.contains(platform)
  }

  /// Check if a meeting should be shown based on platform filtering preferences
  /// - Parameter meeting: The meeting to check
  /// - Returns: True if the meeting should be displayed
  public func shouldShowMeeting(_ meeting: Meeting) -> Bool {
    // Always show unknown platform meetings to avoid hiding legitimate meetings
    if meeting.platform == .unknown {
      return true
    }

    return isPlatformEnabled(meeting.platform)
  }

  // MARK: - Initialization

  public init() {
    // All properties initialized with default values above
  }
}
