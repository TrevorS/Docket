# Zoom Meetings Widget - Implementation Tasks

> **Generated from**: docs/plan.md  
> **Focus**: P0 MVP features broken into implementable chunks  
> **Architecture**: Swift 6 + SwiftUI + EventKit + MVVM pattern

## Task Overview

**Total Tasks**: 13  
**Completed**: 2 (Project Setup, Core Data Models)  
**Remaining**: 11 (URL Processing, Calendar Integration, UI Implementation)  
**Estimated Timeline**: 5-7 days remaining  
**Dependencies**: Task 3 ready to start (depends on Task 2 ✅), parallel opportunities in Tasks 5-6

## Current Implementation Status

### ✅ COMPLETED: Task 1 - Project Setup and Configuration
- SwiftPM-based project structure established
- Swift 6 with strict concurrency configured
- Calendar permissions properly set in Info.plist
- Basic DocketApp and ContentView placeholder implemented
- Swift Testing framework setup for modern testing approach
- CLI-driven development workflow with make commands

### ✅ COMPLETED: Task 2 - Core Data Models Implementation  
- **ZoomMeeting.swift**: Complete data model with time-based state calculations
- **ZoomURLPattern.swift**: Regex patterns for all 4 Zoom URL types (standard, government, protocol, vanity)
- **AppModel.swift**: @Observable class with CalendarAuthState enum for modern SwiftUI state management
- **Comprehensive Testing**: 50 tests passing with full edge case coverage
- **Swift 6 Compliance**: Full Sendable, Identifiable, Equatable conformance
- **TDD Approach**: Tests written first, implementation follows
- **Project Structure**: Clean SwiftPM-only structure (removed old Xcode project duplication)
- **UI Integration**: ContentView updated with working model demonstration
- **App Bundle**: Fully functional .app bundle that launches with visible window

### 🔄 CURRENT STATE: Models Foundation Complete
- **Branch**: feature/task-2-core-data-models (ready for merge)
- **Testing**: 50 comprehensive tests passing (zero warnings)
- **App Status**: Fully launchable GUI application with model integration demo
- **Next Priority**: Task 3 (ZoomURLExtractor utility) - builds on ZoomURLPattern foundation
- **Architecture**: MVVM foundation implemented with @Observable pattern
- **Development**: Works in both Xcode (Cmd+R with "Docket" scheme) and CLI (.app bundle)

### 📋 IMMEDIATE NEXT STEPS (Tasks 3-4: URL Processing)
1. **Task 3**: Create ZoomURLExtractor utility using ZoomURLPattern enum ✅ READY
2. **Task 4**: Build CalendarManager with EventKit integration
3. **Task 5-6**: UI implementation can begin after CalendarManager
4. **Consider**: Merge Task 2 to main branch before continuing

---

## Task 1: Project Setup and Configuration

### Description  
Initialize the project with proper configuration, dependencies, and project structure according to the technical specification. **COMPLETED** using SwiftPM instead of Xcode project structure.

### Acceptance Criteria
- [x] Create new macOS app project targeting 15.0+ (SwiftPM-based)
- [x] Configure Swift 6 with strict concurrency enabled  
- [x] Set up project folder structure as specified
- [x] Configure Info.plist with calendar permissions
- [x] Add EventKit framework access (will be added when needed)
- [x] Create basic app entry point (DocketApp.swift)

### Implementation Approach
- **Method**: SwiftPM project setup (CLI-driven development)
- **Key Decisions**: Enable App Sandbox, configure calendar usage description, Swift Testing framework
- **Architecture**: Establish MVVM foundation with @Observable pattern

### Required Components
```
Docket/ (SwiftPM Structure)
├── Sources/
│   ├── DocketApp/
│   │   ├── main.swift             # ✅ Executable entry point
│   │   └── Resources/
│   │       ├── Info.plist         # ✅ Calendar permissions configured
│   │       ├── Docket.entitlements # ✅ App sandbox enabled
│   │       └── Assets.xcassets    # ✅ App assets
│   └── DocketKit/
│       ├── DocketApp.swift        # ✅ SwiftUI App definition
│       └── Views/
│           └── ContentView.swift  # ✅ Placeholder view
├── Tests/
│   ├── DocketKitTests/            # ✅ Unit tests setup
│   └── DocketAppTests/            # ✅ Integration tests setup
└── Package.swift                  # ✅ SwiftPM configuration
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

## Task 2: Core Data Models Implementation ✅ COMPLETED

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
- `Sources/DocketKit/Models/ZoomMeeting.swift` - Core meeting data model
- `Sources/DocketKit/Models/AppModel.swift` - Global observable app state
- `Sources/DocketKit/Models/ZoomURLPattern.swift` - URL matching patterns

### Test Requirements ✅ COMPLETED
- [x] Test ZoomMeeting computed properties (isUpcoming, hasStarted, hasEnded)
- [x] Test ZoomMeeting time calculations with various scenarios
- [x] Test ZoomURLPattern regex matching for all URL types
- [x] Test AppModel state changes and observation
- [x] Test Equatable/Sendable conformance

### Final Implementation Results
- **Files Created**: 3 model files, 3 comprehensive test files
- **Test Coverage**: 50 tests passing (49 model tests + 1 integration test)
- **Code Quality**: Zero warnings, full Swift 6 strict concurrency compliance
- **Integration**: Working GUI application with model demonstration
- **Architecture**: Clean MVVM with modern @Observable pattern
- **Performance**: All tests run in <0.005 seconds
- **Branch Status**: feature/task-2-core-data-models ready for merge

### Integration Points
- Used by CalendarManager for meeting creation
- Consumed by all UI views for display
- Referenced in URL extraction utilities

### Dependencies
- **Prerequisites**: Task 1 (Project setup) ✅
- **Interdependent Tasks**: None
- **Enables**: Tasks 3, 5, 6 ✅ READY

### Major Achievements
- **Project Structure Cleanup**: Removed duplicate Xcode project files, pure SwiftPM structure
- **Modern Swift Patterns**: @Observable instead of @ObservableObject, Swift 6 strict concurrency
- **Comprehensive Regex**: 4 URL pattern types covering all Zoom URL variations (50+ test cases)
- **Time-Based Logic**: Smart meeting state calculations (5-minute upcoming window, real-time states)
- **Test-Driven Development**: Complete TDD cycle with tests written before implementation
- **GUI Integration**: Fully functional macOS app demonstrating model integration
- **Developer Experience**: Works in both Xcode (Cmd+R) and CLI (make app && open build/Docket.app)

---

## Task 3: URL Extraction Utility

### Description
Implement the ZoomURLExtractor utility class that searches calendar event fields for Zoom meeting URLs using regex patterns.

### Acceptance Criteria
- [ ] Create ZoomURLExtractor with static extract method
- [ ] Search event fields in priority order (virtualConference, URL, location, notes)
- [ ] Support all Zoom URL patterns (standard, government, protocol, vanity)
- [ ] Sanitize extracted URLs (remove tracking parameters)
- [ ] Return nil for events without Zoom URLs

### Implementation Approach
- **Method**: Test-driven with comprehensive URL pattern testing
- **Key Decisions**: Static utility class, priority-based field searching
- **Architecture**: Pure functions with regex-based pattern matching

### Required Components
- `Sources/DocketKit/Utilities/ZoomURLExtractor.swift` - Main extraction logic
- Integration with ZoomURLPattern enum from Task 2

### Test Requirements
- [ ] Test extraction from virtualConference.url field
- [ ] Test extraction from URL field
- [ ] Test extraction from location field with text
- [ ] Test extraction from notes field with mixed content
- [ ] Test all Zoom URL pattern variations
- [ ] Test URL sanitization (remove utm_* parameters)
- [ ] Test edge cases (multiple URLs, malformed URLs, no URLs)
- [ ] Test priority ordering (prefer virtualConference over location)

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
- [ ] Create CalendarManager as @Observable class
- [ ] Implement calendar access request with proper error handling
- [ ] Fetch today's events from all calendars
- [ ] Filter events to only include those with Zoom URLs
- [ ] Convert EKEvents to ZoomMeeting objects
- [ ] Sort meetings chronologically
- [ ] Provide async refresh functionality
- [ ] Handle all calendar authorization states

### Implementation Approach
- **Method**: TDD with mock EventKit interactions where possible
- **Key Decisions**: @Observable for SwiftUI integration, async/await throughout
- **Architecture**: Single source of truth for meeting data

### Required Components
- `Sources/DocketKit/Managers/CalendarManager.swift` - Main business logic class
- Integration with EventKit framework
- Uses ZoomURLExtractor from Task 3

### Test Requirements
- [ ] Test calendar access request flow
- [ ] Test meeting fetch and filtering logic
- [ ] Test EKEvent to ZoomMeeting conversion
- [ ] Test meeting sorting by start time  
- [ ] Test error handling for denied/restricted access
- [ ] Test refresh functionality
- [ ] Mock EventKit interactions for unit testing

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
- [ ] Display meetings in chronological order
- [ ] Show meeting title, time, and visual status indicators
- [ ] Handle empty state (no meetings today)
- [ ] Handle loading state during calendar fetch
- [ ] Handle error states (permission denied, fetch failed)
- [ ] Integrate with CalendarManager for data
- [ ] Support basic list selection

### Implementation Approach
- **Method**: SwiftUI List with custom row views
- **Key Decisions**: LazyVStack for performance, ContentUnavailableView for empty states
- **Architecture**: View consumes CalendarManager as @Observable

### Required Components
- `Sources/DocketKit/Views/MeetingsListView.swift` - Main list view
- `Sources/DocketKit/Views/MeetingRowView.swift` - Individual meeting row
- `Sources/DocketKit/Views/Components/EmptyStates.swift` - Empty state views

### Test Requirements
- [ ] Test list rendering with sample meetings
- [ ] Test empty state display
- [ ] Test loading state display  
- [ ] Test error state handling
- [ ] Test meeting selection behavior
- [ ] UI tests for visual layout and scrolling

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
- [ ] Display meeting title, full time range, and status
- [ ] Show organizer information and attendee count
- [ ] Display meeting duration and calendar source
- [ ] Show visual status indicators (upcoming, in progress, ended)
- [ ] Handle meetings without Zoom URLs gracefully
- [ ] Responsive layout that works in sidebar detail area

### Implementation Approach
- **Method**: SwiftUI with card-based information layout
- **Key Decisions**: Info cards for organized data presentation
- **Architecture**: Stateless view that receives ZoomMeeting object

### Required Components
- `Sources/DocketKit/Views/MeetingDetailView.swift` - Main detail view
- `Sources/DocketKit/Views/Components/InfoCard.swift` - Reusable info card component

### Test Requirements
- [ ] Test detail view rendering with various meeting states
- [ ] Test handling of meetings without Zoom URLs
- [ ] Test responsive layout at different window sizes
- [ ] Test visual status indicator accuracy
- [ ] UI tests for layout and accessibility

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
- [ ] Add "Join Meeting" button to meeting detail view
- [ ] Add quick join buttons to meeting rows for active meetings
- [ ] Open Zoom URLs using NSWorkspace.shared.open()
- [ ] Handle URL opening errors gracefully
- [ ] Validate URLs before attempting to open
- [ ] Show loading/feedback during URL opening
- [ ] Disable buttons for meetings without Zoom URLs

### Implementation Approach
- **Method**: NSWorkspace integration with error handling
- **Key Decisions**: System URL handling, graceful error messaging
- **Architecture**: Action methods in views with URL validation

### Required Components
- Action buttons in MeetingDetailView and MeetingRowView
- URL opening utility methods
- Error handling and user feedback

### Test Requirements
- [ ] Test URL opening with valid Zoom URLs
- [ ] Test error handling for invalid URLs
- [ ] Test button state management (enabled/disabled)
- [ ] Test user feedback during URL opening
- [ ] Mock NSWorkspace for unit testing

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
- [ ] Define MeetingVisualState enum with 5 states
- [ ] Implement state calculation based on current time
- [ ] Apply color coding (gray, orange, green, yellow, gray)
- [ ] Add pulsing animation for upcoming meetings
- [ ] Show prominent join button for in-progress meetings
- [ ] Apply consistent styling across list and detail views
- [ ] Update states automatically as time progresses

### Implementation Approach
- **Method**: Computed properties with SwiftUI styling modifiers
- **Key Decisions**: Time-based state calculation, consistent color palette
- **Architecture**: State logic in ZoomMeeting model, styling in views

### Required Components
- Meeting state calculation logic
- SwiftUI view modifiers for styling
- Color definitions and styling constants

### Test Requirements
- [ ] Test state calculation for all time scenarios
- [ ] Test visual styling application
- [ ] Test automatic state updates over time
- [ ] Test accessibility with color indicators
- [ ] UI tests for visual appearance

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
- [ ] Set window level to floating (.floating)
- [ ] Configure initial size (800x600) and minimum size (400x300)
- [ ] Remember window position between app launches
- [ ] Enable window resizing and moving
- [ ] Apply material background for transparency effect
- [ ] Ensure window stays on top of other applications
- [ ] Handle window focus behavior appropriately

### Implementation Approach
- **Method**: WindowGroup configuration with window level modifiers
- **Key Decisions**: Native SwiftUI window management, system integration
- **Architecture**: App-level window configuration

### Required Components
- `Sources/DocketKit/DocketApp.swift` window configuration
- Window state persistence (UserDefaults)
- WindowGroup scene setup

### Test Requirements
- [ ] Test window floating behavior
- [ ] Test window sizing and constraints
- [ ] Test position persistence across app launches
- [ ] Test window resizing behavior
- [ ] Manual testing of window management

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
- [ ] Create NavigationSplitView with 280pt minimum sidebar width
- [ ] Implement sidebar with meeting list and header
- [ ] Configure detail area with 400pt minimum width
- [ ] Handle sidebar collapse/expand behavior
- [ ] Maintain selected meeting state across layout changes
- [ ] Provide proper navigation between list and detail
- [ ] Ensure responsive layout at different window sizes

### Implementation Approach
- **Method**: SwiftUI NavigationSplitView with proper state management
- **Key Decisions**: Fixed minimum widths, persistent selection
- **Architecture**: Navigation state managed at app level

### Required Components
- Main app window layout structure
- Navigation state management
- Responsive layout logic

### Test Requirements
- [ ] Test split view layout at various window sizes
- [ ] Test sidebar behavior (collapse/expand)
- [ ] Test navigation between list and detail
- [ ] Test selection persistence
- [ ] UI tests for layout responsiveness

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
- [ ] Refresh meeting list every 60 seconds automatically
- [ ] Update meeting states (upcoming, in progress) in real-time
- [ ] Provide manual refresh capability with button
- [ ] Show refresh status/timestamp to user
- [ ] Handle refresh errors gracefully without disrupting UI
- [ ] Pause refresh when app is not active (background behavior)
- [ ] Resume refresh when app becomes active

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
- [ ] Test automatic refresh timing
- [ ] Test manual refresh functionality
- [ ] Test background/foreground refresh behavior
- [ ] Test error handling during refresh
- [ ] Test refresh status display

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
- [ ] Define AppError enum with all error cases
- [ ] Implement localized error descriptions and recovery suggestions
- [ ] Create ErrorView component with recovery actions
- [ ] Handle calendar permission denial with settings link
- [ ] Handle network/fetch errors with retry capability
- [ ] Handle URL opening errors with user feedback
- [ ] Display errors without blocking other app functionality
- [ ] Log errors appropriately for debugging

### Implementation Approach
- **Method**: Swift error handling with custom error types and UI
- **Key Decisions**: User-friendly error messages, actionable recovery options
- **Architecture**: Centralized error handling with distributed UI presentation

### Required Components
- `Sources/DocketKit/Models/AppError.swift` - Error type definitions
- `Sources/DocketKit/Views/Components/ErrorView.swift` - Error display component
- Error handling integration throughout CalendarManager

### Test Requirements
- [ ] Test all error cases and their descriptions
- [ ] Test error UI presentation and recovery actions
- [ ] Test settings link functionality
- [ ] Test retry mechanisms
- [ ] Test error logging without sensitive information

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
- [ ] Unit tests for all business logic (CalendarManager, URLExtractor)
- [ ] Unit tests for data models and computed properties
- [ ] Integration tests for EventKit interactions
- [ ] UI tests for main user flows (launch, select, join)
- [ ] Error scenario testing for all error cases
- [ ] Performance tests for memory and refresh timing
- [ ] Achieve >90% code coverage for non-UI code
- [ ] All tests pass consistently

### Implementation Approach
- **Method**: Swift Testing framework with mocking for external dependencies
- **Key Decisions**: Comprehensive coverage, mock EventKit for reliability, modern Swift Testing approach
- **Architecture**: Test-driven approach validates all requirements

### Required Components
- `Tests/DocketKitTests/CalendarManagerTests.swift` - Business logic tests
- `Tests/DocketKitTests/ZoomURLExtractorTests.swift` - URL extraction tests
- `Tests/DocketKitTests/ModelTests.swift` - Data model tests
- `Tests/DocketAppTests/UIFlowTests.swift` - End-to-end UI tests
- `Tests/DocketKitTests/ErrorHandlingTests.swift` - Error scenario tests

### Test Requirements
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All UI tests pass
- [ ] Performance benchmarks met
- [ ] Error scenarios covered
- [ ] Code coverage >90%

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