# Docket Mini Mode Implementation Plan

## Executive Summary

Transform Docket from a traditional floating window application into a modern, space-efficient meeting widget by implementing a "mini mode" that integrates directly into the macOS titlebar. This ultra-compact interface will display essential meeting information in approximately 28px height while preserving all core functionality and providing seamless expansion to full mode when needed.

## Problem Statement & Vision

### Current State Analysis
- **Window Size**: 720x950 pixels - substantial screen real estate consumption
- **Use Pattern**: Users primarily need quick access to next meeting, not full meeting list
- **Screen Competition**: Large floating window competes with primary work applications
- **Context Switching**: Full interface may be overwhelming for simple "what's next" queries

### Target State Vision
- **Ultra-compact widget**: Titlebar-integrated display (~400x28 pixels)
- **Essential information focus**: Next meeting only, with smart status indicators
- **One-click actions**: Join meeting, copy URL, expand to full view
- **Native integration**: Seamless macOS titlebar behavior with window controls
- **On-demand expansion**: Quick toggle to full interface when detailed view needed

### Success Metrics
- **Space efficiency**: 95% reduction in screen footprint (mini mode)
- **Functionality preservation**: 100% of core features accessible
- **User satisfaction**: Faster access to next meeting information
- **Performance**: Sub-300ms mode switching animations

## Technical Architecture

### SwiftUI Window Management Strategy

#### Window Style Configuration
```swift
// Mini Mode: Custom titlebar with integrated content
WindowGroup {
  MiniModeContentView()
}
.windowStyle(.hiddenTitleBar)                           // Remove default titlebar
.toolbarBackgroundVisibility(.hidden, for: .windowToolbar)  // Transparent background
.windowBackgroundDragBehavior(.enabled)                // Drag-to-move functionality

// Full Mode: Standard macOS window behavior
WindowGroup {
  ContentView()
}
.windowStyle(.automatic)                               // Standard titlebar
.windowResizability(.contentSize)                     // User-resizable window
```

#### Dynamic Window Sizing
| Mode | Dimensions | Aspect Ratio | Window Style | Resizable |
|------|------------|--------------|--------------|-----------|
| Full | 720×950    | 3:4          | `.automatic` | ✅ Yes    |
| Mini | 400×28     | 14:1         | `.hiddenTitleBar` | ❌ No |

### State Management Architecture

#### Enhanced AppModel
```swift
@Observable
public final class AppModel: @unchecked Sendable {
  // MARK: - Mini Mode State
  
  /// Current display mode (mini vs full)
  public var isMiniMode: Bool = false {
    didSet {
      persistMiniModePreference()
      notifyModeChange()
      updateWindowConfiguration()
    }
  }
  
  /// Next upcoming meeting for mini mode display
  public var nextMeeting: Meeting? = nil {
    didSet {
      updateMiniModeContent()
    }
  }
  
  /// Window positioning for each mode
  public var miniModePosition: CGPoint?
  public var fullModePosition: CGPoint?
  
  // MARK: - Computed Properties
  
  public var currentWindowSize: CGSize {
    isMiniMode ? CGSize(width: 400, height: 28) : CGSize(width: 720, height: 950)
  }
  
  public var shouldShowMiniContent: Bool {
    isMiniMode && nextMeeting != nil
  }
  
  // MARK: - Mode Management
  
  public func toggleMiniMode() {
    withAnimation(.easeInOut(duration: 0.3)) {
      isMiniMode.toggle()
    }
  }
  
  private func persistMiniModePreference() {
    UserDefaults.standard.set(isMiniMode, forKey: "docketMiniMode")
  }
  
  private func notifyModeChange() {
    NotificationCenter.default.post(
      name: .miniModeDidChange, 
      object: nil, 
      userInfo: ["isMiniMode": isMiniMode]
    )
  }
}
```

#### CalendarManager Integration
```swift
extension CalendarManager {
  /// Computed property for next upcoming meeting
  public var nextMeeting: Meeting? {
    let now = Date()
    return meetings
      .filter { meeting in
        // Include active meetings and future meetings
        !meeting.hasEnded && meeting.startTime >= now.addingTimeInterval(-1800) // Include 30min active
      }
      .sorted { $0.startTime < $1.startTime }
      .first
  }
  
  /// Update app model with next meeting during refresh cycles
  private func updateAppModelNextMeeting() {
    Task { @MainActor in
      appModel.nextMeeting = nextMeeting
    }
  }
}
```

## UI/UX Design Specification

### Mini Mode Layout Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│[🔴🟡🟢] [🔵] LIVE Design Review with Sarah Thompson... (12 min left) [📋][Join][⬆️]│
└─────────────────────────────────────────────────────────────────────────────────────┘
 ↑       ↑    ↑                                        ↑              ↑     ↑     ↑
 │       │    │                                        │              │     │     │
 │       │    Meeting title (intelligently truncated)  │              │     │     Expand
 │       │                                             │              │     Join button
 │       Platform indicator (8px colored dot)          │              │
 │                                                     Time/status     Copy (hover)
 Window controls (68px reserved space)
```

### Visual State System

#### Active Meeting State (Green Theme)
```swift
struct ActiveMeetingDisplay {
  // Status indicator
  Text("LIVE")
    .font(.caption2.weight(.semibold))
    .foregroundStyle(.green)
  
  // Join button
  Button("Join") { /* action */ }
    .background(.green)
    .foregroundStyle(.white)
  
  // Platform indicator
  Circle()
    .fill(.green)
    .frame(width: 8, height: 8)
}
```

#### Upcoming Soon State (Orange Theme - Within 15 minutes)
```swift
struct UpcomingSoonDisplay {
  // Dynamic countdown
  Text(timeUntilText) // "3m", "1m", "NOW"
    .font(.caption2.weight(.semibold))
    .foregroundStyle(.orange)
  
  // Urgent join button
  Button("Join") { /* action */ }
    .background(.orange)
    .foregroundStyle(.white)
}
```

#### Regular Upcoming State (Blue Theme)
```swift
struct RegularUpcomingDisplay {
  // Time display
  Text("2:30 PM")
    .font(.caption2.weight(.semibold))
    .foregroundStyle(.blue)
  
  // Standard join button
  Button("Join") { /* action */ }
    .background(.blue)
    .foregroundStyle(.white)
}
```

#### Ended State (Gray Theme)
```swift
struct EndedMeetingDisplay {
  // Ended indicator
  Text("ENDED")
    .font(.caption2.weight(.semibold))
    .foregroundStyle(.secondary)
  
  // No join button, only expand
  // Muted appearance throughout
}
```

#### Empty State
```swift
struct EmptyMeetingDisplay {
  HStack(spacing: 6) {
    Image(systemName: "calendar")
      .font(.caption2)
      .foregroundStyle(.tertiary)
    
    Text("No upcoming meetings")
      .font(.caption)
      .foregroundStyle(.secondary)
  }
}
```

### Interaction Design Patterns

#### Hover Effects & Micro-interactions
- **Copy Button**: Appears with fade-in animation on hover (0.2s ease-in-out)
- **Join Button**: Subtle scale transform on press (0.95x scale)
- **Platform Indicator**: Tooltip with platform name and meeting duration
- **Title Text**: Tooltip with full title text when truncated

#### Progressive Disclosure
- **Primary Actions**: Always visible (Join, Expand)
- **Secondary Actions**: Appear on hover (Copy)
- **Contextual Information**: Available via tooltips and hover states

## Implementation Roadmap

### Phase 1: Foundation Components (Week 1)

#### 1.1 Core Mini Mode View
```swift
// File: Sources/DocketKit/Views/MiniMode/MiniModeContentView.swift
struct MiniModeContentView: View {
  @Environment(AppModel.self) private var appModel
  @State private var calendarManager = CalendarManager()
  @State private var isHovered = false
  
  var body: some View {
    HStack(spacing: 0) {
      // Reserved space for macOS window controls
      Spacer().frame(width: 68)
      
      // Dynamic content based on meeting availability
      Group {
        if let meeting = appModel.nextMeeting {
          MiniMeetingContentView(meeting: meeting, isHovered: isHovered)
        } else {
          MiniEmptyStateView()
        }
      }
      
      Spacer()
      
      // Action buttons zone
      MiniActionButtonsView(
        meeting: appModel.nextMeeting,
        isHovered: isHovered,
        onJoin: handleJoinMeeting,
        onCopy: handleCopyURL,
        onExpand: appModel.toggleMiniMode
      )
      .frame(width: 80) // Balanced with left spacer
    }
    .frame(height: 28)
    .background(.regularMaterial)
    .onHover { isHovered = $0 }
  }
  
  private func handleJoinMeeting(_ url: URL) {
    let success = NSWorkspace.shared.open(url)
    if !success {
      print("❌ Failed to open meeting URL: \(url)")
    }
  }
  
  private func handleCopyURL(_ urlString: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(urlString, forType: .string)
    
    // Provide user feedback
    showCopyConfirmation()
  }
}
```

#### 1.2 Meeting Content Display Component
```swift
// File: Sources/DocketKit/Views/MiniMode/MiniMeetingContentView.swift
struct MiniMeetingContentView: View {
  let meeting: Meeting
  let isHovered: Bool
  
  var body: some View {
    HStack(spacing: 8) {
      // Platform indicator
      PlatformIndicatorMini(platform: meeting.platform)
      
      // Status and time information
      MeetingStatusView(meeting: meeting)
      
      // Meeting title with intelligent truncation
      Text(meeting.title)
        .font(.caption)
        .lineLimit(1)
        .truncationMode(.tail)
        .foregroundStyle(meeting.hasEnded ? .secondary : .primary)
        .help(meeting.title) // Full title on hover
    }
  }
}

struct PlatformIndicatorMini: View {
  let platform: MeetingPlatform
  
  var body: some View {
    Circle()
      .fill(platformColor)
      .frame(width: 8, height: 8)
      .help(platform.displayName)
  }
  
  private var platformColor: Color {
    switch platform {
    case .zoom: return .blue
    case .googleMeet: return .green
    case .unknown: return .gray
    }
  }
}
```

#### 1.3 Action Buttons Component
```swift
// File: Sources/DocketKit/Views/MiniMode/MiniActionButtonsView.swift
struct MiniActionButtonsView: View {
  let meeting: Meeting?
  let isHovered: Bool
  let onJoin: (URL) -> Void
  let onCopy: (String) -> Void
  let onExpand: () -> Void
  
  var body: some View {
    HStack(spacing: 4) {
      // Copy button (appears on hover)
      if let meeting = meeting, hasJoinURL(meeting), isHovered {
        Button(action: { onCopy(meeting.joinUrl!) }) {
          Image(systemName: "doc.on.doc")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .help("Copy meeting link")
        .transition(.opacity.combined(with: .scale))
      }
      
      // Join button (primary action)
      if let meeting = meeting, shouldShowJoinButton(meeting) {
        Button(action: {
          if let urlString = meeting.joinUrl, let url = URL(string: urlString) {
            onJoin(url)
          }
        }) {
          Text("Join")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(joinButtonColor(for: meeting))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .help("Join meeting")
        .scaleEffect(isPressed ? 0.95 : 1.0)
      }
      
      // Expand button (always visible)
      Button(action: onExpand) {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
          .font(.caption2)
          .foregroundStyle(.tertiary)
      }
      .buttonStyle(.plain)
      .help("Expand to full view")
    }
  }
}
```

### Phase 2: Window Management System (Week 2)

#### 2.1 Enhanced DocketApp Configuration
```swift
// File: Sources/DocketKit/DocketApp.swift
public struct DocketApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var appModel = AppModel()
  
  public init() {}
  
  public var body: some Scene {
    WindowGroup("Docket") {
      Group {
        if appModel.isMiniMode {
          MiniModeContentView()
            .frame(width: 400, height: 28)
        } else {
          ContentView()
            .frame(minWidth: 550, minHeight: 600)
        }
      }
      .environment(appModel)
      .onAppear {
        NSApp.activate(ignoringOtherApps: true)
      }
      .onReceive(NotificationCenter.default.publisher(for: .miniModeDidChange)) { _ in
        Task { @MainActor in
          await configureModeTransition()
        }
      }
    }
    .windowStyle(appModel.isMiniMode ? .hiddenTitleBar : .automatic)
    .windowToolbarStyle(appModel.isMiniMode ? .unified : .automatic)
    .windowBackgroundDragBehavior(appModel.isMiniMode ? .enabled : .automatic)
    .windowResizability(appModel.isMiniMode ? .contentSize : .contentSize)
    .defaultSize(appModel.currentWindowSize)
    .commands {
      CommandGroup(after: .windowArrangement) {
        Button("Toggle Mini Mode") {
          appModel.toggleMiniMode()
        }
        .keyboardShortcut("m", modifiers: [.command])
      }
    }
  }
  
  @MainActor
  private func configureModeTransition() async {
    // Smooth transition between modes with position preservation
    await appDelegate.handleModeTransition(to: appModel.isMiniMode)
  }
}
```

#### 2.2 AppDelegate Window Management
```swift
// File: Sources/DocketKit/DocketApp.swift (AppDelegate extension)
extension AppDelegate {
  @MainActor
  func handleModeTransition(to miniMode: Bool) async {
    guard let window = NSApp.windows.first else { return }
    
    // Save current position
    if miniMode {
      appModel.fullModePosition = window.frame.origin
    } else {
      appModel.miniModePosition = window.frame.origin
    }
    
    // Configure window for new mode
    await withAnimation(.easeInOut(duration: 0.3)) {
      if miniMode {
        configureMiniModeWindow(window)
      } else {
        configureFullModeWindow(window)
      }
    }
    
    // Restore appropriate position
    restoreWindowPosition(window, for: miniMode)
  }
  
  private func configureMiniModeWindow(_ window: NSWindow) {
    window.styleMask = [.titled, .closable, .miniaturizable]
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.level = appModel.alwaysOnTop ? .floating : .normal
    window.setContentSize(NSSize(width: 400, height: 28))
    window.standardWindowButton(.zoomButton)?.isHidden = true // Hide zoom in mini
  }
  
  private func configureFullModeWindow(_ window: NSWindow) {
    window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
    window.titlebarAppearsTransparent = false
    window.titleVisibility = .visible
    window.level = appModel.alwaysOnTop ? .floating : .normal
    window.setContentSize(NSSize(width: 720, height: 950))
    window.standardWindowButton(.zoomButton)?.isHidden = false
  }
}
```

### Phase 3: State Persistence & Polish (Week 3)

#### 3.1 UserDefaults Integration
```swift
// File: Sources/DocketKit/Models/AppModel.swift (Persistence extension)
extension AppModel {
  private enum UserDefaultsKeys {
    static let miniMode = "docketMiniMode"
    static let miniModePosition = "docketMiniModePosition"
    static let fullModePosition = "docketFullModePosition"
  }
  
  func loadPersistedState() {
    isMiniMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.miniMode)
    
    if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.miniModePosition),
       let point = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data)?.pointValue {
      miniModePosition = point
    }
    
    if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.fullModePosition),
       let point = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data)?.pointValue {
      fullModePosition = point
    }
  }
  
  func persistState() {
    UserDefaults.standard.set(isMiniMode, forKey: UserDefaultsKeys.miniMode)
    
    if let position = miniModePosition {
      let data = try? NSKeyedArchiver.archivedData(
        withRootObject: NSValue(point: position),
        requiringSecureCoding: true
      )
      UserDefaults.standard.set(data, forKey: UserDefaultsKeys.miniModePosition)
    }
  }
}
```

#### 3.2 Animation & Transition System
```swift
// File: Sources/DocketKit/Views/MiniMode/MiniModeTransitionView.swift
struct MiniModeTransitionView: View {
  @Environment(AppModel.self) private var appModel
  @State private var isTransitioning = false
  
  var body: some View {
    Group {
      if appModel.isMiniMode {
        MiniModeContentView()
          .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
          ))
      } else {
        ContentView()
          .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
          ))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: appModel.isMiniMode)
  }
}
```

### Phase 4: Integration & Testing (Week 4)

#### 4.1 CalendarManager Integration
```swift
// File: Sources/DocketKit/Managers/CalendarManager.swift (Mini mode integration)
extension CalendarManager {
  /// Update next meeting during refresh cycles
  @MainActor
  private func updateNextMeetingForMiniMode() {
    // Only update if we have an app model reference
    guard let appModel = appModel else { return }
    
    let previousNextMeeting = appModel.nextMeeting
    let currentNextMeeting = nextMeeting
    
    // Only update if the next meeting actually changed
    if previousNextMeeting?.id != currentNextMeeting?.id {
      appModel.nextMeeting = currentNextMeeting
      
      // Log mini mode updates for debugging
      if appModel.isMiniMode {
        if let meeting = currentNextMeeting {
          print("🔄 Mini mode updated: \(meeting.title) at \(meeting.startTime)")
        } else {
          print("🔄 Mini mode updated: No upcoming meetings")
        }
      }
    }
  }
}
```

#### 4.2 Comprehensive Testing Strategy
```swift
// File: Tests/DocketKitTests/MiniMode/MiniModeTests.swift
@Test("Mini mode state management")
func testMiniModeStateChanges() async throws {
  let appModel = AppModel()
  
  // Test initial state
  #expect(appModel.isMiniMode == false)
  
  // Test toggle functionality
  appModel.toggleMiniMode()
  #expect(appModel.isMiniMode == true)
  
  // Test persistence
  appModel.persistState()
  let newAppModel = AppModel()
  newAppModel.loadPersistedState()
  #expect(newAppModel.isMiniMode == true)
}

@Test("Next meeting calculation")
func testNextMeetingCalculation() async throws {
  let calendarManager = CalendarManager()
  
  // Setup test meetings
  let now = Date()
  let activeMeeting = Meeting(
    startTime: now.addingTimeInterval(-1800), // Started 30 min ago
    endTime: now.addingTimeInterval(1800)     // Ends in 30 min
  )
  let upcomingMeeting = Meeting(
    startTime: now.addingTimeInterval(3600),  // Starts in 1 hour
    endTime: now.addingTimeInterval(7200)     // Ends in 2 hours
  )
  
  calendarManager.meetings = [activeMeeting, upcomingMeeting]
  
  // Test next meeting selection (should be active meeting)
  #expect(calendarManager.nextMeeting?.id == activeMeeting.id)
}
```

## File Structure & Organization

### New Directory Structure
```
Sources/DocketKit/
├── Views/
│   ├── MiniMode/                              # New mini mode components
│   │   ├── MiniModeContentView.swift          # Main mini interface
│   │   ├── MiniMeetingContentView.swift       # Meeting info display
│   │   ├── MiniActionButtonsView.swift        # Compact action buttons
│   │   ├── MiniEmptyStateView.swift           # No meetings state
│   │   ├── MiniModeTransitionView.swift       # Transition animations
│   │   └── Components/
│   │       ├── PlatformIndicatorMini.swift    # Tiny platform indicator
│   │       ├── MeetingStatusView.swift        # Status text component
│   │       └── MiniModeToggleButton.swift     # Mode switching control
│   ├── ContentView.swift                      # Modified: mode switching
│   ├── MeetingsListView.swift                 # Enhanced: mini mode toggle
│   └── Components/                            # Existing components
│       ├── MiniMeetingView.swift              # Original mini prototype
│       └── TitlebarMiniView.swift             # Research prototype
├── Models/
│   └── AppModel.swift                         # Enhanced: mini mode state
├── Managers/
│   └── CalendarManager.swift                  # Enhanced: next meeting logic
└── DocketApp.swift                            # Enhanced: window management

Tests/DocketKitTests/
├── MiniMode/                                  # New mini mode tests
│   ├── MiniModeTests.swift                    # State management tests
│   ├── NextMeetingTests.swift                 # Meeting calculation tests
│   └── WindowManagementTests.swift            # Window behavior tests
└── Components/
    ├── MiniMeetingContentTests.swift          # Component unit tests
    └── MiniActionButtonsTests.swift           # Action button tests
```

### Modified Files Impact Analysis
| File | Modification Type | Impact Level | Breaking Changes |
|------|------------------|--------------|------------------|
| `DocketApp.swift` | Major | High | ❌ None |
| `AppModel.swift` | Major | Medium | ❌ None |
| `CalendarManager.swift` | Minor | Low | ❌ None |
| `ContentView.swift` | Minor | Low | ❌ None |

## Testing & Quality Assurance

### Automated Testing Strategy

#### Unit Tests (95% Coverage Target)
```swift
// Mini mode state management
@Test("Toggle mini mode") 
@Test("Persist mini mode preferences")
@Test("Window size calculations")

// Next meeting logic
@Test("Calculate next meeting - no meetings")
@Test("Calculate next meeting - active meeting exists") 
@Test("Calculate next meeting - multiple upcoming meetings")
@Test("Calculate next meeting - only ended meetings")

// Component rendering
@Test("Mini content view with meeting")
@Test("Mini content view empty state")
@Test("Action buttons visibility logic")
```

#### Integration Tests
```swift
// Mode switching
@Test("Switch from full to mini mode")
@Test("Switch from mini to full mode") 
@Test("Preserve window position across mode changes")

// Calendar integration
@Test("Update mini mode when meetings change")
@Test("Handle calendar permission changes in mini mode")

// Window management
@Test("Window controls remain functional in mini mode")
@Test("Window dragging works in mini mode")
```

### Manual Testing Scenarios

#### Core Functionality Testing
1. **Mode Switching**
   - [ ] Toggle between modes using UI button
   - [ ] Toggle using keyboard shortcut (⌘M)
   - [ ] Verify smooth animation transitions
   - [ ] Test window position preservation

2. **Meeting Display**
   - [ ] Active meeting shows "LIVE" status in green
   - [ ] Upcoming meeting shows countdown in orange
   - [ ] Regular upcoming shows time in blue
   - [ ] Ended meeting shows "ENDED" in gray
   - [ ] Empty state shows appropriate message

3. **Action Buttons**
   - [ ] Join button opens correct meeting URL
   - [ ] Copy button copies URL to clipboard
   - [ ] Expand button switches to full mode
   - [ ] Hover reveals copy button

#### Edge Case Testing
4. **Meeting States**
   - [ ] Meeting starting in < 1 minute
   - [ ] Meeting with very long title
   - [ ] Meeting without join URL
   - [ ] Multiple meetings at same time

5. **Window Behavior**
   - [ ] Mini mode on multiple monitors
   - [ ] Window positioning near screen edges
   - [ ] Always-on-top behavior in mini mode
   - [ ] Mission Control and Spaces integration

6. **Performance**
   - [ ] Mode switching with large meeting list
   - [ ] Auto-refresh performance in mini mode
   - [ ] Memory usage during extended mini mode use

### User Acceptance Testing

#### Usability Criteria
- **Discoverability**: New users can find and understand mini mode within 30 seconds
- **Efficiency**: Experienced users can join meetings 50% faster using mini mode
- **Satisfaction**: 90% of users prefer mini mode for quick meeting access
- **Accessibility**: All mini mode features work with VoiceOver and keyboard navigation

#### Beta Testing Plan
1. **Internal Testing** (Week 1): Development team daily use
2. **Alpha Testing** (Week 2): 5 power users with diverse usage patterns  
3. **Beta Testing** (Week 3): 20 users across different workflows
4. **Release Candidate** (Week 4): 50 users with feedback collection

## Performance & Optimization

### Performance Targets

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Mode Switch Time | < 300ms | Animation duration tracking |
| Memory Usage | < 50MB | Memory profiler in both modes |
| CPU Usage (idle) | < 2% | Activity Monitor during auto-refresh |
| Window Resize | < 100ms | Frame rate analysis |

### Optimization Strategies

#### Memory Management
```swift
// Lazy loading for mini mode components
@State private var miniModeContent: MiniModeContentView? = nil

var body: some View {
  Group {
    if appModel.isMiniMode {
      if miniModeContent == nil {
        miniModeContent = MiniModeContentView()
      }
      miniModeContent
    } else {
      ContentView()
    }
  }
}
```

#### Rendering Optimization
- **Conditional updates**: Only refresh mini mode content when next meeting changes
- **Animation throttling**: Limit hover effects to essential interactions
- **View caching**: Reuse meeting content views when possible

#### Network Efficiency
- **Smart polling**: Reduce auto-refresh frequency in mini mode when no meetings
- **Differential updates**: Only process changed meetings during refresh
- **Background processing**: Handle meeting calculations off main thread

## Risk Assessment & Mitigation

### Technical Risks

#### High Impact Risks
1. **Window Management Complexity**
   - *Risk*: SwiftUI window style switching may cause visual artifacts
   - *Probability*: Medium (30%)
   - *Impact*: High - Core functionality affected
   - *Mitigation*: Extensive testing across macOS versions, fallback to manual NSWindow configuration

2. **Performance Degradation**
   - *Risk*: Frequent mode switching impacts app responsiveness
   - *Probability*: Low (15%)
   - *Impact*: Medium - User experience degraded
   - *Mitigation*: Performance testing, lazy loading, view recycling

3. **Calendar Integration Issues**
   - *Risk*: Next meeting calculation fails with complex calendar setups
   - *Probability*: Medium (25%)
   - *Impact*: High - Mini mode shows incorrect information
   - *Mitigation*: Comprehensive edge case testing, robust error handling

#### Medium Impact Risks
4. **SwiftUI Limitations**
   - *Risk*: titlebar integration doesn't work as expected
   - *Probability*: Medium (40%)
   - *Impact*: Medium - May need design adjustments
   - *Mitigation*: Research alternative approaches, AppKit fallbacks

5. **User Adoption**
   - *Risk*: Users don't discover or use mini mode
   - *Probability*: Medium (35%)
   - *Impact*: Low - Feature unused but no harm
   - *Mitigation*: Prominent UI placement, onboarding flow, user education

### Mitigation Action Plan

#### Pre-Implementation
- [ ] Create SwiftUI window management prototype
- [ ] Test titlebar integration on multiple macOS versions
- [ ] Performance baseline measurement of current app

#### During Implementation  
- [ ] Daily performance monitoring
- [ ] Progressive feature rollout with feature flags
- [ ] Regular memory leak testing

#### Post-Implementation
- [ ] User analytics on mini mode usage
- [ ] Performance monitoring in production
- [ ] Feedback collection and iteration

## Success Metrics & KPIs

### Quantitative Metrics

#### Usage Analytics
- **Mini Mode Adoption Rate**: % of users who try mini mode within first week
- **Mini Mode Retention**: % of users still using mini mode after 1 month
- **Mode Switch Frequency**: Average switches per user per day
- **Join Success Rate**: % of successful meeting joins from mini mode

#### Performance Metrics
- **App Launch Time**: Time to first usable state in mini vs full mode
- **Memory Footprint**: RAM usage comparison between modes
- **Battery Impact**: Energy usage analysis on MacBook devices
- **Responsiveness**: UI interaction response times

#### Feature Utilization
- **Next Meeting Accuracy**: % of time mini mode shows correct next meeting
- **Action Usage**: Frequency of Join vs Copy vs Expand actions
- **Error Rates**: Failed joins, copy operations, mode switches

### Qualitative Metrics

#### User Satisfaction (Survey-Based)
- Overall satisfaction with mini mode (1-10 scale)
- Perceived usefulness for daily workflow
- Preference vs traditional full mode
- Likelihood to recommend feature

#### Usability Assessment
- Time to discover mini mode feature
- Time to understand mini mode controls
- Success rate for first-time mode switching
- Accessibility compliance verification

### Success Criteria Definition

#### MVP Success (Minimum Viable Product)
- ✅ 60% of beta users try mini mode
- ✅ 70% of users who try mini mode use it again within 24 hours
- ✅ < 5% error rate for mode switching
- ✅ 100% feature parity for core meeting actions

#### Full Success (Product Goals)
- ✅ 80% of active users adopt mini mode
- ✅ 90% user satisfaction score for mini mode
- ✅ 40% reduction in average time to join meetings
- ✅ Zero accessibility violations

#### Exceptional Success (Stretch Goals)
- ✅ Mini mode becomes primary usage pattern for 60% of users
- ✅ Feature requested for porting to other meeting apps
- ✅ App Store review score improvement attributed to mini mode
- ✅ Recognition in macOS design showcase or awards

## Future Enhancement Roadmap

### Phase 2 Features (6-Month Horizon)

#### Smart Positioning
- **Magnetic Edges**: Mini mode snaps to screen edges and corners
- **Focus-Aware Positioning**: Automatically position away from active app windows
- **Multi-Monitor Intelligence**: Remember optimal position per monitor setup

#### Enhanced Interaction
- **Hover Preview**: Show meeting details overlay on mini mode hover
- **Quick Actions Menu**: Right-click context menu with additional actions
- **Keyboard Navigation**: Full keyboard control for accessibility

#### Visual Enhancements
- **Theme Support**: Light/dark/auto theme following system preferences
- **Custom Sizing**: User-configurable mini mode dimensions
- **Transparency Control**: Adjustable opacity for background integration

### Phase 3 Features (12-Month Horizon)

#### Advanced Meeting Management
- **Multiple Meeting Preview**: Show next 2-3 meetings in expanded mini view
- **Quick Meeting Creation**: Create meetings directly from mini mode
- **Meeting Notes Integration**: Quick note-taking for active meetings

#### System Integration
- **Menu Bar Mode**: Optional menu bar integration instead of floating window
- **Focus Modes Integration**: Automatic behavior changes based on Focus state
- **Shortcuts App Integration**: Custom automations and workflows

#### Intelligent Features
- **Smart Notifications**: Context-aware meeting reminders
- **Travel Time Integration**: Account for location-based meeting prep time
- **Calendar Conflicts**: Visual indicators for scheduling conflicts

### Long-Term Vision (18+ Months)

#### Platform Expansion
- **iOS Companion**: iPhone widget showing Mac meeting status
- **Apple Watch Integration**: Glance-able meeting information
- **tvOS Support**: Conference room display mode

#### AI-Powered Features
- **Meeting Insights**: Automatic meeting pattern analysis
- **Smart Scheduling**: AI-powered optimal meeting time suggestions
- **Content Awareness**: Meeting preparation based on title/agenda parsing

#### Enterprise Features
- **Team Coordination**: Shared team meeting visibility
- **Analytics Dashboard**: Meeting productivity metrics
- **Integration Ecosystem**: Deep integration with productivity suites

## Conclusion

The Mini Mode implementation represents a significant evolution of Docket from a traditional calendar application to a modern, space-efficient meeting companion. By leveraging the latest SwiftUI window management APIs and focusing on essential user workflows, we can deliver a feature that fundamentally improves the daily meeting experience for macOS users.

The comprehensive plan outlined above provides a clear roadmap for implementation while maintaining high standards for code quality, user experience, and system integration. The phased approach allows for iterative development with regular feedback incorporation, ensuring the final product meets both technical requirements and user expectations.

Success will be measured not just by technical implementation, but by genuine user adoption and workflow improvement. The mini mode should become an indispensable part of users' daily meeting routine, providing instant access to essential information while preserving screen real estate for primary work activities.

With proper execution of this plan, Docket's mini mode will set a new standard for meeting management applications on macOS, demonstrating how thoughtful design and modern development practices can create truly user-centric software experiences.