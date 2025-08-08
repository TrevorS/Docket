# Component Extraction Plan

## Overview

This document outlines the systematic extraction of UI components from larger views into smaller, focused, testable components. Each component will have:

- **Single responsibility** - focused logic and clear purpose
- **Comprehensive tests** - covering all states and edge cases  
- **Rich previews** - showing all configurations and states
- **Clean interfaces** - minimal dependencies and clear APIs
- **Proper documentation** - ABOUTME comments and inline docs

## Extraction Order & Dependencies

We'll extract components in order of complexity and impact, ensuring dependencies are handled properly:

### Phase 1: Independent Components (No Dependencies)

1. **PlatformIndicatorView** - Simple, no dependencies
2. **MeetingTimeView** - Self-contained time logic
3. **CompletedMeetingsBadge** - Simple formatting logic

### Phase 2: Interactive Components (Moderate Dependencies)  

4. **MeetingCopyButton** - Hover states, copy logic
5. **CopyConfirmationBanner** - Animation and timing logic
6. **MeetingDetailsView** - Organizer/attendee display

### Phase 3: Complex Stateful Components (High Dependencies)

7. **RefreshStatusText** - Date formatting and state handling
8. **RefreshStatusIcon** - Complex animation and state machine
9. **MeetingJoinButton** - Most complex - hover, states, actions

---

## Component Specifications

### 1. PlatformIndicatorView

**Priority**: HIGH (Phase 1 - Independent)
**Complexity**: LOW

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 103-127 (`platformIndicator`, `platformColor`)

#### Logic to Extract

```swift
// View logic
private var platformIndicator: some View { ... }
private var platformColor: Color { ... }
```

#### New Component Interface

```swift
struct PlatformIndicatorView: View {
  let platform: MeetingPlatform
  
  var body: some View { ... }
}
```

#### Tests Required

- `PlatformIndicatorTests.swift`
  - ✅ All platform types render correctly (Zoom, Google Meet, Unknown)
  - ✅ Correct colors for each platform (blue, green, gray)
  - ✅ Correct icons for each platform
  - ✅ Proper styling and padding
  - ✅ Text displays correct short names

#### Previews Required

- `#Preview("Zoom Platform")`
- `#Preview("Google Meet Platform")`
- `#Preview("Unknown Platform")`
- `#Preview("All Platforms")` - Side by side comparison

#### Integration

- Update `MeetingRowView` to use `PlatformIndicatorView(platform: meeting.platform)`

---

### 2. MeetingTimeView

**Priority**: HIGH (Phase 1 - Independent)
**Complexity**: MEDIUM

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 44-63 (`meetingTime`), 151-161 (`timeColor`), 254-287 (helper properties)

#### Logic to Extract

```swift
// View logic
private var meetingTime: some View { ... }
private var timeColor: Color { ... }
private var timeRangeText: String { ... }
private var durationText: String? { ... }
```

#### New Component Interface

```swift
struct MeetingTimeView: View {
  let meeting: Meeting
  
  var body: some View { ... }
}
```

#### Tests Required

- `MeetingTimeTests.swift`
  - ✅ Time range formatting (start - end)
  - ✅ Duration calculation and display (minutes, hours, mixed)
  - ✅ Color logic for different meeting states (ended, started, upcoming, future)
  - ✅ Edge cases: zero duration, negative duration, very long meetings
  - ✅ Date formatting consistency

#### Previews Required  

- `#Preview("Upcoming Meeting")`
- `#Preview("Active Meeting")`
- `#Preview("Ended Meeting")`
- `#Preview("Short Meeting (15m)")`
- `#Preview("Long Meeting (2h 30m)")`
- `#Preview("All Day Meeting")`

#### Integration

- Update `MeetingRowView` to use `MeetingTimeView(meeting: meeting)`

---

### 3. CompletedMeetingsBadge

**Priority**: MEDIUM (Phase 1 - Independent)  
**Complexity**: LOW

#### Current Location

- File: `DaySectionView.swift`
- Lines: 123-133 (`completedBadge`)

#### Logic to Extract

```swift
// View logic
private var completedBadge: some View { ... }
```

#### New Component Interface

```swift
struct CompletedMeetingsBadge: View {
  let meetingCount: Int
  
  var body: some View { ... }
}
```

#### Tests Required

- `CompletedMeetingsBadgeTests.swift`
  - ✅ Correct count display
  - ✅ Singular vs plural text ("meeting" vs "meetings")
  - ✅ Proper styling (green checkmark, secondary text)
  - ✅ Edge cases: 0 meetings, 1 meeting, many meetings

#### Previews Required

- `#Preview("Single Meeting")`
- `#Preview("Multiple Meetings")`  
- `#Preview("Many Meetings (10+)")`

#### Integration

- Update `DaySectionView` to use `CompletedMeetingsBadge(meetingCount: meetings.count)`

---

### 4. MeetingCopyButton

**Priority**: HIGH (Phase 2 - Interactive)
**Complexity**: MEDIUM

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 165-176 (`copyLinkButton`), 257-273 (`copyMeetingLink`)
- State: `isCopyButtonHovered`

#### Logic to Extract

```swift
// View and state logic
@State private var isCopyButtonHovered = false
private var copyLinkButton: some View { ... }
private func copyMeetingLink() { ... }
```

#### New Component Interface

```swift
struct MeetingCopyButton: View {
  let meetingUrl: String?
  let onCopy: (String) -> Void
  
  var body: some View { ... }
}
```

#### Tests Required

- `MeetingCopyButtonTests.swift`
  - ✅ Hover state tracking
  - ✅ Visual feedback (scale, color changes)
  - ✅ Copy action triggering
  - ✅ Tooltip display
  - ✅ Disabled state when no URL
  - ✅ Animation timing

#### Previews Required

- `#Preview("Normal State")`
- `#Preview("Hovered State")`
- `#Preview("With Animation")`

#### Integration

- Update `MeetingRowView` to use `MeetingCopyButton` with copy handler
- Move copy confirmation logic up to parent

---

### 5. CopyConfirmationBanner

**Priority**: MEDIUM (Phase 2 - Interactive)
**Complexity**: MEDIUM

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 195-208 (`copyConfirmationBanner`)
- State: `showCopyConfirmation`

#### Logic to Extract

```swift
// View and animation logic
@State private var showCopyConfirmation = false
private var copyConfirmationBanner: some View { ... }
// Animation timing logic
```

#### New Component Interface

```swift
struct CopyConfirmationBanner: View {
  @Binding var isVisible: Bool
  let message: String
  let autohideDuration: TimeInterval = 2.0
  
  var body: some View { ... }
}
```

#### Tests Required

- `CopyConfirmationBannerTests.swift`
  - ✅ Show/hide animations
  - ✅ Auto-hide timing  
  - ✅ Message display
  - ✅ Styling consistency
  - ✅ Transition effects

#### Previews Required

- `#Preview("Visible Banner")`
- `#Preview("Hidden Banner")`
- `#Preview("Animation Demo")` - Shows show/hide cycle

#### Integration

- Update `MeetingRowView` to use `CopyConfirmationBanner` with binding

---

### 6. MeetingDetailsView

**Priority**: MEDIUM (Phase 2 - Interactive)
**Complexity**: LOW

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 65-101 (`meetingDetails`)

#### Logic to Extract

```swift
// View logic for organizer and attendee display
private var meetingDetails: some View { ... }
```

#### New Component Interface

```swift
struct MeetingDetailsView: View {
  let organizerName: String?
  let attendeeCount: Int
  
  var body: some View { ... }
}
```

#### Tests Required

- `MeetingDetailsTests.swift`
  - ✅ With organizer name
  - ✅ Without organizer name
  - ✅ Various attendee counts (0, 1, many)
  - ✅ Proper formatting and layout
  - ✅ Conditional display logic

#### Previews Required

- `#Preview("With Organizer & Attendees")`
- `#Preview("Organizer Only")`
- `#Preview("Attendees Only")`
- `#Preview("Minimal Info")`

#### Integration

- Update `MeetingRowView` to use `MeetingDetailsView`

---

### 7. RefreshStatusText

**Priority**: MEDIUM (Phase 3 - Complex)
**Complexity**: MEDIUM

#### Current Location

- File: `RefreshStatusView.swift`
- Lines: 43-51 (conditional text display)

#### Logic to Extract

```swift
// Text display and formatting logic
if let lastRefresh = lastRefresh {
  Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
} else {
  Text("Not refreshed yet")
}
```

#### New Component Interface

```swift
struct RefreshStatusText: View {
  let lastRefresh: Date?
  
  var body: some View { ... }
}
```

#### Tests Required

- `RefreshStatusTextTests.swift`
  - ✅ Various refresh dates
  - ✅ Nil state handling  
  - ✅ Date formatting consistency
  - ✅ Text styling
  - ✅ Recent vs old refresh times

#### Previews Required

- `#Preview("Recent Refresh")`
- `#Preview("Old Refresh")`
- `#Preview("No Refresh Yet")`

#### Integration

- Update `RefreshStatusView` to use `RefreshStatusText(lastRefresh: lastRefresh)`

---

### 8. RefreshStatusIcon

**Priority**: HIGH (Phase 3 - Complex)
**Complexity**: HIGH

#### Current Location

- File: `RefreshStatusView.swift`
- Lines: 36-42 (icon display), 80-157 (state management and animation logic)
- State: `isPulsing`, `isPostRefreshFading`, `fadeTimer`

#### Logic to Extract

```swift
// Complex state management and animation
@State private var isPulsing = false
@State private var isPostRefreshFading = false  
@State private var fadeTimer: Timer?

private var iconName: String { ... }
private var iconColor: Color { ... }
private func startPulsingIfNeeded() { ... }
private func handleRefreshComplete() { ... }
```

#### New Component Interface

```swift
struct RefreshStatusIcon: View {
  let isRefreshing: Bool
  let isAutoRefreshActive: Bool
  let isAutoRefreshEnabled: Bool
  let lastRefresh: Date?
  
  var body: some View { ... }
}
```

#### Tests Required

- `RefreshStatusIconTests.swift`
  - ✅ Icon switching logic (clock vs pause)
  - ✅ Color transitions for all states
  - ✅ Animation state management
  - ✅ Timer lifecycle management
  - ✅ Breathing animation behavior
  - ✅ Fade-out timing and transitions
  - ✅ Paused state (no animation)

#### Previews Required

- `#Preview("Normal Clock")`
- `#Preview("Paused State")`
- `#Preview("Breathing Animation")`
- `#Preview("Fade-out Animation")`
- `#Preview("All States")` - Grid of different states

#### Integration

- Update `RefreshStatusView` to use `RefreshStatusIcon`
- Handle `handleRefreshComplete()` callback from parent

---

### 9. MeetingJoinButton

**Priority**: HIGH (Phase 3 - Complex)
**Complexity**: HIGHEST

#### Current Location

- File: `MeetingRowView.swift`
- Lines: 178-202 (`joinButton`), 210-250 (related computed properties), 275-301 (`joinMeeting`)
- State: `isJoinButtonHovered`, `isJoining`

#### Logic to Extract

```swift
// Complex interactive logic
@State private var isJoining = false
@State private var isJoinButtonHovered = false

private var joinButton: some View { ... }
private var joinButtonText: String { ... }
private var joinButtonColor: Color { ... }
private var joinButtonBackgroundColor: Color { ... }
private var joinButtonTooltip: String { ... }
private func joinMeeting() { ... }
```

#### New Component Interface

```swift
struct MeetingJoinButton: View {
  let meeting: Meeting
  let onJoin: (URL) -> Void
  
  var body: some View { ... }
}
```

#### Tests Required

- `MeetingJoinButtonTests.swift`
  - ✅ All meeting states (upcoming, active, ended)
  - ✅ All platform types (Zoom, Google Meet, Unknown)
  - ✅ Hover state interactions
  - ✅ Loading state during join
  - ✅ Disabled states
  - ✅ Dynamic tooltip content
  - ✅ Color logic for different states
  - ✅ Button scaling on hover
  - ✅ Join action triggering
  - ✅ URL validation

#### Previews Required

- `#Preview("Upcoming Zoom Meeting")`
- `#Preview("Active Google Meet")`
- `#Preview("Hovered State")`
- `#Preview("Loading State")`
- `#Preview("All Platforms")` - Grid showing different platforms
- `#Preview("All States")` - Grid showing different meeting states

#### Integration

- Update `MeetingRowView` to use `MeetingJoinButton(meeting: meeting, onJoin: { url in ... })`
- Move join logic to parent or pass through closure

---

## Implementation Strategy

### Phase Approach

1. **Start with Phase 1** - Independent, simple components
2. **Manual testing** after each component before proceeding
3. **Phase 2** - Interactive components with moderate complexity
4. **Phase 3** - Complex stateful components last

### File Organization

```
Sources/DocketKit/Views/
├── Components/                    # New directory for extracted components
│   ├── PlatformIndicatorView.swift
│   ├── MeetingTimeView.swift
│   ├── CompletedMeetingsBadge.swift
│   ├── MeetingCopyButton.swift
│   ├── CopyConfirmationBanner.swift
│   ├── MeetingDetailsView.swift
│   ├── RefreshStatusText.swift
│   ├── RefreshStatusIcon.swift
│   └── MeetingJoinButton.swift
├── MeetingRowView.swift           # Updated to use components
├── DaySectionView.swift           # Updated to use components  
├── RefreshStatusView.swift        # Updated to use components
└── ... (other existing views)

Tests/DocketKitTests/
├── Components/                    # New directory for component tests
│   ├── PlatformIndicatorTests.swift
│   ├── MeetingTimeTests.swift
│   ├── CompletedMeetingsBadgeTests.swift
│   ├── MeetingCopyButtonTests.swift
│   ├── CopyConfirmationBannerTests.swift
│   ├── MeetingDetailsTests.swift
│   ├── RefreshStatusTextTests.swift
│   ├── RefreshStatusIconTests.swift
│   └── MeetingJoinButtonTests.swift
└── ... (existing tests)
```

### Testing Strategy

- **Unit tests** for each component in isolation
- **SwiftUI Testing** using new Swift Testing framework  
- **Comprehensive state coverage** - all combinations of inputs
- **Mock data** via existing PreviewData infrastructure
- **Integration tests** remain in existing files

### Preview Strategy

- **Rich previews** showing all states and configurations
- **Grid layouts** for side-by-side comparisons
- **Animation demos** where applicable
- **Edge cases** like empty states, errors, loading

---

## Progress Tracking

### Phase 1: Independent Components ✅ COMPLETED

- [x] 1. PlatformIndicatorView - Component + Tests + Previews + Integration
- [x] 2. MeetingTimeView - Component + Tests + Previews + Integration  
- [x] 3. CompletedMeetingsBadge - Component + Tests + Previews + Integration

### Phase 2: Interactive Components ✅ COMPLETED

- [x] 4. MeetingCopyButton - Component + Tests + Previews + Integration
- [x] 5. CopyConfirmationBanner - Component + Tests + Previews + Integration
- [x] 6. MeetingDetailsView - Component + Tests + Previews + Integration

### Phase 3: Complex Stateful Components ✅ COMPLETED 

- [x] 7. RefreshStatusText - Component + Tests + Previews + Integration
- [x] 8. RefreshStatusIcon - Component + Tests + Previews + Integration
- [x] 9. MeetingJoinButton - Component + Tests + Previews + Integration

---

## Success Criteria ✅ ALL COMPLETED

Each component extraction is complete when:

✅ **Component created** with clean, focused interface
✅ **Comprehensive tests** covering all states and edge cases  
✅ **Rich previews** demonstrating all configurations
✅ **Original view updated** to use new component
✅ **All existing tests pass** (no regressions)
✅ **Manual testing confirms** visual/interactive behavior unchanged  
✅ **Documentation complete** with proper ABOUTME comments

## ✅ COMPONENT EXTRACTION COMPLETE

**Status**: All 9 components successfully extracted and integrated  
**Architecture**: Clean, modular component structure with comprehensive testing  
**Testing**: All tests pass with no regressions from component extraction  
**Code Quality**: Improved modularity, reusability, and testability achieved  

### Components/ Directory Structure Created

```
Sources/DocketKit/Views/Components/
├── PlatformIndicatorView.swift      ✅ Phase 1
├── MeetingTimeView.swift            ✅ Phase 1
├── CompletedMeetingsBadge.swift     ✅ Phase 1
├── MeetingCopyButton.swift          ✅ Phase 2
├── CopyConfirmationBanner.swift     ✅ Phase 2
├── MeetingDetailsView.swift         ✅ Phase 2
├── RefreshStatusText.swift          ✅ Phase 3
├── RefreshStatusIcon.swift          ✅ Phase 3
└── MeetingJoinButton.swift          ✅ Phase 3

Tests/DocketKitTests/Components/
├── PlatformIndicatorTests.swift     ✅ Comprehensive test coverage
├── MeetingTimeTests.swift           ✅ Comprehensive test coverage
├── CompletedMeetingsBadgeTests.swift ✅ Comprehensive test coverage
├── MeetingCopyButtonTests.swift     ✅ Comprehensive test coverage
├── CopyConfirmationBannerTests.swift ✅ Comprehensive test coverage
├── MeetingDetailsTests.swift        ✅ Comprehensive test coverage
├── RefreshStatusTextTests.swift     ✅ Comprehensive test coverage
├── RefreshStatusIconTests.swift     ✅ Comprehensive test coverage
└── MeetingJoinButtonTests.swift     ✅ Comprehensive test coverage
```

### Major Achievements

- **Systematic Extraction**: All components extracted in dependency order
- **Zero Regressions**: All existing functionality preserved
- **Enhanced Testability**: Each component now has focused, comprehensive tests
- **Rich Previews**: All components have multiple preview configurations
- **Clean Interfaces**: Minimal, focused component APIs
- **Improved Maintainability**: Easier to modify, test, and understand individual components

The codebase now has a clean, modular architecture with well-tested, reusable components.
