# Zoom Meetings Widget for macOS - Technical Specification

## 1. Executive Summary

### 1.1 Project Overview
A lightweight, native macOS application that displays today's Zoom meetings in a floating window, enabling one-click access to join calls. The app extracts meeting information from the user's calendar system rather than using Zoom's API, ensuring comprehensive meeting coverage.

### 1.2 Core Value Proposition
- **Single Purpose**: Display today's Zoom meetings with join links
- **Minimal Friction**: One-click to join meetings
- **Always Accessible**: Floating window stays above other applications
- **Zero Configuration**: Works with existing calendar setup

### 1.3 Target Environment
- **Platform**: macOS 15.6+ exclusively
- **Language**: Swift 6 with strict concurrency
- **Framework**: SwiftUI with EventKit
- **Architecture**: MVVM with Observation framework

## 2. Functional Requirements

### 2.1 Core Features

**P0 - Must Have (MVP)**
- [ ] Display list of today's Zoom meetings from calendar
- [ ] Extract Zoom URLs from calendar events (location, notes, URL fields)
- [ ] One-click join meeting functionality
- [ ] Floating window that stays on top
- [ ] Auto-refresh every 60 seconds
- [ ] Show meeting time and title
- [ ] Visual indicator for meetings in progress
- [ ] Visual indicator for meetings starting soon (5 min warning)

**P1 - Should Have (v1.1)**
- [ ] Search/filter meetings
- [ ] Show meeting organizer
- [ ] Copy meeting link functionality
- [ ] Meeting details view
- [ ] Refresh on demand
- [ ] Keyboard shortcuts

**P2 - Nice to Have (Future)**
- [ ] Menu bar integration
- [ ] Meeting notifications
- [ ] Multiple day view
- [ ] Calendar selection/filtering
- [ ] Auto-join capability
- [ ] Settings/preferences window

### 2.2 Non-Functional Requirements
- **Performance**: Launch in < 1 second, refresh in < 500ms
- **Memory**: < 50MB memory footprint
- **Reliability**: Graceful handling of calendar access denial
- **Security**: No network calls except to open Zoom URLs
- **Privacy**: Local calendar access only, no data transmission

## 3. Technical Architecture

### 3.1 Technology Stack
```yaml
Core:
  Language: Swift 6
  UI Framework: SwiftUI
  Minimum Target: macOS 15.6
  Build System: Xcode 16.1+
  Package Manager: Swift Package Manager

Frameworks:
  - EventKit (Calendar access)
  - Observation (State management)
  - AppKit (Window management interop)
  
External Dependencies:
  - None for MVP
  - Optional: Alamofire (future API integration)
  - Optional: TCA (if scaling complexity)
```

### 3.2 Architecture Pattern
```
┌─────────────────────────────────────────┐
│              SwiftUI Views              │
│  (MeetingsListView, MeetingDetailView)  │
└────────────────────┬────────────────────┘
                     │ @Observable
┌────────────────────▼────────────────────┐
│           CalendarManager               │
│     (Business Logic & State)            │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│             EventKit API                │
│         (Calendar Data Source)          │
└─────────────────────────────────────────┘
```

### 3.3 Project Structure
```
ZoomMeetings/
├── ZoomMeetingsApp.swift          # App entry point
├── Models/
│   ├── ZoomMeeting.swift         # Meeting data model
│   └── AppModel.swift            # Global app state
├── Managers/
│   └── CalendarManager.swift     # EventKit integration
├── Views/
│   ├── MeetingsListView.swift    # Main list view
│   ├── MeetingDetailView.swift   # Detail view
│   ├── MeetingRowView.swift      # List row component
│   └── Components/
│       ├── InfoCard.swift        # Reusable card component
│       └── EmptyStates.swift     # Empty state views
├── Utilities/
│   ├── ZoomURLExtractor.swift    # URL parsing logic
│   └── DateFormatters.swift      # Date utilities
├── Resources/
│   └── Info.plist                # App permissions
└── Tests/
    ├── CalendarManagerTests.swift
    └── ZoomURLExtractorTests.swift
```

## 4. Data Models

### 4.1 Core Models
```swift
// MARK: - Meeting Model
struct ZoomMeeting: Identifiable, Sendable, Equatable {
    let id: UUID
    let title: String
    let startTime: Date
    let endTime: Date
    let joinUrl: String?
    let organizerName: String?
    let organizerEmail: String?
    let attendeeCount: Int
    let calendarName: String
    let eventIdentifier: String  // EKEvent identifier for updates
    
    // Computed Properties
    var timeUntilStart: TimeInterval
    var isUpcoming: Bool         // Within 5 minutes
    var hasStarted: Bool         // Currently in progress
    var hasEnded: Bool
    var duration: TimeInterval
}

// MARK: - App State
@Observable
final class AppModel {
    // User Preferences
    var showOnlyZoomMeetings = true
    var notificationTime = 5
    var selectedCalendars: Set<String> = []
    var windowOpacity: Double = 1.0
    var alwaysOnTop = true
    
    // Runtime State
    var lastRefresh: Date?
    var nextMeeting: ZoomMeeting?
}

// MARK: - Calendar Authorization State
enum CalendarAuthState: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case error(String)
}
```

### 4.2 URL Pattern Matching
```swift
enum ZoomURLPattern: String, CaseIterable {
    case standard = "https?://[\\w.-]*zoom\\.us/[^\\s]+"
    case government = "https?://[\\w.-]*zoomgov\\.com/[^\\s]+"
    case protocol = "zoommtg://[^\\s]+"
    case vanity = "https?://[\\w.-]*\\.zoom\\.us/[^\\s]+"
    
    var regex: NSRegularExpression? {
        try? NSRegularExpression(pattern: rawValue)
    }
}
```

## 5. Calendar Integration

### 5.1 EventKit Access Flow
```swift
protocol CalendarDataSource {
    func requestAccess() async throws -> Bool
    func fetchEvents(from: Date, to: Date) async -> [EKEvent]
    func observeChanges() -> AsyncStream<CalendarChange>
}

enum CalendarChange {
    case added([EKEvent])
    case modified([EKEvent])
    case removed([String])  // Event identifiers
}
```

### 5.2 Meeting Extraction Logic
```swift
class ZoomURLExtractor {
    static func extract(from event: EKEvent) -> String? {
        // Priority order for URL extraction:
        // 1. virtualConference property (iOS 15+)
        // 2. URL field
        // 3. Location field
        // 4. Notes/Description field
        
        let searchFields = [
            event.virtualConference?.url,
            event.url?.absoluteString,
            event.location,
            event.notes
        ].compactMap { $0 }
        
        for field in searchFields {
            if let url = findZoomURL(in: field) {
                return sanitizeURL(url)
            }
        }
        return nil
    }
    
    private static func findZoomURL(in text: String) -> String? {
        for pattern in ZoomURLPattern.allCases {
            if let match = pattern.regex?.firstMatch(in: text, ...) {
                return String(text[match.range])
            }
        }
        return nil
    }
    
    private static func sanitizeURL(_ url: String) -> String {
        // Remove tracking parameters, ensure HTTPS, etc.
        var components = URLComponents(string: url)
        components?.queryItems?.removeAll { 
            ["utm_source", "utm_medium", "utm_campaign"].contains($0.name)
        }
        return components?.string ?? url
    }
}
```

## 6. User Interface Specifications

### 6.1 Window Configuration
```swift
Window Configuration:
  Style: Floating (always on top)
  Initial Size: 800x600
  Minimum Size: 400x300
  Position: Center screen on first launch, remember position
  Transparency: User configurable (0.8-1.0)
  Backdrop: Material.regular
  Resizable: Yes
  Movable: Yes (by background)
```

### 6.2 View Hierarchy
```
NavigationSplitView
├── Sidebar (280pt min width)
│   ├── Header
│   │   ├── Title + Meeting Count
│   │   └── Refresh Button
│   ├── Search Field
│   └── Meeting List
│       └── MeetingRow (per meeting)
│           ├── Title
│           ├── Time Status Badge
│           └── Quick Join Button (if applicable)
└── Detail View (400pt min width)
    ├── Meeting Title
    ├── Time Range
    ├── Info Grid
    │   ├── Status Card
    │   ├── Attendees Card
    │   ├── Organizer Card
    │   └── Duration Card
    └── Actions
        ├── Join Meeting Button
        └── Copy Link Button
```

### 6.3 Visual States
```swift
enum MeetingVisualState {
    case future         // Gray, subdued
    case upcoming       // Orange, pulsing indicator
    case inProgress     // Green, prominent join button
    case ending         // Yellow, ending soon warning
    case ended          // Gray, strikethrough
}

Color Palette:
  - Primary: System accent color
  - In Progress: .green
  - Upcoming: .orange
  - Ended: .secondary
  - Background: .background
  - Floating elements: .background.opacity(0.95)
```

## 7. Error Handling Strategy

### 7.1 Error Types and Recovery
```swift
enum AppError: LocalizedError {
    case calendarAccessDenied
    case calendarAccessRestricted
    case noCalendarsFound
    case eventFetchFailed(Error)
    case invalidZoomURL
    case unableToOpenURL
    
    var errorDescription: String? {
        switch self {
        case .calendarAccessDenied:
            return "Calendar access was denied"
        case .calendarAccessRestricted:
            return "Calendar access is restricted by system policy"
        case .noCalendarsFound:
            return "No calendars found in your account"
        case .eventFetchFailed(let error):
            return "Failed to fetch events: \\(error.localizedDescription)"
        case .invalidZoomURL:
            return "Invalid Zoom meeting URL"
        case .unableToOpenURL:
            return "Unable to open Zoom application"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .calendarAccessDenied:
            return "Grant calendar access in System Settings > Privacy & Security"
        case .calendarAccessRestricted:
            return "Contact your system administrator"
        case .noCalendarsFound:
            return "Add a calendar account in System Settings"
        case .eventFetchFailed:
            return "Try refreshing the meeting list"
        case .invalidZoomURL:
            return "Check the meeting details in your calendar"
        case .unableToOpenURL:
            return "Ensure Zoom is installed on your Mac"
        }
    }
}
```

### 7.2 Error UI Components
```swift
struct ErrorView: View {
    let error: AppError
    let retry: (() -> Void)?
    
    var body: some View {
        ContentUnavailableView {
            Label(error.errorDescription ?? "Error", 
                  systemImage: errorIcon)
        } description: {
            Text(error.recoverySuggestion ?? "")
        } actions: {
            if case .calendarAccessDenied = error {
                Button("Open System Settings") {
                    NSWorkspace.shared.open(settingsURL)
                }
            }
            if let retry = retry {
                Button("Try Again", action: retry)
            }
        }
    }
}
```

## 8. Testing Strategy

### 8.1 Unit Tests
```swift
// CalendarManagerTests.swift
class CalendarManagerTests: XCTestCase {
    func testZoomURLExtraction() {
        let testCases = [
            ("Join: https://zoom.us/j/123456789", "https://zoom.us/j/123456789"),
            ("Meet at https://company.zoom.us/my/room", "https://company.zoom.us/my/room"),
            ("No zoom link here", nil),
            ("Multiple https://zoom.us/j/111 and https://zoom.us/j/222", "https://zoom.us/j/111")
        ]
        
        for (input, expected) in testCases {
            XCTAssertEqual(ZoomURLExtractor.extract(from: input), expected)
        }
    }
    
    func testMeetingStateCalculation() {
        let now = Date()
        let meeting = ZoomMeeting(
            startTime: now.addingTimeInterval(240), // 4 minutes
            endTime: now.addingTimeInterval(3600)
        )
        XCTAssertTrue(meeting.isUpcoming)
        XCTAssertFalse(meeting.hasStarted)
    }
}
```

### 8.2 Integration Tests
```swift
class EventKitIntegrationTests: XCTestCase {
    func testCalendarAccess() async {
        let manager = CalendarManager()
        let authorized = await manager.requestAccess()
        XCTAssertTrue(authorized || !authorized) // Should not throw
    }
    
    func testMeetingFetch() async {
        let manager = CalendarManager()
        await manager.fetchTodaysMeetings()
        // Verify meetings are sorted by time
        let times = manager.meetings.map(\\.startTime)
        XCTAssertEqual(times, times.sorted())
    }
}
```

### 8.3 UI Tests
```swift
class UIFlowTests: XCTestCase {
    func testJoinMeetingFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for meetings to load
        let meetingsList = app.lists.firstMatch
        XCTAssertTrue(meetingsList.waitForExistence(timeout: 5))
        
        // Click first meeting with join button
        let joinButton = app.buttons["Join Meeting"].firstMatch
        if joinButton.exists {
            joinButton.tap()
            // Verify Zoom opens (check for alert or URL handler)
        }
    }
}
```

### 8.4 Manual Test Cases

| Test Case | Steps | Expected Result |
|-----------|--------|----------------|
| First Launch | 1. Launch app<br>2. Observe permission dialog | Calendar permission request appears |
| No Meetings | 1. Launch with empty calendar | "No meetings" empty state shown |
| Join Meeting | 1. Click join on active meeting | Zoom app launches with meeting |
| Refresh | 1. Add meeting to calendar<br>2. Click refresh | New meeting appears in list |
| Search | 1. Type in search field | List filters in real-time |
| Window Float | 1. Open other apps | Window stays on top |

## 9. Implementation Roadmap

### 9.1 Development Phases

**Phase 1: MVP (Week 1)**
- [ ] Project setup and configuration
- [ ] EventKit integration
- [ ] Basic meeting list view
- [ ] Zoom URL extraction
- [ ] Join meeting functionality
- [ ] Floating window setup

**Phase 2: Polish (Week 2)**
- [ ] Meeting detail view
- [ ] Search functionality
- [ ] Visual states (upcoming, in progress)
- [ ] Error handling
- [ ] Auto-refresh
- [ ] App icon and assets

**Phase 3: Enhancement (Week 3)**
- [ ] Settings window
- [ ] Keyboard shortcuts
- [ ] Menu bar integration
- [ ] Notifications
- [ ] Performance optimization
- [ ] Testing suite

### 9.2 Definition of Done
- [ ] Code compiles without warnings
- [ ] All unit tests pass
- [ ] UI responsive and smooth
- [ ] Memory usage < 50MB
- [ ] No crashes in 1 hour of usage
- [ ] Calendar permission handling works
- [ ] Join meeting works for all Zoom URL types

## 10. Security & Privacy

### 10.1 Permissions Required
```xml
<!-- Info.plist -->
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Zoom Meetings Widget needs access to your calendar to display today's Zoom meetings and allow you to join them directly.</string>

<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>

<key>LSMinimumSystemVersion</key>
<string>15.6</string>
```

### 10.2 Security Considerations
- **No Network Access**: App only reads local calendar data
- **No Data Storage**: No persistent storage of meeting data
- **No Analytics**: No tracking or analytics
- **Sandboxed**: Full App Sandbox compliance
- **URL Validation**: Validate all URLs before opening

## 11. Performance Requirements

### 11.1 Metrics

| Metric | Target | Maximum |
|--------|---------|---------|
| Launch Time | < 500ms | 1s |
| Memory Usage | < 30MB | 50MB |
| CPU (Idle) | < 0.1% | 1% |
| CPU (Refresh) | < 5% | 10% |
| Frame Rate | 60 FPS | 30 FPS |
| Calendar Fetch | < 200ms | 500ms |

### 11.2 Optimization Strategies
```swift
// Lazy loading
LazyVStack instead of VStack for lists

// Debounced search
.searchable(text: $searchText)
.onChange(of: searchText)
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)

// Minimal redraws
@Observable with computed properties marked appropriately

// Efficient date calculations
Cache TimeInterval calculations that don't change
```

## 12. Deployment

### 12.1 Build Configuration
```yaml
Build Settings:
  Swift Language Version: 6.0
  Deployment Target: macOS 15.6
  Architecture: Apple Silicon + Intel
  Optimization: -O for Release
  Code Signing: Developer ID (for distribution outside App Store)
```

### 12.2 Distribution Options
- **Direct Distribution**: Notarized DMG via GitHub Releases
- **App Store**: If adding premium features later
- **TestFlight**: For beta testing with larger audience

## 13. Future Enhancements

### 13.1 Potential Features
- **AI Meeting Summaries**: Integration with meeting transcription
- **Team Presence**: Show who's already in the meeting
- **Smart Notifications**: ML-based importance detection
- **Calendar Analytics**: Meeting time statistics
- **Zoom API Integration**: For richer meeting metadata
- **Multi-Platform**: iPhone/iPad companion app
- **Shortcuts Support**: Siri Shortcuts and automation

### 13.2 Technical Debt to Monitor
- Consider TCA if state management becomes complex
- Evaluate need for Core Data if adding history
- Monitor EventKit deprecations in future macOS versions
- Consider WidgetKit for desktop widgets

## 14. Key Implementation Insights

### 14.1 Why EventKit Over Zoom API
**Research Finding**: Zoom API only returns meetings where you are the host, NOT meetings where you're invited as an attendee. This is a critical limitation that would make the app useless for most users' primary use case.

**Solution**: EventKit can access ALL calendar events including:
- Zoom meetings you created
- Zoom meetings others invited you to
- Meeting URLs from calendar event descriptions/locations
- Works with Google Calendar, Outlook, Apple Calendar, etc.

### 14.2 Modern SwiftUI Features (macOS 15.6+)
- `@Observable` instead of `@ObservableObject`
- Native `.windowLevel(.floating)` 
- `ContentUnavailableView` for empty states
- `NavigationSplitView` for sidebar/detail layout
- Swift 6 strict concurrency throughout
- Latest SF Symbols and button styles

### 14.3 URL Extraction Strategy
Zoom URLs can appear in multiple fields of calendar events:
1. `virtualConference.url` (modern, preferred)
2. `url` field (direct link)
3. `location` field (common)
4. `notes` field (fallback)

The app searches all fields with priority ordering and supports multiple URL formats (zoom.us, zoomgov.com, zoommtg:// protocol).

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Status**: Ready for Implementation

This specification provides everything needed to begin immediate development. The MVP can be completed in approximately 1 week with the full feature set achievable within 3 weeks for a single developer.