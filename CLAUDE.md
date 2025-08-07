# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Docket** is a native macOS application for managing Zoom meetings. This is a Swift project implementing a Zoom meetings widget that displays today's meetings in a floating window, enabling one-click access to join calls.

- **Platform**: macOS 15.5+ exclusively  
- **Language**: Swift 6 (currently configured as Swift 5.0 but targeting Swift 6)
- **Framework**: SwiftUI with EventKit integration
- **Architecture**: MVVM with Observation framework (@Observable pattern)
- **Test Framework**: Swift Testing (new Testing framework) for unit tests, XCTest for UI tests

## Development Commands

This project is now **CLI-driven using Swift Package Manager**. All development can happen from the command line.

### Core Commands
- **Build**: `swift build` or `make build`
- **Run**: `swift run Docket` or `make run`
- **Test**: `swift test` or `make test`
- **Clean**: `swift package clean` or `make clean`

### App Distribution
- **Create .app bundle**: `make app` (builds app in `build/` directory)
- **Install to /Applications**: `make install`

### Development Tools
- **Format code**: `make format` (requires swift-format)
- **Lint code**: `make lint` (requires swiftlint)  
- **Generate Xcode project**: `make xcode` or `swift package generate-xcodeproj`
- **Update dependencies**: `make deps` or `swift package update`
- **Development mode**: `make dev` (auto-restart on file changes)

### Project Information
- **Show package info**: `make info` or `swift package describe`
- **Help**: `make help`

### Key Build Settings
- **Swift Version**: 6.0 (Package.swift uses swift-tools-version: 6.0)
- **Deployment Target**: macOS 15.0
- **App Sandbox**: Enabled (configured in entitlements)
- **Bundle Identifier**: org.strieber.Docket
- **Testing Framework**: Swift Testing (new framework, not XCTest for unit tests)

## Architecture and Code Structure

### Current State  
This is a **SwiftPM-based project** with a clean CLI-driven structure:

**SwiftPM Structure:**
```
Sources/
├── DocketApp/
│   ├── main.swift              # Executable entry point
│   └── Resources/              # App resources (Info.plist, assets, entitlements)
├── DocketKit/                  # Core business logic library
│   ├── DocketApp.swift         # SwiftUI App definition  
│   └── Views/
│       └── ContentView.swift   # Main UI view
Tests/
├── DocketKitTests/             # Unit tests using Swift Testing
└── DocketAppTests/             # Integration tests
```

**Key Files:**
- **main.swift**: Simple executable that calls `DocketApp.main()`  
- **DocketApp.swift**: SwiftUI `App` struct with window configuration
- **ContentView.swift**: Main UI view (currently Hello World placeholder)
- **Package.swift**: SwiftPM configuration with Swift 6.0 and strict concurrency

### Target Architecture (from plan.md)
The project is designed to implement:

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

### Planned Implementation Structure (SwiftPM)
```
Sources/DocketKit/          # All business logic goes here
├── DocketApp.swift         # SwiftUI App (already implemented)
├── Models/
│   ├── ZoomMeeting.swift   # Meeting data model
│   └── AppModel.swift      # Global app state
├── Managers/
│   └── CalendarManager.swift # EventKit integration
├── Views/
│   ├── ContentView.swift   # Main view (placeholder implemented)
│   ├── MeetingsListView.swift
│   ├── MeetingDetailView.swift
│   └── Components/
├── Utilities/
│   └── ZoomURLExtractor.swift
```

## Key Technical Requirements

### Dependencies and Frameworks
- **EventKit**: For calendar access and meeting extraction
- **SwiftUI**: For UI implementation
- **Observation**: Modern state management (@Observable instead of @ObservableObject)
- **AppKit**: For window management (floating window behavior)

### Permission Requirements
The app requires calendar access permissions:
```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Zoom Meetings Widget needs access to your calendar to display today's Zoom meetings and allow you to join them directly.</string>
```

### Core Features to Implement
- Extract Zoom URLs from calendar events (location, notes, URL fields)
- Display today's meetings in floating window
- Visual indicators for meeting status (upcoming, in progress, ended)
- One-click join meeting functionality
- Auto-refresh every 60 seconds
- NavigationSplitView layout (sidebar + detail)

## Development Guidelines

### Swift and SwiftUI Patterns
- Use `@Observable` pattern for state management (modern SwiftUI)
- Prefer Swift 6 strict concurrency patterns
- Use `async/await` for calendar operations
- Follow MVVM architecture with clear separation
- Use `ContentUnavailableView` for empty states

### Calendar Integration Strategy
**Important**: Use EventKit instead of Zoom API because:
- Zoom API only returns meetings where you are the host
- EventKit provides access to ALL calendar events including invitations
- Works with Google Calendar, Outlook, Apple Calendar, etc.
- Can extract meeting URLs from multiple fields (virtualConference, location, notes)

### URL Extraction Priority Order
1. `virtualConference.url` (modern, preferred)
2. `url` field (direct link)  
3. `location` field (common)
4. `notes` field (fallback)

### Testing Strategy
- **Unit Tests**: Use Swift Testing framework (modern, new Apple framework) for DocketKit business logic
- **Integration Tests**: Test app integration in DocketAppTests using Swift Testing
- **UI Tests**: Can add XCTest-based UI tests if needed (not currently configured)
- **CLI Testing**: All tests run via `swift test` or `make test`
- **Test-Driven Development**: Write tests before implementation

**Note**: SwiftUI Previews are not available in SwiftPM CLI development. Use `make xcode` to generate an Xcode project when you need visual UI development.

## Window Management
The app should implement:
- Floating window (stays on top)
- Initial size: 800x600, minimum: 400x300
- Material background for transparency
- Remember position between launches

## Performance Targets
- Launch time: < 1 second
- Memory usage: < 50MB
- Refresh time: < 500ms
- 60 FPS UI performance

## Implementation Sequence
Based on tasks.md, development follows this order:
1. **Foundation**: Core data models, calendar manager, URL extraction
2. **UI Layer**: Meeting list, detail views, join functionality  
3. **Enhancement**: Visual states, floating window, auto-refresh
4. **Quality**: Error handling, comprehensive testing

## CLI Development Workflow

### Daily Development
1. **Code**: Edit files in `Sources/DocketKit/` using any editor
2. **Test**: `make test` to run unit and integration tests
3. **Build**: `make build` to verify compilation
4. **Run**: `make run` to test the app
5. **Package**: `make app` to create distributable .app bundle

### GUI Development (when needed)
1. **Generate Xcode project**: `make xcode`
2. **Use Xcode for**: SwiftUI Previews, visual debugging, asset management
3. **Return to CLI**: Continue development with `swift build` etc.

### Distribution
1. **Build release**: `make app` (automatically builds with `--configuration release`)
2. **Install locally**: `make install` 
3. **Manual distribution**: Copy `build/Docket.app` to share

## Important Notes
- **CLI-First Development**: This project is optimized for command-line development using SwiftPM
- **SwiftUI Previews**: Only available via Xcode project generation (`make xcode`)
- **Modern Swift**: Uses Swift 6.0 with strict concurrency and latest SwiftUI patterns (@Observable)
- **Testing**: Uses new Swift Testing framework, not XCTest, for unit tests
- **Pure Swift**: No external dependencies planned for MVP - pure Swift/SwiftUI solution
- **EventKit Integration**: Critical for comprehensive meeting coverage (better than Zoom API)
- **macOS-Only**: Focused on macOS 15.0+ with app sandbox enabled