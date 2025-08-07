# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Docket** is a native macOS application for managing Zoom meetings. This is a Swift project implementing a Zoom meetings widget that displays today's meetings in a floating window, enabling one-click access to join calls.

- **Platform**: macOS 15.0+ exclusively  
- **Language**: Swift 6 with strict concurrency enabled
- **Framework**: SwiftUI with EventKit integration
- **Architecture**: MVVM with @Observable pattern (modern SwiftUI)
- **Test Framework**: Swift Testing (new Apple framework) for all tests
- **Development Status**: Foundation complete (Tasks 1-4), UI layer ready for implementation

## Development Commands

This project is now **CLI-driven using Swift Package Manager**. All development can happen from the command line.

### Core Commands
- **Build**: `swift build` or `make build`
- **Run**: `swift run Docket` or `make run`
- **Test**: `swift test` or `make test` (73 comprehensive tests)
- **Clean**: `swift package clean` or `make clean`

### App Distribution  
- **Create .app bundle**: `make app` (builds release version to `build/` directory)
- **Install to /Applications**: `make install`

### Code Quality
- **Format code**: `make format` (requires swift-format)
- **Lint code**: `make lint` (Swift compiler warnings with strict concurrency)

### Development Tools
- **Open in Xcode**: `make xcode` or `xed .` (for SwiftUI previews and visual debugging)
- **Help**: `make help`

### Key Build Settings
- **Swift Version**: 6.0 (Package.swift uses swift-tools-version: 6.0)
- **Deployment Target**: macOS 15.0
- **App Sandbox**: Enabled (configured in entitlements)
- **Bundle Identifier**: org.strieber.Docket
- **Testing Framework**: Swift Testing (new framework, not XCTest for unit tests)

## Architecture and Code Structure

### Multi-Target SwiftPM Architecture
This project uses a **library + executable** pattern for clean separation:

**Current Implementation (Tasks 1-4 Complete):**
```
Sources/
├── DocketApp/                  # Minimal executable target
│   ├── main.swift              # Entry point (calls DocketApp.main())
│   └── Resources/              # App metadata (Info.plist, entitlements, assets)
└── DocketKit/                  # Core business logic library
    ├── DocketApp.swift         # SwiftUI App definition
    ├── Models/                 # Data models
    │   ├── ZoomMeeting.swift   # Meeting data with time-based states  
    │   ├── AppModel.swift      # Global app state (@Observable)
    │   └── ZoomURLPattern.swift # Regex patterns for Zoom URL matching
    ├── Managers/               # Business logic
    │   └── CalendarManager.swift # EventKit integration (@Observable)
    ├── Utilities/              # Pure functions
    │   └── ZoomURLExtractor.swift # URL extraction from calendar events
    ├── Extensions/             # Protocol adapters
    │   └── EKEvent+CalendarEventLike.swift # EventKit → protocol bridge
    └── Views/
        └── ContentView.swift   # Main UI (currently displays Task 4 status)

Tests/
├── DocketKitTests/             # 73 comprehensive unit tests (Swift Testing)
└── DocketAppTests/             # Integration tests
```

### MVVM Data Flow Architecture
**Implemented** (Tasks 1-4) and ready for UI layer:

```
┌─────────────────────────────────────────┐
│              SwiftUI Views              │
│           (Tasks 5-7: TODO)             │
└────────────────────┬────────────────────┘
                     │ @Observable
┌────────────────────▼────────────────────┐
│        CalendarManager ✅                │
│   (EventKit → ZoomMeeting pipeline)     │
│   • Calendar permission handling        │
│   • Event fetching & filtering          │
│   • Async refresh with error handling   │  
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│          ZoomURLExtractor ✅             │
│     (URL extraction from events)        │
│   • Priority-based field searching      │
│   • Multi-pattern regex matching        │
│   • URL sanitization                    │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│             EventKit API                │
│         (Calendar Data Source)          │
└─────────────────────────────────────────┘
```

## Key Implementation Details

### EventKit Integration Strategy ✅ IMPLEMENTED
**Critical architectural decision**: Use EventKit instead of Zoom API because:
- Zoom API only returns meetings where you are the host
- EventKit provides access to ALL calendar events including invitations  
- Works with Google Calendar, Outlook, Apple Calendar, etc.
- Can extract meeting URLs from multiple fields

### URL Extraction Pipeline ✅ IMPLEMENTED
Priority-based field searching in `ZoomURLExtractor`:
1. `virtualConference.url` (modern, preferred)
2. `url` field (direct link)  
3. `location` field (common)
4. `notes` field (fallback)

Supports all Zoom URL patterns: standard, government, protocol, vanity domains.

### Calendar Manager Features ✅ IMPLEMENTED
- **@Observable CalendarManager**: Single source of truth for meeting data
- **Permission handling**: Complete authorization flow with CalendarAuthState enum
- **Event processing**: EKEvent → ZoomMeeting conversion with filtering
- **Async operations**: Modern concurrency with error handling
- **Meeting sorting**: Chronological ordering by start time

## Development Guidelines

### Modern Swift Patterns (Enforced)
- **@Observable pattern**: Used throughout for SwiftUI state management (not @ObservableObject)
- **Swift 6 strict concurrency**: Enabled in all targets with @preconcurrency imports where needed
- **Async/await**: All EventKit operations use modern concurrency
- **Protocol-based design**: CalendarEventLike enables clean testing and EventKit integration
- **TDD approach**: All business logic implemented with tests first (73 tests passing)

### Testing Strategy (Swift Testing Framework)
- **Unit tests**: DocketKitTests covers all business logic (models, managers, utilities)
- **Integration tests**: DocketAppTests for app-level integration
- **CLI-driven**: All tests run via `swift test` or `make test`
- **Mock objects**: Protocol-based mocking enables testing without EventKit dependencies
- **Test naming**: Uses descriptive test names with @Test("description") syntax

### SwiftUI Development Notes
- **CLI-first**: Primary development happens via command line
- **SwiftUI Previews**: Only available via `make xcode` (generates Xcode project)
- **Window configuration**: Set in DocketApp.swift (currently 700x650 to display Task 4 info)

## Implementation Status & Next Steps

### Completed Foundation (Tasks 1-4) ✅
1. **Project Setup**: SwiftPM structure, Swift 6, calendar permissions
2. **Data Models**: ZoomMeeting, AppModel, ZoomURLPattern with comprehensive tests
3. **URL Extraction**: ZoomURLExtractor with priority-based field searching  
4. **Calendar Integration**: CalendarManager with complete EventKit pipeline

### Ready for Implementation (Tasks 5-7)
**Next immediate tasks for UI layer:**
- Task 5: MeetingsListView using CalendarManager as data source
- Task 6: MeetingDetailView for selected meeting display  
- Task 7: Join meeting functionality (NSWorkspace.open)

### Future Enhancement Tasks (8-13)
- Visual meeting states, floating window, auto-refresh, error handling, testing completion

## Critical Architecture Insights

### Why Multi-Target SwiftPM Structure?
- **DocketKit (library)**: All business logic, testable in isolation, reusable
- **DocketApp (executable)**: Minimal app wrapper, just `main.swift` + resources  
- **Benefits**: Faster builds, better testing, clear separation of concerns

### Why EventKit Over Zoom API?
**This is a critical architectural decision**: Zoom API only returns meetings where you are the host. EventKit provides access to ALL calendar events including invitations, making the app actually useful.

### Testing Pattern
Uses new Swift Testing framework (not XCTest) with protocol-based mocking:
- `CalendarEventLike` protocol enables testing without EventKit  
- `MockCalendarEvent` for comprehensive URL extraction testing
- All business logic has corresponding tests (73 tests passing)

### Branch Strategy
- `feature/task-4-calendar-manager`: Current branch with foundation complete
- Foundation phase (Tasks 1-4) ready for integration to main
- Next development: UI layer implementation (Tasks 5-7)

## Key Development Commands
```bash
# Comprehensive development cycle
swift test        # Run all 73 tests
swift build       # Verify compilation  
swift run Docket  # Test the app
make app          # Create .app bundle
make xcode        # Generate Xcode project for SwiftUI previews
```