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

  /// Whether to hide completed meetings 5 minutes after they end
  public var hideCompletedMeetingsAfter5Min: Bool = true

  // MARK: - Initialization

  public init() {
    // All properties initialized with default values above
  }
}
