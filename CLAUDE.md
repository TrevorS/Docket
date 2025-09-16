# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Docket** is a native macOS application for managing video meetings. This Swift project implements a multi-platform meeting widget that displays today's meetings in a floating window, enabling one-click access to join calls.

- **Platform**: macOS 15.0+ exclusively  
- **Language**: Swift 6 with strict concurrency enabled
- **Framework**: SwiftUI with EventKit integration
- **Architecture**: MVVM with @Observable pattern (modern SwiftUI)
- **Test Framework**: Swift Testing (new Apple framework) for all tests
- **Supported Platforms**: Zoom, Google Meet (extensible architecture for additional platforms)
- **Development Status**: Complete implementation with floating window and auto-refresh

## Development Commands

This project is now **CLI-driven using Swift Package Manager**. All development can happen from the command line.

### Core Commands
- **Build**: `swift build` or `make build`
- **Run**: `swift run Docket` or `make run`
- **Test**: `swift test` or `make test` (216 comprehensive tests)
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

**Complete Implementation:**
```
Sources/
├── DocketApp/                  # Minimal executable target
│   ├── main.swift              # Entry point (calls DocketApp.main())
│   └── Resources/              # App metadata (Info.plist, entitlements, assets)
└── DocketKit/                  # Core business logic library
    ├── DocketApp.swift         # SwiftUI App definition
    ├── Models/                 # Data models
    │   ├── Meeting.swift       # Meeting data with time-based states  
    │   ├── MeetingPlatform.swift # Platform enum (Zoom, Google Meet, etc.)
    │   ├── MeetingURLPattern.swift # Regex patterns for URL matching
    │   └── AppModel.swift      # Global app state (@Observable)
    ├── Managers/               # Business logic
    │   └── CalendarManager.swift # EventKit integration (@Observable)
    ├── Utilities/              # Pure functions
    │   └── MeetingURLExtractor.swift # URL extraction from calendar events
    ├── Extensions/             # Protocol adapters
    │   └── EKEvent+CalendarEventLike.swift # EventKit → protocol bridge
    └── Views/                  # Complete SwiftUI interface
        ├── ContentView.swift   # Main container with loading states
        ├── MeetingsListView.swift # Primary meeting list interface
        ├── MeetingRowView.swift # Individual meeting row component
        ├── DaySectionView.swift # Date section headers
        ├── EmptyStateView.swift # No meetings state
        ├── EmptyMeetingsDayView.swift # No meetings today state
        ├── LoadingStateView.swift # Loading indicator
        ├── RefreshStatusView.swift # Auto-refresh status indicator
        ├── PreviewData.swift   # SwiftUI preview data
        └── Components/         # Extracted, reusable components
            ├── PlatformIndicatorView.swift # Platform type display
            ├── MeetingTimeView.swift # Time range and duration
            ├── CompletedMeetingsBadge.swift # Completed meetings badge
            ├── MeetingCopyButton.swift # Copy meeting URL button
            ├── CopyConfirmationBanner.swift # Copy confirmation display
            ├── MeetingDetailsView.swift # Organizer and attendee info
            ├── RefreshStatusText.swift # Last refresh time display
            ├── RefreshStatusIcon.swift # Refresh status icon with animations
            └── MeetingJoinButton.swift # Meeting join button

Tests/
├── DocketKitTests/             # 216 comprehensive unit tests (Swift Testing)
│   ├── Components/             # Component-specific tests
│   │   ├── PlatformIndicatorTests.swift
│   │   ├── MeetingTimeTests.swift
│   │   ├── CompletedMeetingsBadgeTests.swift
│   │   ├── MeetingCopyButtonTests.swift
│   │   ├── CopyConfirmationBannerTests.swift
│   │   ├── MeetingDetailsTests.swift
│   │   ├── RefreshStatusTextTests.swift
│   │   ├── RefreshStatusIconTests.swift
│   │   └── MeetingJoinButtonTests.swift
│   └── (other test files)
└── DocketAppTests/             # Integration tests
```

### MVVM Data Flow Architecture
**Complete Implementation with Multi-Platform Support:**

```
┌─────────────────────────────────────────┐
│           SwiftUI Views ✅               │
│  • MeetingsListView (main interface)    │
│  • MeetingRowView (individual meetings) │
│  • Floating window with auto-refresh    │
└────────────────────┬────────────────────┘
                     │ @Observable
┌────────────────────▼────────────────────┐
│        CalendarManager ✅                │
│   (EventKit → Meeting pipeline)         │
│   • Calendar permission handling        │
│   • Event fetching & filtering          │
│   • Async refresh with error handling   │
│   • Auto-refresh every 60 seconds       │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│        MeetingURLExtractor ✅            │
│   (Multi-platform URL extraction)       │
│   • Priority-based field searching      │
│   • Multi-platform regex matching       │
│   • Platform detection & validation     │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│          MeetingPlatform ✅              │
│     (Platform abstraction layer)        │
│   • Zoom, Google Meet support           │
│   • Extensible for new platforms        │
│   • Platform-specific icons & colors    │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│             EventKit API                │
│         (Calendar Data Source)          │
└─────────────────────────────────────────┘
```

## Key Implementation Details

### EventKit Integration Strategy ✅ IMPLEMENTED
**Critical architectural decision**: Use EventKit instead of platform-specific APIs because:
- Platform APIs only return meetings where you are the host
- EventKit provides access to ALL calendar events including invitations  
- Works with Google Calendar, Outlook, Apple Calendar, etc.
- Can extract meeting URLs from multiple fields

### Multi-Platform URL Extraction Pipeline ✅ IMPLEMENTED
Priority-based field searching in `MeetingURLExtractor`:
1. `virtualConference.url` (modern, preferred)
2. `url` field (direct link)  
3. `location` field (common)
4. `notes` field (fallback)

**Supported Platforms:**
- **Zoom**: Standard (.zoom.us), government (.zoomgov.com), protocol (zoommtg://)
- **Google Meet**: meet.google.com URLs with automatic platform detection
- **Extensible**: Easy to add new platforms via MeetingPlatform enum

### Calendar Manager Features ✅ IMPLEMENTED
- **@Observable CalendarManager**: Single source of truth for meeting data
- **Permission handling**: Complete authorization flow with CalendarAuthState enum
- **Event processing**: EKEvent → Meeting conversion with multi-platform filtering
- **Async operations**: Modern concurrency with error handling
- **Meeting sorting**: Chronological ordering by start time
- **Auto-refresh**: Automatic updates every 60 seconds while app is active
- **Floating window**: Always-on-top window with transparent background

## Development Guidelines

### Modern Swift Patterns (Enforced)
- **@Observable pattern**: Used throughout for SwiftUI state management (not @ObservableObject)
- **Swift 6 strict concurrency**: Enabled in all targets with @preconcurrency imports where needed
- **Async/await**: All EventKit operations use modern concurrency
- **Protocol-based design**: CalendarEventLike enables clean testing and EventKit integration
- **TDD approach**: All business logic implemented with tests first (216 tests passing)

### Testing Strategy (Swift Testing Framework)
- **Unit tests**: DocketKitTests covers all business logic (models, managers, utilities)
- **Integration tests**: DocketAppTests for app-level integration
- **CLI-driven**: All tests run via `swift test` or `make test`
- **Mock objects**: Protocol-based mocking enables testing without EventKit dependencies
- **Test naming**: Uses descriptive test names with @Test("description") syntax

### SwiftUI Development Notes
- **CLI-first**: Primary development happens via command line
- **SwiftUI Previews**: Available via `make xcode` (generates Xcode project)
- **Window configuration**: Floating window (460x520) set in DocketApp.swift
- **Preview data**: Complete mock data in PreviewData.swift for UI development

## Implementation Status

### ✅ Complete Implementation
**All core functionality implemented:**
1. **Multi-Platform Support**: Zoom and Google Meet with extensible architecture
2. **Complete UI**: MeetingsListView, MeetingRowView, and supporting components
3. **Component-Based Architecture**: 9 extracted components with comprehensive testing
4. **Floating Window**: Always-on-top window with auto-refresh every 60 seconds
5. **EventKit Integration**: Full calendar access with proper permission handling
6. **Meeting Management**: One-click join functionality via NSWorkspace.open
7. **State Management**: @Observable pattern with comprehensive error handling
8. **Testing Coverage**: 216 tests covering all business logic, utilities, and components

### 🎯 Ready for Production Use
The app is feature-complete with:
- Multi-platform meeting detection and joining
- Real-time meeting status (upcoming, active, ended)
- Auto-refresh with visual status indicators
- Comprehensive error handling and loading states
- Clean, modern SwiftUI interface with modular components
- Robust testing suite (216 comprehensive tests)
- Component-based architecture for maintainability

## Critical Architecture Insights

### Why Multi-Target SwiftPM Structure?
- **DocketKit (library)**: All business logic, testable in isolation, reusable
- **DocketApp (executable)**: Minimal app wrapper, just `main.swift` + resources  
- **Benefits**: Faster builds, better testing, clear separation of concerns

### Why EventKit Over Platform APIs?
**This is a critical architectural decision**: Platform APIs (Zoom, Google Meet, etc.) only return meetings where you are the host. EventKit provides access to ALL calendar events including invitations, making the app actually useful for real-world meeting workflows.

### Testing Pattern
Uses new Swift Testing framework (not XCTest) with protocol-based mocking:
- `CalendarEventLike` protocol enables testing without EventKit  
- `MockCalendarEvent` for comprehensive URL extraction testing
- All business logic has corresponding tests (216 tests passing)
- Multi-platform testing ensures robustness across different meeting providers

### Multi-Platform Architecture
The app uses an extensible platform architecture:
- `MeetingPlatform` enum handles platform detection and display
- `MeetingURLExtractor` supports multiple URL patterns per platform
- Easy to add new platforms by extending the enum and adding URL patterns
- Platform-specific icons, colors, and display names

## Project Validation Tools

- **Format**: `make format` (swift-format)
- **Lint**: `make lint` (Swift compiler with strict concurrency)
- **Test**: `make test` (Swift Testing framework with 275 tests)
- **Build**: `make build` (Swift Package Manager)

## Project Permissions

- **Project Type**: personal
- **Direct Commits Allowed**: yes
- **Last Checked**: 2025-09-16

## Key Development Commands
```bash
# Validation cycle
make format       # Format all Swift code
make lint         # Lint with strict concurrency
make test         # Run all 275 tests
make build        # Verify compilation

# Comprehensive development cycle
swift test        # Run all 275 tests
swift build       # Verify compilation
swift run Docket  # Launch the floating widget
make app          # Create .app bundle for distribution
make install      # Install to /Applications
make xcode        # Generate Xcode project for SwiftUI previews
```