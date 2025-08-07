# Zoom Meetings Widget - Implementation Tasks

> **Generated from**: docs/plan.md  
> **Focus**: P0 MVP features broken into implementable chunks  
> **Architecture**: Swift 6 + SwiftUI + EventKit + MVVM pattern

## Task Overview

**Total Tasks**: 13  
**Estimated Timeline**: 7-10 days  
**Dependencies**: Sequential with some parallel opportunities

---

## Task 1: Project Setup and Configuration

### Description
Initialize the Xcode project with proper configuration, dependencies, and project structure according to the technical specification.

### Acceptance Criteria
- [x] Create new macOS app project targeting 15.6+
- [x] Configure Swift 6 with strict concurrency enabled
- [x] Set up project folder structure as specified
- [x] Configure Info.plist with calendar permissions
- [x] Add EventKit framework dependency
- [x] Create basic app entry point (ZoomMeetingsApp.swift)

### Implementation Approach
- **Method**: New Xcode project setup
- **Key Decisions**: Enable App Sandbox, configure calendar usage description
- **Architecture**: Establish MVVM foundation with @Observable pattern

### Required Components
```
ZoomMeetings/
├── ZoomMeetingsApp.swift          # App entry point
├── Models/                        # Empty folder structure
├── Managers/                      # Empty folder structure  
├── Views/                         # Empty folder structure
├── Utilities/                     # Empty folder structure
├── Resources/
│   └── Info.plist                # Calendar permissions
└── Tests/                         # Test target setup
```

### Test Requirements
- [x] Project compiles without errors
- [x] App launches and shows empty window
- [x] Calendar permission request appears on first launch
- [x] Info.plist contains correct usage descriptions

### Configuration Changes
```xml
<!-- Info.plist additions -->
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Zoom Meetings Widget needs access to your calendar to display today's Zoom meetings and allow you to join them directly.</string>
<key>LSMinimumSystemVersion</key>
<string>15.6</string>
```

### Dependencies
- **Prerequisites**: None
- **Interdependent Tasks**: None  
- **Enables**: All subsequent tasks

---

## Task 2: Core Data Models Implementation

### Description
Implement the core data structures for meetings, app state, and supporting types as defined in the technical specification.

### Acceptance Criteria
- [x] Create ZoomMeeting struct with all required properties
- [x] Implement AppModel observable class for app state
- [x] Add CalendarAuthState enum for permission states
- [x] Create ZoomURLPattern enum with regex patterns
- [x] Add computed properties for meeting states (isUpcoming, hasStarted, etc.)

### Implementation Approach
- **Method**: Test-driven development starting with model tests
- **Key Decisions**: Use @Observable instead of @ObservableObject, Sendable conformance
- **Architecture**: Pure value types with computed properties for state

### Required Components
- `Models/ZoomMeeting.swift` - Core meeting data model
- `Models/AppModel.swift` - Global observable app state
- `Models/ZoomURLPattern.swift` - URL matching patterns

### Test Requirements
- [x] Test ZoomMeeting computed properties (isUpcoming, hasStarted, hasEnded)
- [x] Test ZoomMeeting time calculations with various scenarios
- [x] Test ZoomURLPattern regex matching for all URL types
- [x] Test AppModel state changes and observation
- [x] Test Equatable/Sendable conformance

### Integration Points
- Used by CalendarManager for meeting creation
- Consumed by all UI views for display
- Referenced in URL extraction utilities

### Dependencies
- **Prerequisites**: Task 1 (Project setup)
- **Interdependent Tasks**: None
- **Enables**: Tasks 3, 5, 6

---

## Task 3: URL Extraction Utility

### Description
Implement the ZoomURLExtractor utility class that searches calendar event fields for Zoom meeting URLs using regex patterns.

### Acceptance Criteria
- [x] Create ZoomURLExtractor with static extract method
- [x] Search event fields in priority order (virtualConference, URL, location, notes)
- [x] Support all Zoom URL patterns (standard, government, protocol, vanity)
- [x] Sanitize extracted URLs (remove tracking parameters)
- [x] Return nil for events without Zoom URLs

### Implementation Approach
- **Method**: Test-driven with comprehensive URL pattern testing
- **Key Decisions**: Static utility class, priority-based field searching
- **Architecture**: Pure functions with regex-based pattern matching

### Required Components
- `Utilities/ZoomURLExtractor.swift` - Main extraction logic
- Integration with ZoomURLPattern enum from Task 2

### Test Requirements
- [x] Test extraction from virtualConference.url field
- [x] Test extraction from URL field
- [x] Test extraction from location field with text
- [x] Test extraction from notes field with mixed content
- [x] Test all Zoom URL pattern variations
- [x] Test URL sanitization (remove utm_* parameters)
- [x] Test edge cases (multiple URLs, malformed URLs, no URLs)
- [x] Test priority ordering (prefer virtualConference over location)

### Integration Points
- Called by CalendarManager during event processing
- Uses ZoomURLPattern from Task 2
- Critical for core app functionality

### Dependencies
- **Prerequisites**: Task 2 (Data models for ZoomURLPattern)
- **Interdependent Tasks**: None
- **Enables**: Task 4 (CalendarManager)

---

## Task 4: Calendar Manager Implementation

### Description
Implement the CalendarManager class that handles EventKit integration, calendar access, and meeting data management.

### Acceptance Criteria
- [x] Create CalendarManager as @Observable class
- [x] Implement calendar access request with proper error handling
- [x] Fetch today's events from all calendars
- [x] Filter events to only include those with Zoom URLs
- [x] Convert EKEvents to ZoomMeeting objects
- [x] Sort meetings chronologically
- [x] Provide async refresh functionality
- [x] Handle all calendar authorization states

### Implementation Approach
- **Method**: TDD with mock EventKit interactions where possible
- **Key Decisions**: @Observable for SwiftUI integration, async/await throughout
- **Architecture**: Single source of truth for meeting data

### Required Components
- `Managers/CalendarManager.swift` - Main business logic class
- Integration with EventKit framework
- Uses ZoomURLExtractor from Task 3

### Test Requirements
- [x] Test calendar access request flow
- [x] Test meeting fetch and filtering logic
- [x] Test EKEvent to ZoomMeeting conversion
- [x] Test meeting sorting by start time  
- [x] Test error handling for denied/restricted access
- [x] Test refresh functionality
- [x] Mock EventKit interactions for unit testing

### Integration Points
- Primary data source for all UI views
- Integrates with ZoomURLExtractor
- Uses ZoomMeeting and AppModel from Task 2

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 3 (URL extraction)
- **Interdependent Tasks**: None
- **Enables**: All UI tasks (5-10)

---

## Task 5: Basic Meeting List View

### Description
Create the core MeetingsListView that displays today's meetings in a list format with essential information.

### Acceptance Criteria
- [x] Display meetings in chronological order
- [x] Show meeting title, time, and visual status indicators
- [x] Handle empty state (no meetings today)
- [x] Handle loading state during calendar fetch
- [x] Handle error states (permission denied, fetch failed)
- [x] Integrate with CalendarManager for data
- [x] Support basic list selection

### Implementation Approach
- **Method**: SwiftUI List with custom row views
- **Key Decisions**: LazyVStack for performance, ContentUnavailableView for empty states
- **Architecture**: View consumes CalendarManager as @Observable

### Required Components
- `Views/MeetingsListView.swift` - Main list view
- `Views/MeetingRowView.swift` - Individual meeting row
- `Views/Components/EmptyStates.swift` - Empty state views

### Test Requirements
- [x] Test list rendering with sample meetings
- [x] Test empty state display
- [x] Test loading state display  
- [x] Test error state handling
- [x] Test meeting selection behavior
- [x] UI tests for visual layout and scrolling

### Integration Points
- Consumes CalendarManager from Task 4
- Uses ZoomMeeting model from Task 2
- Will integrate with detail view in Task 6

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 4 (CalendarManager)
- **Interdependent Tasks**: Task 6 (Detail view for navigation)
- **Enables**: Task 7 (Join meeting functionality)

---

## Task 6: Meeting Detail View

### Description
Implement the detailed view that shows comprehensive meeting information and actions when a meeting is selected.

### Acceptance Criteria
- [x] Display meeting title, full time range, and status
- [x] Show organizer information and attendee count
- [x] Display meeting duration and calendar source
- [x] Show visual status indicators (upcoming, in progress, ended)
- [x] Handle meetings without Zoom URLs gracefully
- [x] Responsive layout that works in sidebar detail area

### Implementation Approach
- **Method**: SwiftUI with card-based information layout
- **Key Decisions**: Info cards for organized data presentation
- **Architecture**: Stateless view that receives ZoomMeeting object

### Required Components
- `Views/MeetingDetailView.swift` - Main detail view
- `Views/Components/InfoCard.swift` - Reusable info card component

### Test Requirements
- [x] Test detail view rendering with various meeting states
- [x] Test handling of meetings without Zoom URLs
- [x] Test responsive layout at different window sizes
- [x] Test visual status indicator accuracy
- [x] UI tests for layout and accessibility

### Integration Points
- Selected from MeetingsListView (Task 5)
- Uses ZoomMeeting model from Task 2
- Will host action buttons from Task 7

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 5 (List view for navigation)
- **Interdependent Tasks**: Task 5 (Navigation integration)
- **Enables**: Task 7 (Action buttons), Task 9 (Split view layout)

---

## Task 7: Join Meeting Functionality

### Description
Implement the core feature that allows users to join Zoom meetings by opening the Zoom URL in the system's default handler.

### Acceptance Criteria
- [x] Add "Join Meeting" button to meeting detail view
- [x] Add quick join buttons to meeting rows for active meetings
- [x] Open Zoom URLs using NSWorkspace.shared.open()
- [x] Handle URL opening errors gracefully
- [x] Validate URLs before attempting to open
- [x] Show loading/feedback during URL opening
- [x] Disable buttons for meetings without Zoom URLs

### Implementation Approach
- **Method**: NSWorkspace integration with error handling
- **Key Decisions**: System URL handling, graceful error messaging
- **Architecture**: Action methods in views with URL validation

### Required Components
- Action buttons in MeetingDetailView and MeetingRowView
- URL opening utility methods
- Error handling and user feedback

### Test Requirements
- [x] Test URL opening with valid Zoom URLs
- [x] Test error handling for invalid URLs
- [x] Test button state management (enabled/disabled)
- [x] Test user feedback during URL opening
- [x] Mock NSWorkspace for unit testing

### Integration Points
- Buttons added to views from Tasks 5 and 6
- Uses ZoomMeeting URLs from Task 2
- Integrates with error handling system

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 5 (List view), Task 6 (Detail view)
- **Interdependent Tasks**: Tasks 5, 6 (UI integration)
- **Enables**: Core app functionality

---

## Task 8: Visual Meeting States

### Description
Implement visual indicators that show meeting status (future, upcoming, in progress, ending, ended) with appropriate colors and styling.

### Acceptance Criteria
- [x] Define MeetingVisualState enum with 5 states
- [x] Implement state calculation based on current time
- [x] Apply color coding (gray, orange, green, yellow, gray)
- [x] Add pulsing animation for upcoming meetings
- [x] Show prominent join button for in-progress meetings
- [x] Apply consistent styling across list and detail views
- [x] Update states automatically as time progresses

### Implementation Approach
- **Method**: Computed properties with SwiftUI styling modifiers
- **Key Decisions**: Time-based state calculation, consistent color palette
- **Architecture**: State logic in ZoomMeeting model, styling in views

### Required Components
- Meeting state calculation logic
- SwiftUI view modifiers for styling
- Color definitions and styling constants

### Test Requirements
- [x] Test state calculation for all time scenarios
- [x] Test visual styling application
- [x] Test automatic state updates over time
- [x] Test accessibility with color indicators
- [x] UI tests for visual appearance

### Integration Points
- Extends ZoomMeeting from Task 2
- Applied in views from Tasks 5 and 6
- Uses time calculations for dynamic updates

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 5 (List view), Task 6 (Detail view)
- **Interdependent Tasks**: Tasks 5, 6 (Visual integration)
- **Enables**: Enhanced user experience

---

## Task 9: Floating Window Setup

### Description
Configure the main application window to float above other applications and provide the proper window management behavior.

### Acceptance Criteria
- [x] Set window level to floating (.floating)
- [x] Configure initial size (800x600) and minimum size (400x300)
- [x] Remember window position between app launches
- [x] Enable window resizing and moving
- [x] Apply material background for transparency effect
- [x] Ensure window stays on top of other applications
- [x] Handle window focus behavior appropriately

### Implementation Approach
- **Method**: WindowGroup configuration with window level modifiers
- **Key Decisions**: Native SwiftUI window management, system integration
- **Architecture**: App-level window configuration

### Required Components
- ZoomMeetingsApp.swift window configuration
- Window state persistence (UserDefaults)
- WindowGroup scene setup

### Test Requirements
- [x] Test window floating behavior
- [x] Test window sizing and constraints
- [x] Test position persistence across app launches
- [x] Test window resizing behavior
- [x] Manual testing of window management

### Integration Points
- Hosts all UI components from previous tasks
- Integrates with system window management
- Foundation for user experience

### Dependencies
- **Prerequisites**: Task 1 (Project setup), UI tasks (5-8)
- **Interdependent Tasks**: None
- **Enables**: Task 10 (Split view layout)

---

## Task 10: Split View Layout Implementation

### Description
Implement the NavigationSplitView layout with sidebar for meeting list and detail area for meeting information.

### Acceptance Criteria
- [x] Create NavigationSplitView with 280pt minimum sidebar width
- [x] Implement sidebar with meeting list and header
- [x] Configure detail area with 400pt minimum width
- [x] Handle sidebar collapse/expand behavior
- [x] Maintain selected meeting state across layout changes
- [x] Provide proper navigation between list and detail
- [x] Ensure responsive layout at different window sizes

### Implementation Approach
- **Method**: SwiftUI NavigationSplitView with proper state management
- **Key Decisions**: Fixed minimum widths, persistent selection
- **Architecture**: Navigation state managed at app level

### Required Components
- Main app window layout structure
- Navigation state management
- Responsive layout logic

### Test Requirements
- [x] Test split view layout at various window sizes
- [x] Test sidebar behavior (collapse/expand)
- [x] Test navigation between list and detail
- [x] Test selection persistence
- [x] UI tests for layout responsiveness

### Integration Points
- Hosts MeetingsListView from Task 5
- Hosts MeetingDetailView from Task 6
- Integrates with floating window from Task 9

### Dependencies
- **Prerequisites**: Task 5 (List view), Task 6 (Detail view), Task 9 (Window setup)
- **Interdependent Tasks**: Tasks 5, 6 (Layout integration)
- **Enables**: Complete UI experience

---

## Task 11: Auto-Refresh Implementation

### Description
Implement automatic refreshing of meeting data every 60 seconds to keep the display current throughout the day.

### Acceptance Criteria
- [x] Refresh meeting list every 60 seconds automatically
- [x] Update meeting states (upcoming, in progress) in real-time
- [x] Provide manual refresh capability with button
- [x] Show refresh status/timestamp to user
- [x] Handle refresh errors gracefully without disrupting UI
- [x] Pause refresh when app is not active (background behavior)
- [x] Resume refresh when app becomes active

### Implementation Approach
- **Method**: Timer-based refresh with background/foreground state handling
- **Key Decisions**: 60-second interval, pause in background for efficiency
- **Architecture**: Background task management in CalendarManager

### Required Components
- Timer management in CalendarManager
- App state monitoring (active/inactive)
- Manual refresh UI controls
- Refresh status indicators

### Test Requirements
- [x] Test automatic refresh timing
- [x] Test manual refresh functionality
- [x] Test background/foreground refresh behavior
- [x] Test error handling during refresh
- [x] Test refresh status display

### Integration Points
- Extends CalendarManager from Task 4
- Updates UI views from Tasks 5 and 6
- Integrates with app lifecycle management

### Dependencies
- **Prerequisites**: Task 4 (CalendarManager), Task 5 (List view)
- **Interdependent Tasks**: None
- **Enables**: Dynamic, current meeting data

---

## Task 12: Error Handling System

### Description
Implement comprehensive error handling for calendar access, event fetching, and URL operations with user-friendly messaging.

### Acceptance Criteria
- [x] Define AppError enum with all error cases
- [x] Implement localized error descriptions and recovery suggestions
- [x] Create ErrorView component with recovery actions
- [x] Handle calendar permission denial with settings link
- [x] Handle network/fetch errors with retry capability
- [x] Handle URL opening errors with user feedback
- [x] Display errors without blocking other app functionality
- [x] Log errors appropriately for debugging

### Implementation Approach
- **Method**: Swift error handling with custom error types and UI
- **Key Decisions**: User-friendly error messages, actionable recovery options
- **Architecture**: Centralized error handling with distributed UI presentation

### Required Components
- `Models/AppError.swift` - Error type definitions
- `Views/Components/ErrorView.swift` - Error display component
- Error handling integration throughout CalendarManager

### Test Requirements
- [x] Test all error cases and their descriptions
- [x] Test error UI presentation and recovery actions
- [x] Test settings link functionality
- [x] Test retry mechanisms
- [x] Test error logging without sensitive information

### Integration Points
- Used by CalendarManager from Task 4
- Displayed in views from Tasks 5 and 6
- Integrates with system settings for permissions

### Dependencies
- **Prerequisites**: Task 2 (Data models), Task 4 (CalendarManager), Task 5 (List view)
- **Interdependent Tasks**: All UI tasks for error display
- **Enables**: Robust user experience

---

## Task 13: Testing Suite Completion

### Description
Complete the testing suite with comprehensive unit, integration, and UI tests covering all core functionality.

### Acceptance Criteria
- [x] Unit tests for all business logic (CalendarManager, URLExtractor)
- [x] Unit tests for data models and computed properties
- [x] Integration tests for EventKit interactions
- [x] UI tests for main user flows (launch, select, join)
- [x] Error scenario testing for all error cases
- [x] Performance tests for memory and refresh timing
- [x] Achieve >90% code coverage for non-UI code
- [x] All tests pass consistently

### Implementation Approach
- **Method**: XCTest framework with mocking for external dependencies
- **Key Decisions**: Comprehensive coverage, mock EventKit for reliability
- **Architecture**: Test-driven approach validates all requirements

### Required Components
- `Tests/CalendarManagerTests.swift` - Business logic tests
- `Tests/ZoomURLExtractorTests.swift` - URL extraction tests
- `Tests/ModelTests.swift` - Data model tests
- `Tests/UIFlowTests.swift` - End-to-end UI tests
- `Tests/ErrorHandlingTests.swift` - Error scenario tests

### Test Requirements
- [x] All unit tests pass
- [x] All integration tests pass
- [x] All UI tests pass
- [x] Performance benchmarks met
- [x] Error scenarios covered
- [x] Code coverage >90%

### Integration Points
- Tests all components from Tasks 1-12
- Validates complete application behavior
- Ensures quality and reliability

### Dependencies
- **Prerequisites**: All previous tasks (1-12)
- **Interdependent Tasks**: None
- **Enables**: Production-ready application

---

## Implementation Notes

### Development Sequence
1. **Foundation (Tasks 1-4)**: Core infrastructure and business logic
2. **UI Layer (Tasks 5-7)**: User interface and core interaction
3. **Enhancement (Tasks 8-11)**: Polish and advanced features
4. **Quality (Tasks 12-13)**: Error handling and comprehensive testing

### Parallel Opportunities
- Tasks 2 and 3 can be developed in parallel after Task 1
- Tasks 5 and 6 can be developed in parallel after Task 4
- Tasks 8, 9, and 11 can be developed in parallel after UI tasks

### Key Architectural Decisions Validated
- **EventKit Integration**: Confirmed as the right approach for comprehensive meeting access
- **@Observable Pattern**: Modern SwiftUI state management
- **MVVM Architecture**: Clean separation of concerns
- **Test-Driven Development**: Each task includes comprehensive testing requirements

### Performance Targets
- Launch time: < 1 second
- Memory usage: < 50MB  
- Refresh time: < 500ms
- 60 FPS UI performance

This task breakdown provides a clear implementation path from initial setup to production-ready application, with each task being independently testable and buildable.