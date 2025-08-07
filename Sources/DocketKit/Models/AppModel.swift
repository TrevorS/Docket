// ABOUTME: Global app state management using @Observable pattern for SwiftUI integration
// ABOUTME: Manages user preferences, runtime state, and calendar authorization status

import Foundation
import Observation

// MARK: - Calendar Authorization State

/// Represents the current state of calendar access authorization
public enum CalendarAuthState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case error(String)
    
    public static func == (lhs: CalendarAuthState, rhs: CalendarAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.notDetermined, .notDetermined),
             (.authorized, .authorized),
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
    
    /// Whether to show only meetings with Zoom URLs
    public var showOnlyZoomMeetings: Bool = true
    
    /// Minutes before meeting to show notification (5 minute default)
    public var notificationTime: Int = 5
    
    /// Set of selected calendar names to display
    public var selectedCalendars: Set<String> = []
    
    /// Window opacity level (0.0 to 1.0)
    public var windowOpacity: Double = 1.0
    
    /// Whether window should always stay on top
    public var alwaysOnTop: Bool = true
    
    // MARK: - Runtime State
    
    /// Timestamp of last successful meeting refresh
    public var lastRefresh: Date?
    
    /// Next upcoming meeting (used for quick access)
    public var nextMeeting: ZoomMeeting?
    
    // MARK: - Initialization
    
    public init() {
        // All properties initialized with default values above
    }
}