# AppKit Conversion Plan for Docket
## From SwiftUI to Native AppKit with macOS 26 Tahoe Liquid Glass

**Date**: October 2025
**Version**: 1.0
**Status**: Approved
**Author**: Teej + Claude
**Estimated Duration**: 4 weeks

---

## 1. Executive Summary

### Why Convert to AppKit?

Docket is a **floating widget** – a specialized use case where AppKit excels and SwiftUI has fundamental limitations:

**Current SwiftUI Issues:**
- `.containerBackground(.ultraThinMaterial)` caches the material effect
- Window movement doesn't trigger live re-sampling of background
- Users must resize the window to refresh the material appearance
- Limited control over NSWindow/NSPanel behavior

**AppKit Advantages:**
- `NSVisualEffectView` automatically updates as window moves
- Built-in support for floating panels (NSPanel)
- Direct access to Liquid Glass materials in macOS 26 Tahoe
- Better performance for persistent, always-visible windows
- Native integration with system design language

### What We Gain

✅ **Live-Updating Liquid Glass** - Material reflects content behind window in real-time
✅ **True Floating Panel Behavior** - Full NSPanel API control
✅ **2025 HIG Compliance** - Follows macOS Tahoe design guidelines precisely
✅ **Better Performance** - No SwiftUI-AppKit bridge overhead
✅ **Easier Debugging** - Direct AppKit view hierarchy
✅ **Future-Proof** - Built on native macOS framework

### Timeline

- **Week 1**: AppKit infrastructure (DocketPanel, window controller, Liquid Glass setup)
- **Week 2**: Core views (MeetingsListViewController, MeetingRowView)
- **Week 3**: Components (buttons, status bar, info displays)
- **Week 4**: Testing, QA, documentation

**Total Effort**: ~80-100 development hours
**Risk Level**: Medium (view layer only, business logic untouched)

### Success Criteria

✅ All 262 business logic tests pass unchanged
✅ Material background updates live as window moves
✅ Floating window behavior matches NSPanel API capabilities
✅ Performance metrics match or exceed current SwiftUI version
✅ No regressions in calendar access, URL extraction, meeting detection
✅ Accessibility/VoiceOver support maintained

---

## 2. Current SwiftUI Architecture

### File Structure Overview

```
Sources/DocketKit/
├── DocketApp.swift                    (153 LOC) - SwiftUI App entry point
├── Models/
│   ├── Meeting.swift                  (145 LOC) - Data model
│   ├── MeetingPlatform.swift          (156 LOC) - Platform enum
│   └── AppModel.swift                 (67 LOC) - @Observable state
├── Managers/
│   └── CalendarManager.swift          (402 LOC) - EventKit integration
├── Utilities/
│   ├── MeetingURLExtractor.swift      (198 LOC) - URL parsing
│   └── Logger.swift                   (61 LOC) - Logging
├── Extensions/
│   └── EKEvent+CalendarEventLike.swift (78 LOC) - EventKit bridge
└── Views/
    ├── MeetingsListView.swift         (229 LOC) - Main container
    ├── MeetingRowView.swift           (160 LOC) - Row component
    ├── DaySectionView.swift           (70 LOC) - Section header
    ├── EmptyStateView.swift           (122 LOC) - Permission/empty states
    ├── EmptyMeetingsDayView.swift     (25 LOC) - Empty day message
    ├── LoadingStateView.swift         (56 LOC) - Loading indicator
    ├── PreviewData.swift              (150 LOC) - SwiftUI preview data
    └── Components/
        ├── StatusBar.swift            (194 LOC) - Bottom status bar
        ├── StatusBarRefreshItem.swift (111 LOC) - Refresh status
        ├── HideCompletedButton.swift  (142 LOC) - Toggle button
        ├── PinButton.swift            (49 LOC) - Always-on-top toggle
        ├── MeetingJoinButton.swift    (149 LOC) - Join meeting action
        ├── MeetingCopyButton.swift    (73 LOC) - Copy URL action
        ├── PlatformIndicatorView.swift (97 LOC) - Platform badge
        ├── MeetingTimeView.swift      (183 LOC) - Time display
        ├── MeetingDetailsView.swift   (61 LOC) - Organizer/attendees
        ├── RefreshStatusIcon.swift    (107 LOC) - Animated refresh icon
        └── RefreshStatusText.swift    (92 LOC) - Refresh timestamp

Total: ~2,650 LOC (26 Swift files)
```

### View Hierarchy (Current SwiftUI)

```
WindowGroup ("Docket - Zoom Meetings")
├── containerBackground(.ultraThinMaterial)
├── MeetingsListView
│   ├── Group (conditional)
│   │   ├── permissionLoadingView (LoadingStateView)
│   │   ├── loadingView (LoadingStateView)
│   │   ├── emptyStateView (EmptyStateView)
│   │   └── meetingsList
│   │       ├── List
│   │       │   ├── DaySectionView("Yesterday")
│   │       │   │   ├── MeetingRowView
│   │       │   │   │   ├── VStack (meeting info)
│   │       │   │   │   │   ├── Text (title)
│   │       │   │   │   │   ├── MeetingTimeView
│   │       │   │   │   │   └── HStack (details)
│   │       │   │   │   │       ├── PlatformIndicatorView
│   │       │   │   │   │       └── MeetingDetailsView
│   │       │   │   │   └── HStack (actions)
│   │       │   │   │       ├── MeetingCopyButton
│   │       │   │   │       └── MeetingJoinButton
│   │       │   ├── DaySectionView("Today")
│   │       │   └── DaySectionView("Tomorrow")
│   │       └── StatusBar
│   │           ├── StatusBarRefreshItem
│   │           └── HideCompletedButton
│   └── toolbar
│       └── PinButton
```

### State Management (@Observable Pattern)

```
AppModel (@Observable)
├── alwaysOnTop: Bool → Controls window.level
└── hideCompletedMeetingsAfter5Min: Bool → Filters meeting list

CalendarManager (@Observable)
├── authState: CalendarAuthState
├── meetings: [Meeting]
├── yesterdayMeetings: [Meeting]
├── todayMeetings: [Meeting]
├── tomorrowMeetings: [Meeting]
├── isRefreshing: Bool
├── lastRefresh: Date?
├── isAutoRefreshEnabled: Bool
├── isAutoRefreshActive: Bool
└── Methods:
    ├── requestAccess() async → Bool
    ├── refreshMeetings() async throws
    ├── startAutoRefresh()
    ├── pauseAutoRefresh()
    ├── resumeAutoRefresh()
    └── stopAutoRefresh()
```

### Data Flow

```
┌─────────────────────────────────────┐
│     SwiftUI Views (UI Layer)         │
│  • Observe @Observable state        │
│  • Trigger user actions             │
└────────────────┬────────────────────┘
                 │
        .onChange(of:)
        .onAppear
        .onReceive
                 │
┌────────────────▼────────────────────┐
│  AppModel + CalendarManager         │
│   (@Observable state sources)       │
└────────────────┬────────────────────┘
                 │
                 │ Property changes
                 │
┌────────────────▼────────────────────┐
│   Business Logic Layer              │
│  • Meeting filtering & sorting      │
│  • Time state calculations          │
│  • Platform detection               │
│  • URL extraction                   │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  EventKit API + Managers            │
│  • Calendar access & permissions    │
│  • Event fetching                   │
│  • System integration               │
└─────────────────────────────────────┘
```

### Material Handling Issues

**Current Problem:**
```swift
.containerBackground(.ultraThinMaterial, for: .window)
```

1. Material effect is rendered once during view initialization
2. As window moves over different content, material doesn't re-sample
3. Only re-renders on resize or explicit view updates
4. Users see stale material appearance until window changes size

**AppKit Solution:**
```swift
let effectView = NSVisualEffectView()
effectView.material = .hudWindow  // macOS 26 Tahoe semantic
effectView.blendingMode = .behindWindow
```

- NSVisualEffectView continuously samples background content
- Automatic updates as window position changes
- GPU-accelerated rendering
- Live response to light/dark appearance changes

---

## 3. Target AppKit Architecture

### New File Structure

```
Sources/DocketKit/
├── DocketApp.swift                    ❌ DELETE (moved to AppDelegate)
├── AppDelegate.swift                  ✨ NEW - App entry point
├── Windows/                           ✨ NEW
│   ├── DocketPanel.swift             - NSPanel subclass
│   └── DocketWindowController.swift  - Window lifecycle
├── Controllers/                       ✨ NEW
│   ├── ContentViewController.swift    - Root view controller
│   ├── MeetingsListViewController.swift - Main list container
│   ├── EmptyStateViewController.swift - Permission/empty states
│   └── LoadingStateViewController.swift - Loading view controller
├── Views/                             (REFACTORED)
│   ├── MeetingRowView.swift          → NSView subclass
│   ├── DaySectionView.swift          → NSView subclass
│   ├── StatusBarView.swift           → NSView subclass
│   ├── LoadingStateView.swift        → NSView subclass
│   └── Components/                   (REFACTORED)
│       ├── PinButton.swift           → NSButton subclass
│       ├── HideCompletedButton.swift → NSButton subclass
│       ├── MeetingJoinButton.swift   → NSButton subclass
│       ├── MeetingCopyButton.swift   → NSButton subclass
│       ├── StatusBarRefreshItem.swift → NSView subclass
│       ├── PlatformIndicatorView.swift → NSView subclass
│       ├── MeetingTimeView.swift     → NSView subclass
│       ├── MeetingDetailsView.swift  → NSView subclass
│       ├── RefreshStatusIcon.swift   → NSImageView subclass
│       └── RefreshStatusText.swift   → NSTextField subclass
├── Models/                            (NO CHANGES)
│   ├── Meeting.swift                 ✅ Keep as-is
│   ├── MeetingPlatform.swift         ✅ Keep as-is
│   └── AppModel.swift                ✅ Keep as-is
├── Managers/                          (NO CHANGES)
│   └── CalendarManager.swift         ✅ Keep as-is
├── Utilities/                         (NO CHANGES)
│   ├── MeetingURLExtractor.swift     ✅ Keep as-is
│   └── Logger.swift                  ✅ Keep as-is
├── Extensions/                        (NO CHANGES)
│   └── EKEvent+CalendarEventLike.swift ✅ Keep as-is
└── Helpers/                           ✨ NEW
    ├── NSViewExtensions.swift        - Auto Layout helpers
    └── ColorExtensions.swift         - Platform colors

Resources/
├── Info.plist                         (UPDATED)
└── Entitlements.entitlements          (NO CHANGES)
```

### AppKit View Hierarchy (Target)

```
DocketPanel (NSPanel)
├── isFloatingPanel = true
├── level = .floating
├── collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
└── contentViewController = ContentViewController
    └── ContentViewController (NSViewController)
        └── view (NSView) - root container
            ├── NSVisualEffectView (Liquid Glass background)
            │   ├── material = .hudWindow (Tahoe 2025)
            │   ├── blendingMode = .behindWindow
            │   └── state = .active
            │
            ├── NSScrollView (main content area)
            │   └── clipView.documentView
            │       └── NSStackView (vertical)
            │           ├── NSStackView (Yesterday section)
            │           │   ├── NSTextField (header)
            │           │   └── [MeetingRowView...]
            │           ├── NSStackView (Today section)
            │           │   ├── NSTextField (header)
            │           │   └── [MeetingRowView...]
            │           └── NSStackView (Tomorrow section)
            │               ├── NSTextField (header)
            │               └── [MeetingRowView...]
            │
            ├── MeetingRowView (NSView) ×N
            │   ├── NSVisualEffectView (row background)
            │   └── NSStackView (horizontal)
            │       ├── NSStackView (left - meeting info)
            │       │   ├── NSTextField (title)
            │       │   ├── NSStackView (time info)
            │       │   └── NSStackView (details)
            │       │       ├── PlatformIndicatorView
            │       │       └── MeetingDetailsView
            │       └── NSStackView (right - actions)
            │           ├── MeetingCopyButton (NSButton)
            │           └── MeetingJoinButton (NSButton)
            │
            └── StatusBarView (NSView - bottom pinned)
                ├── NSVisualEffectView (bar background)
                └── NSStackView (horizontal)
                    ├── StatusBarRefreshItem
                    ├── NSView (spacer)
                    └── HideCompletedButton
```

### Data Binding Pattern (AppKit)

```
┌──────────────────────────────────────┐
│   NSViewController subclasses        │
│  • Store @Observable references     │
│  • Observe via Combine publisher    │
│  • Update NSView hierarchy          │
└────────────────┬─────────────────────┘
                 │
        @ObservedReading
        / Combine .sink()
                 │
┌────────────────▼─────────────────────┐
│  AppModel + CalendarManager          │
│   (@Observable properties)           │
└────────────────┬─────────────────────┘
                 │
                 │ Property changes
                 │
┌────────────────▼─────────────────────┐
│  NSViewController update logic       │
│  • Update view properties            │
│  • Refresh NSStackView layout        │
│  • Animate transitions               │
└────────────────┬─────────────────────┘
                 │
┌────────────────▼─────────────────────┐
│  NSView hierarchy (AppKit UI)        │
│  • NSTextField content               │
│  • NSButton state                    │
│  • NSStackView arrangement           │
└──────────────────────────────────────┘
```

### Memory Management Model

```
DocketPanel (owns)
└── ContentViewController
    └── MeetingsListViewController (holds weak references to:)
        ├── appModel (weak - managed by AppDelegate)
        ├── calendarManager (weak - managed by AppDelegate)
        └── cancellables: Set<AnyCancellable> (strong - cleans on deinit)
            ├── appModel.publisher(for: \.alwaysOnTop)
            └── calendarManager.publisher(for: \.meetings)
```

**Key Principle**: Avoid retain cycles by using weak self in closures and proper Combine subscription management.

---

## 4. Business Logic Preservation Strategy

### Models (NO CHANGES REQUIRED)

#### Meeting.swift (145 LOC)
```swift
// ✅ NO CHANGES - Remains identical
public struct Meeting: Identifiable, Sendable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let startTime: Date
    public let endTime: Date
    public let joinUrl: String?
    public let platform: MeetingPlatform
    public let organizerName: String?
    public let organizerEmail: String?
    public let attendeeCount: Int
    public let attendees: [(name: String?, email: String?)]
    public let calendarName: String
    public let eventIdentifier: String

    // Computed properties for state - UNCHANGED
    public var timeUntilStart: TimeInterval { ... }
    public var duration: TimeInterval { ... }
    public var isUpcoming: Bool { ... }
    public var hasStarted: Bool { ... }
    public var hasEnded: Bool { ... }
    public var minutesSinceEnd: Double { ... }
    public func shouldBeHidden(hideCompletedAfter5Min: Bool) -> Bool { ... }
}
```

**Rationale**: Pure data model with no UI concerns. Framework-agnostic.

#### MeetingPlatform.swift (156 LOC)
```swift
// ✅ NO CHANGES - Remains identical
public enum MeetingPlatform: String, Sendable, Hashable, CaseIterable {
    case zoom
    case googleMeet
    case unknown

    // Display name, icon, color - UNCHANGED
    public var displayName: String { ... }
    public var iconName: String { ... }
    public var color: NSColor { ... }  // Already NSColor compatible

    // Detection method - UNCHANGED
    public static func detect(from urlString: String) -> MeetingPlatform { ... }
}
```

**Rationale**: Enum with computed properties. Already uses NSColor for cross-framework compatibility.

#### AppModel.swift (67 LOC)
```swift
// ✅ NO CHANGES - @Observable works perfectly with AppKit
@Observable
public final class AppModel: @unchecked Sendable {
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

    public var hideCompletedMeetingsAfter5Min: Bool = true
}
```

**Bridge Pattern**: @Observable properties integrate with AppKit via Combine publishers or KVO.

### Managers (NO CHANGES REQUIRED)

#### CalendarManager.swift (402 LOC)
```swift
// ✅ NO CHANGES - @Observable works perfectly with AppKit
@Observable
public final class CalendarManager: @unchecked Sendable {
    public var authState: CalendarAuthState = .notDetermined
    public var meetings: [Meeting] = []
    public var yesterdayMeetings: [Meeting] { ... }
    public var todayMeetings: [Meeting] { ... }
    public var tomorrowMeetings: [Meeting] { ... }
    public var isRefreshing: Bool = false
    public var lastRefresh: Date?
    public var isAutoRefreshEnabled: Bool = true
    public var isAutoRefreshActive: Bool = false

    // Methods - UNCHANGED
    public func requestAccess() async -> Bool { ... }
    public func refreshMeetings() async throws { ... }
    public func startAutoRefresh() { ... }
    public func pauseAutoRefresh() { ... }
    public func resumeAutoRefresh() { ... }
    public func stopAutoRefresh() { ... }
    public func updateAuthState() { ... }
}
```

**Integration**: AppKit view controllers observe via Combine publishers:
```swift
calendarManager.publisher(for: \.meetings)
    .sink { [weak self] newMeetings in
        self?.updateMeetingsList(newMeetings)
    }
    .store(in: &cancellables)
```

### Utilities (NO CHANGES REQUIRED)

#### MeetingURLExtractor.swift (198 LOC)
```swift
// ✅ NO CHANGES - Pure functions, framework-agnostic
public struct MeetingURLExtractor {
    public static func extractMeetingURL(
        from event: CalendarEventLike
    ) -> (url: String, platform: MeetingPlatform)? { ... }

    private static func extractFromVirtualConference(...) -> String? { ... }
    private static func extractFromFields(...) -> String? { ... }
    private static func detectPlatform(...) -> MeetingPlatform { ... }
}
```

**Rationale**: Pure utility functions with no dependencies on framework choice.

### Extensions (NO CHANGES REQUIRED)

#### EKEvent+CalendarEventLike.swift (78 LOC)
```swift
// ✅ NO CHANGES - Protocol adapter remains identical
extension EKEvent: CalendarEventLike {
    public var virtualConferenceURL: String? {
        guard #available(macOS 14.0, *) else { return nil }
        return structuredLocation?.title
    }

    public var eventURL: String? { url?.absoluteString }
    public var eventLocation: String? { location }
    public var eventNotes: String? { notes }
    public var eventTitle: String { title }
    public var eventStart: Date { startDate }
    public var eventEnd: Date { endDate }
}
```

**Rationale**: Protocol adapter pattern decouples EventKit from business logic.

### Test Suite (262 TESTS REMAIN UNCHANGED)

```
Tests/DocketKitTests/
├── MeetingTests.swift                ✅ All tests pass unchanged
├── AppModelTests.swift               ✅ All tests pass unchanged
├── CalendarManagerTests.swift        ✅ All tests pass unchanged
├── MeetingPlatformTests.swift        ✅ All tests pass unchanged
├── MeetingURLExtractorTests.swift    ✅ All tests pass unchanged
└── Components/                       ✅ Business logic tests pass unchanged
    └── (all component tests remain valid for business logic verification)
```

**Coverage Preservation**: 100% of business logic tests continue to pass because:
1. No changes to model/manager implementations
2. No changes to business logic algorithms
3. Protocol-based testing enables framework-agnostic validation

### Integration Points

**Only View Layer Changes Required:**
- SwiftUI @View structs → AppKit NSView/NSViewController subclasses
- SwiftUI bindings → Combine publishers or KVO
- SwiftUI state updates → NSView.needsDisplay / NSStackView.needsLayout

**Business Logic Integration Pattern:**
```swift
class MeetingsListViewController: NSViewController {
    // Store weak references to singletons
    private weak var appModel: AppModel?
    private weak var calendarManager: CalendarManager?

    // Observe changes via Combine
    private var cancellables = Set<AnyCancellable>()

    func viewDidLoad() {
        super.viewDidLoad()

        // Observe meetings array changes
        calendarManager?.publisher(for: \.meetings)
            .sink { [weak self] meetings in
                self?.updateMeetingsList(meetings)
            }
            .store(in: &cancellables)

        // Observe filter state
        appModel?.publisher(for: \.hideCompletedMeetingsAfter5Min)
            .sink { [weak self] _ in
                self?.reloadMeetings()
            }
            .store(in: &cancellables)
    }
}
```

---

## 5. Complete View Conversion Matrix

### Priority 1: Core Infrastructure (Week 1)

#### 1.1 DocketPanel.swift (NEW)
**Lines of Code**: ~150 LOC
**SwiftUI Equivalent**: WindowGroup + containerBackground

```swift
class DocketPanel: NSPanel {
    private var effectView: NSVisualEffectView!

    override init(contentRect: NSRect,
                  styleMask: NSWindow.StyleMask,
                  backing: NSWindow.BackingStoreType,
                  defer flag: Bool) {
        super.init(contentRect: contentRect,
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)

        setupPanelConfiguration()
        setupLiquidGlassBackground()
    }

    private func setupPanelConfiguration() {
        // Floating panel properties
        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Window appearance
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        animationBehavior = .utilityWindow
        hidesOnDeactivate = false

        // Hide standard window buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        // Transparency for material effect
        isOpaque = false
        backgroundColor = .clear
    }

    private func setupLiquidGlassBackground() {
        effectView = NSVisualEffectView(frame: .zero)

        // macOS 26 Tahoe Liquid Glass material
        effectView.material = .hudWindow // Semantic material for floating panels
        effectView.blendingMode = .behindWindow // Material shows through content
        effectView.state = .active
        effectView.autoresizingMask = [.width, .height]

        // Add to content view (background layer)
        if let contentView = contentView {
            contentView.addSubview(effectView, positioned: .below, relativeTo: nil)
            effectView.frame = contentView.bounds
        }
    }

    // Handle Liquid Glass refresh on window moves
    override func didMove(to screen: NSScreen?) {
        super.didMove(to: screen)
        effectView?.needsDisplay = true
    }
}
```

**Key Features**:
- ✅ Floating panel configuration
- ✅ NSVisualEffectView with .hudWindow material (Tahoe 2025)
- ✅ .behindWindow blending mode for content behind glass
- ✅ Automatic material refresh on movement

#### 1.2 DocketWindowController.swift (NEW)
**Lines of Code**: ~120 LOC
**SwiftUI Equivalent**: AppDelegate window management

```swift
class DocketWindowController: NSWindowController {
    let panel: DocketPanel
    let contentVC: ContentViewController

    init(window: DocketPanel, contentViewController: ContentViewController) {
        self.panel = window
        self.contentVC = contentViewController
        super.init(window: window)

        // Setup content
        window.contentViewController = contentViewController

        // Restore window position from preferences
        restoreWindowPosition()

        // Observe window moves for position persistence
        setupWindowPositionObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func restoreWindowPosition() {
        let defaults = UserDefaults.standard
        if let positionData = defaults.data(forKey: "DocketWindowPosition"),
           let position = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: NSValue.self, from: positionData)?.pointValue {
            // Validate position is on screen
            if let screen = NSScreen.main,
               screen.visibleFrame.contains(NSRect(origin: position, size: panel.frame.size)) {
                panel.setFrameOrigin(position)
            }
        }
    }

    private func setupWindowPositionObserver() {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.saveWindowPosition()
        }
    }

    private func saveWindowPosition() {
        let defaults = UserDefaults.standard
        let positionValue = NSValue(point: panel.frame.origin)
        let positionData = try? NSKeyedArchiver.archivedData(
            withRootObject: positionValue, requiringSecureCoding: true)
        defaults.set(positionData, forKey: "DocketWindowPosition")
    }
}
```

**Key Features**:
- ✅ Window lifecycle management
- ✅ Position persistence
- ✅ Auto Layout setup

#### 1.3 AppDelegate.swift (CONVERTED from DocketApp.swift)
**Lines of Code**: ~200 LOC
**Replaces**: SwiftUI App struct

```swift
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    // Singletons
    var windowController: DocketWindowController?
    let appModel = AppModel()
    let calendarManager = CalendarManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create floating panel
        let panel = DocketPanel(
            contentRect: NSRect(x: 100, y: 100, width: 720, height: 950),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Create content view controller
        let contentVC = ContentViewController(
            appModel: appModel,
            calendarManager: calendarManager
        )

        // Setup window controller
        windowController = DocketWindowController(
            window: panel,
            contentViewController: contentVC
        )

        // Show window
        windowController?.showWindow(nil)

        // Activate and bring to front
        NSApp.activate(ignoringOtherApps: true)

        // Start auto-refresh
        calendarManager.startAutoRefresh()

        // Observe pin state changes
        setupAlwaysOnTopObserver()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        calendarManager.resumeAutoRefresh()
    }

    func applicationDidResignActive(_ notification: Notification) {
        // Keep running - users want widget visible even when app is background
    }

    private func setupAlwaysOnTopObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("alwaysOnTopDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let alwaysOnTop = notification.userInfo?["alwaysOnTop"] as? Bool {
                self?.windowController?.panel.level = alwaysOnTop ? .floating : .normal
            }
        }
    }
}
```

**Key Features**:
- ✅ App entry point
- ✅ Singleton management
- ✅ Window creation and lifecycle
- ✅ Calendar permissions & refresh integration

### Priority 2: Container Views (Week 2)

#### 2.1 MeetingsListViewController.swift
**Lines of Code**: ~250 LOC
**Replaces**: MeetingsListView.swift (229 LOC)

**Responsibilities**:
- Main view controller hierarchy
- NSScrollView + NSStackView for meetings
- Day section management
- State conditional rendering
- Data binding via Combine

**Implementation Pattern**:
```swift
class MeetingsListViewController: NSViewController {
    weak var appModel: AppModel?
    weak var calendarManager: CalendarManager?

    private let scrollView = NSScrollView()
    private let stackView = NSStackView()
    private let emptyStateVC = EmptyStateViewController()
    private let loadingStateVC = LoadingStateViewController()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataBindings()
    }

    private func setupUI() {
        // Configure scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // ... setup constraints

        // Configure stack view
        scrollView.documentView = stackView
        stackView.orientation = .vertical
        stackView.distribution = .fill
    }

    private func setupDataBindings() {
        // Observe meetings changes
        calendarManager?.publisher(for: \.meetings)
            .sink { [weak self] _ in
                self?.updateMeetingsList()
            }
            .store(in: &cancellables)

        // Observe auth state
        calendarManager?.publisher(for: \.authState)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }

    private func updateMeetingsList() {
        // Clear existing views
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0); $0.removeFromSuperview() }

        // Add day sections
        if !yesterdayMeetings.isEmpty {
            addDaySection("Yesterday", meetings: yesterdayMeetings)
        }
        addDaySection("Today", meetings: todayMeetings)
        if !tomorrowMeetings.isEmpty {
            addDaySection("Tomorrow", meetings: tomorrowMeetings)
        }
    }
}
```

#### 2.2 MeetingRowView (NSView subclass)
**Lines of Code**: ~180 LOC
**Replaces**: MeetingRowView.swift (160 LOC)

**Auto Layout Pattern**:
```swift
class MeetingRowView: NSView {
    let meeting: Meeting

    // Subviews
    private let backgroundEffect = NSVisualEffectView()
    private let titleLabel = NSTextField()
    private let timeView = MeetingTimeView()
    private let platformIndicator = PlatformIndicatorView()
    private let detailsView = MeetingDetailsView()
    private let copyButton = MeetingCopyButton()
    private let joinButton = MeetingJoinButton()

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Background with material
        backgroundEffect.material = .regularMaterial
        backgroundEffect.blendingMode = .withinWindow
        addSubview(backgroundEffect)

        // Title label
        titleLabel.isEditable = false
        titleLabel.isBezeled = false
        titleLabel.stringValue = meeting.title
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        addSubview(titleLabel)

        // Time view (custom NSView)
        addSubview(timeView)

        // Platform + Details in horizontal stack
        let detailsStack = NSStackView()
        detailsStack.orientation = .horizontal
        detailsStack.addArrangedSubview(platformIndicator)
        detailsStack.addArrangedSubview(detailsView)
        addSubview(detailsStack)

        // Action buttons
        addSubview(copyButton)
        addSubview(joinButton)

        // Setup constraints...
    }
}
```

#### 2.3 DaySectionView (NSView subclass)
**Lines of Code**: ~60 LOC
**Replaces**: DaySectionView.swift (70 LOC)

```swift
class DaySectionView: NSView {
    let title: String
    let meetings: [Meeting]

    private let headerLabel = NSTextField()
    private let meetingsStack = NSStackView()

    init(title: String, meetings: [Meeting]) {
        self.title = title
        self.meetings = meetings
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Header
        headerLabel.stringValue = title
        headerLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        headerLabel.textColor = .labelColor
        addSubview(headerLabel)

        // Meeting rows stack
        meetingsStack.orientation = .vertical
        for meeting in meetings {
            let rowView = MeetingRowView(meeting: meeting)
            meetingsStack.addArrangedSubview(rowView)
        }
        addSubview(meetingsStack)

        // Layout...
    }
}
```

### Priority 3: Components (Week 3)

#### 3.1 Button Components (NSButton subclasses)

**PinButton.swift** (49 LOC → 70 LOC)
```swift
class PinButton: NSButton {
    weak var appModel: AppModel?
    var isPinned: Bool = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        title = ""
        image = NSImage(systemSymbolName: "pin", accessibilityDescription: "Pin")
        bezelStyle = .regularSquare
        isBordered = false
        target = self
        action = #selector(togglePinned)
        toolTip = "Pin window (keep on top)"
    }

    @objc private func togglePinned() {
        appModel?.alwaysOnTop.toggle()
        updateAppearance()
    }

    private func updateAppearance() {
        if appModel?.alwaysOnTop ?? false {
            image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: "Pinned")
            contentTintColor = .systemBlue
        } else {
            image = NSImage(systemSymbolName: "pin", accessibilityDescription: "Not pinned")
            contentTintColor = .secondaryLabelColor
        }
    }
}
```

**MeetingJoinButton.swift** (149 LOC → 170 LOC)
```swift
class MeetingJoinButton: NSButton {
    let meeting: Meeting
    var isJoining = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        title = "Join"
        font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        contentTintColor = meeting.platform.color
        bezelStyle = .rounded
        target = self
        action = #selector(performJoin)
    }

    @objc private func performJoin() {
        guard let urlString = meeting.joinUrl,
              let url = URL(string: urlString) else { return }

        isJoining = true
        isEnabled = false

        NSWorkspace.shared.open(url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isJoining = false
            self?.isEnabled = true
        }
    }
}
```

#### 3.2 Status Display Components

**StatusBarView.swift** (194 LOC)
```swift
class StatusBarView: NSView {
    weak var appModel: AppModel?
    weak var calendarManager: CalendarManager?

    private let refreshItem = StatusBarRefreshItemView()
    private let hideButton = HideCompletedButton()

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Background
        let effectView = NSVisualEffectView()
        effectView.material = .regularMaterial
        addSubview(effectView)

        // Horizontal stack: refresh | spacer | hide button
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.distribution = .fill
        stack.spacing = 12

        stack.addArrangedSubview(refreshItem)
        let spacer = NSView()
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(hideButton)

        addSubview(stack)

        // Layout...
    }
}
```

### Priority 4: State Views

**EmptyStateViewController.swift** (122 LOC)
- Permission denied view
- Calendar access required view
- Error state view
- Uses NSImageView + NSTextField + NSButton

**LoadingStateViewController.swift** (56 LOC)
- NSProgressIndicator (spinning)
- NSTextField for status message
- Centered layout

---

## 6. Liquid Glass Implementation Guide (macOS 26 Tahoe)

### Material Selection for 2025

**NSVisualEffectView.Material Options** (Tahoe 2025):

```swift
// Recommended for Docket:
.hudWindow      // ← Perfect for floating panels (our use case)
.popover        // ← For popup-style content
.windowBackground // ← For standard window backgrounds

// Deprecated (don't use):
.sidebar        // ❌ Blocks glass in Tahoe
.light          // ❌ Legacy color-based
.dark           // ❌ Legacy color-based
.mediumLight    // ❌ Legacy color-based
```

### Live-Update Pattern

**The Problem with SwiftUI:**
```swift
// SwiftUI (doesn't update on window move)
.containerBackground(.ultraThinMaterial, for: .window)
// Material sampled once → stale as window moves
```

**The AppKit Solution:**
```swift
// AppKit NSVisualEffectView (updates continuously)
let effectView = NSVisualEffectView()
effectView.material = .hudWindow  // Tahoe semantic material
effectView.blendingMode = .behindWindow  // Key: shows through content
effectView.state = .active
effectView.autoresizingMask = [.width, .height]

// Automatically re-samples as window moves ✅
// GPU-accelerated rendering ✅
// No manual invalidation needed ✅
```

### Blending Mode Selection

```swift
// .behindWindow
// - Material appears BEHIND the view content
// - Shows through view's transparent areas
// - Perfect for floating panels
// - Content (buttons, text) appears OVER the glass
effectView.blendingMode = .behindWindow

// .withinWindow (alternative)
// - Material appears as part of the view
// - Creates frosted glass effect with content
// - Use for row backgrounds (MeetingRowView)
effectView.blendingMode = .withinWindow
```

### Corner Radius for Tahoe

**New API** (macOS 26):
```swift
// Use NSView.LayoutRegion for corner-aware layouts
// Avoids clipping content near window corners

let safeArea = layoutGuide(for: .safeArea(cornerAdaptation: .horizontal))
// Access guides: .horizontal, .vertical, or both

// Larger corner radius for windows with toolbars
// Smaller for titlebar-only windows
```

### Vibrancy Integration

```swift
// NSVisualEffectView provides vibrancy automatically
// But text/controls must use system colors

// ✅ DO use:
label.textColor = .labelColor
label.textColor = .secondaryLabelColor

// ❌ DON'T use:
label.textColor = .black  // Doesn't vibrate
label.textColor = UIColor(red:, green:, blue:, alpha:)
```

### Real-Time Material Sampling

**How NSVisualEffectView Works in Tahoe:**

1. **Continuous Sampling**: GPU continuously samples framebuffer behind view
2. **Blur Application**: Real-time blur filter applied to sampled content
3. **Adaptive Darkening**: Material lightens/darkens based on content brightness
4. **Window Movement**: Automatically re-samples as window position changes
5. **Light/Dark Mode**: Material adapts to system appearance

**Result**: Perfect glass effect that tracks content in real-time ✅

---

## 7. Data Flow & State Management

### AppModel Integration

**Current @Observable Pattern:**
```swift
@Observable
public final class AppModel: @unchecked Sendable {
    private var _alwaysOnTop: Bool = false

    public var alwaysOnTop: Bool {
        get { _alwaysOnTop }
        set {
            _alwaysOnTop = newValue
            // Post notification for AppKit
            NotificationCenter.default.post(
                name: Notification.Name("alwaysOnTopDidChange"),
                object: nil,
                userInfo: ["alwaysOnTop": newValue]
            )
        }
    }
}
```

**AppKit Observation Pattern:**
```swift
class MeetingsListViewController: NSViewController {
    weak var appModel: AppModel?
    private var cancellables = Set<AnyCancellable>()

    func setupDataBindings() {
        // Observe alwaysOnTop changes via notification
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("alwaysOnTopDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let alwaysOnTop = notification.userInfo?["alwaysOnTop"] as? Bool {
                print("Always on top changed to: \(alwaysOnTop)")
            }
        }

        // Alternative: Direct property observation (Combine)
        appModel?.publisher(for: \.hideCompletedMeetingsAfter5Min)
            .sink { [weak self] hideCompleted in
                self?.reloadMeetings()
            }
            .store(in: &cancellables)
    }
}
```

### CalendarManager Integration

**Observable Properties:**
```swift
@Observable
class CalendarManager: @unchecked Sendable {
    @ObservationTracked var meetings: [Meeting] = []
    @ObservationTracked var isRefreshing: Bool = false
    @ObservationTracked var authState: CalendarAuthState = .notDetermined
}
```

**AppKit Consumption:**
```swift
class MeetingsListViewController: NSViewController {
    weak var calendarManager: CalendarManager?

    func setupDataBindings() {
        // Observe meetings array changes
        calendarManager?.publisher(for: \.meetings)
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] updatedMeetings in
                self?.updateMeetingsList(updatedMeetings)
            }
            .store(in: &cancellables)

        // Observe loading state
        calendarManager?.publisher(for: \.isRefreshing)
            .sink { [weak self] isRefreshing in
                self?.updateLoadingState(isRefreshing)
            }
            .store(in: &cancellables)
    }

    private func updateMeetingsList(_ meetings: [Meeting]) {
        // Apply filter based on appModel state
        let filtered = meetings.filter { meeting in
            !meeting.shouldBeHidden(
                hideCompletedAfter5Min: appModel?.hideCompletedMeetingsAfter5Min ?? true
            )
        }

        // Update UI
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        filtered.forEach { meeting in
            let rowView = MeetingRowView(meeting: meeting)
            stackView.addArrangedSubview(rowView)
        }
    }
}
```

### Observation Cleanup (Memory Safety)

**Critical**: Clean up observations on deinit
```swift
class MeetingsListViewController: NSViewController {
    private var cancellables = Set<AnyCancellable>()

    deinit {
        // Automatically cleans up all Combine subscriptions
        cancellables.removeAll()
    }
}
```

---

## 8. Testing Strategy

### Business Logic Tests (262 - NO CHANGES)

**Preserved Test Suites:**

```
Tests/DocketKitTests/
├── MeetingTests.swift (262 tests)
│   ✅ Meeting state calculations
│   ✅ Time-based filtering
│   ✅ Duration calculations
│   └── All pass unchanged
│
├── AppModelTests.swift
│   ✅ Observable property changes
│   ✅ Notification posting
│   └── All pass unchanged
│
├── CalendarManagerTests.swift
│   ✅ EventKit integration
│   ✅ Meeting extraction
│   ✅ Auto-refresh logic
│   └── All pass unchanged
│
├── MeetingPlatformTests.swift
│   ✅ Platform detection
│   ✅ Color assignment
│   └── All pass unchanged
│
└── MeetingURLExtractorTests.swift
    ✅ URL extraction from multiple fields
    ✅ Platform-specific regex patterns
    └── All pass unchanged
```

### New AppKit View Tests (XCTest)

```swift
// Example: DocketPanel Tests
class DocketPanelTests: XCTestCase {
    var panel: DocketPanel!

    override func setUp() {
        super.setUp()
        panel = DocketPanel(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 950),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
    }

    func testFloatingPanelConfiguration() {
        XCTAssertTrue(panel.isFloatingPanel)
        XCTAssertEqual(panel.level, .floating)
        XCTAssertTrue(panel.collectionBehavior.contains(.canJoinAllSpaces))
    }

    func testLiquidGlassBackground() {
        XCTAssertNotNil(panel.contentView)
        // Verify NSVisualEffectView is in subview hierarchy
    }

    func testWindowTransparency() {
        XCTAssertFalse(panel.isOpaque)
        XCTAssertEqual(panel.backgroundColor, .clear)
    }
}

// Example: MeetingRowView Tests
class MeetingRowViewTests: XCTestCase {
    var meetingView: MeetingRowView!

    override func setUp() {
        super.setUp()
        let meeting = PreviewData.activeMeeting
        meetingView = MeetingRowView(meeting: meeting)
    }

    func testViewCreation() {
        XCTAssertNotNil(meetingView)
        XCTAssertEqual(meetingView.frame.size.height, 100)
    }

    func testSubviewHierarchy() {
        XCTAssertGreaterThan(meetingView.subviews.count, 0)
        // Verify NSVisualEffectView, labels, buttons present
    }

    func testLayoutConstraints() {
        XCTAssertNotNil(meetingView.constraints)
        // Verify auto layout is properly configured
    }
}
```

### UI Integration Tests

```swift
// Example: Full window flow
class IntegrationTests: XCTestCase {
    var windowController: DocketWindowController!

    override func setUp() {
        super.setUp()
        let panel = DocketPanel(/* ... */)
        let contentVC = ContentViewController(/* ... */)
        windowController = DocketWindowController(window: panel, contentViewController: contentVC)
    }

    func testWindowDisplaysContent() {
        windowController.showWindow(nil)
        XCTAssertNotNil(windowController.panel.contentViewController)
        XCTAssertTrue(windowController.panel.isVisible)
    }

    func testMeetingsDisplay() {
        // Simulate calendar manager updates
        // Verify meetings appear in UI
    }
}
```

### Accessibility Testing

```swift
// VoiceOver and Keyboard Navigation
func testAccessibility() {
    let button = MeetingJoinButton()

    // Verify accessibility labels
    XCTAssertNotNil(button.accessibilityLabel)
    XCTAssertNotNil(button.accessibilityHelp)

    // Verify keyboard navigation
    XCTAssertTrue(button.canBecomeKeyView)
}
```

---

## 9. Migration Path (4-Week Timeline)

### Week 1: Infrastructure (5 days)

**Day 1-2: DocketPanel + Window Configuration**
- [ ] Create DocketPanel.swift
- [ ] Implement NSVisualEffectView with .hudWindow material
- [ ] Configure floating panel properties
- [ ] Test window displays with glass background
- ✅ Checkpoint: Window visible with live-updating material

**Day 3: DocketWindowController**
- [ ] Create DocketWindowController.swift
- [ ] Implement window position persistence
- [ ] Setup lifecycle management
- ✅ Checkpoint: Window position saved/restored correctly

**Day 4: AppDelegate Conversion**
- [ ] Convert DocketApp.swift → AppDelegate.swift
- [ ] Setup singleton management (appModel, calendarManager)
- [ ] Implement app lifecycle methods
- [ ] Test window creation on app launch
- ✅ Checkpoint: App launches, calendar permissions requested

**Day 5: Liquid Glass Polish**
- [ ] Verify material updates on window movement
- [ ] Test light/dark mode switching
- [ ] Verify corner radius handling
- ✅ Week 1 Milestone: Floating panel with live Liquid Glass background

### Week 2: Core Views (5 days)

**Day 6-7: MeetingsListViewController**
- [ ] Create MeetingsListViewController.swift
- [ ] Implement NSScrollView + NSStackView
- [ ] Setup data bindings from CalendarManager
- [ ] Test meetings render from live data
- ✅ Checkpoint: Meetings list displays and auto-updates

**Day 8-9: MeetingRowView Component**
- [ ] Convert MeetingRowView to NSView
- [ ] Implement horizontal NSStackView layout
- [ ] Add NSVisualEffectView background
- [ ] Integrate child components
- ✅ Checkpoint: Individual meetings render correctly

**Day 10: Day Sections + Empty/Loading States**
- [ ] Convert DaySectionView to NSView
- [ ] Convert EmptyStateView to NSViewController
- [ ] Convert LoadingStateView to NSViewController
- [ ] Test state switching (loading → content → empty)
- ✅ Week 2 Milestone: Main meetings list functional with all states

### Week 3: Components (5 days)

**Day 11-12: Button Components**
- [ ] Convert PinButton to NSButton
- [ ] Convert HideCompletedButton to NSButton
- [ ] Convert MeetingJoinButton to NSButton
- [ ] Convert MeetingCopyButton to NSButton
- [ ] Test all interactions work
- ✅ Checkpoint: All buttons functional

**Day 13-14: Status Bar + Display Components**
- [ ] Convert StatusBar to NSView
- [ ] Convert StatusBarRefreshItem to NSView
- [ ] Convert PlatformIndicatorView to NSView
- [ ] Convert MeetingTimeView to NSTextField subclass
- [ ] Convert MeetingDetailsView to NSView
- [ ] Convert RefreshStatusIcon to NSImageView
- [ ] Convert RefreshStatusText to NSTextField
- ✅ Checkpoint: All display elements rendering correctly

**Day 15: Animations**
- [ ] Implement button animations using CABasicAnimation
- [ ] Implement icon rotations for PinButton
- [ ] Implement refresh icon animation
- [ ] Polish interactions and timing
- ✅ Week 3 Milestone: All components complete and interactive

### Week 4: Testing & Polish (5 days)

**Day 16-17: Update Test Suite**
- [ ] Verify all 262 business logic tests pass
- [ ] Create AppKit view tests
- [ ] Fix any integration issues
- ✅ Checkpoint: All tests passing

**Day 18: Manual QA Testing**
- [ ] Test on single monitor
- [ ] Test on multi-monitor setup
- [ ] Test light/dark mode switching
- [ ] Test always-on-top toggling
- [ ] Test calendar access flow
- [ ] Test meeting URL extraction
- [ ] Test refresh functionality
- ✅ Checkpoint: No regressions found

**Day 19: Performance Optimization**
- [ ] Profile with Instruments (Time Profiler)
- [ ] Check for memory leaks
- [ ] Optimize view hierarchy depth
- [ ] Verify startup time
- ✅ Checkpoint: Performance acceptable

**Day 20: Documentation**
- [ ] Update CLAUDE.md with AppKit architecture
- [ ] Update DESIGN_SYSTEM.md for AppKit components
- [ ] Document migration path for future changes
- [ ] Create AppKit component development guide
- ✅ Week 4 Milestone: Production-ready release

---

## 10. Risk Assessment & Mitigation

### High-Risk Areas

#### Risk 1: Memory Leaks in NSView Hierarchy
**Severity**: 🔴 HIGH
**Likelihood**: 🟡 MEDIUM

**Problem**:
- NSView retain cycles if weak self not used
- Combine subscriptions not cleaned up
- NotificationCenter observers not removed

**Mitigation**:
```swift
// ✅ DO: Use weak self in closures
calendarManager?.publisher(for: \.meetings)
    .sink { [weak self] meetings in
        self?.updateMeetings(meetings)
    }
    .store(in: &cancellables)

// ✅ DO: Store cancellables and clean on deinit
private var cancellables = Set<AnyCancellable>()

deinit {
    cancellables.removeAll()
}

// ❌ DON'T: Store strong references
calendarManager?.publisher(for: \.meetings)
    .sink { [self] meetings in  // Strong reference!
        self.updateMeetings(meetings)
    }
    .store(in: &cancellables)
```

**Testing**:
- Use Instruments (Allocations tool) to verify cleanup
- Watch for leaked NSView objects in deinit
- Profile startup/shutdown cycles

#### Risk 2: Auto Layout Constraint Conflicts
**Severity**: 🔴 HIGH
**Likelihood**: 🟡 MEDIUM

**Problem**:
- NSStackView adds automatic constraints
- Manual constraints can conflict
- Broken layout on configuration changes

**Mitigation**:
```swift
// ✅ DO: Let NSStackView manage layout
let stack = NSStackView()
stack.addArrangedSubview(subview1)
stack.addArrangedSubview(subview2)
// Don't add manual constraints to arranged subviews

// ❌ DON'T: Mix manual constraints with arranged subviews
stack.addArrangedSubview(subview)
subview.heightAnchor.constraint(equalToConstant: 50).isActive = true
// Conflicts with NSStackView's constraints
```

**Testing**:
- Use Xcode's view hierarchy debugger
- Visual Layout Debugger to identify conflicts
- Test on various window sizes

#### Risk 3: NSVisualEffectView Performance
**Severity**: 🟡 MEDIUM
**Likelihood**: 🟡 MEDIUM

**Problem**:
- Multiple NSVisualEffectViews can impact GPU usage
- Blur effect is computationally expensive
- Excessive re-rendering on animation

**Mitigation**:
```swift
// ✅ DO: Minimize number of effect views
// One effect view per panel background (good)
// One effect view per row background (acceptable)
// Multiple effect views per row (bad - too many)

// ✅ DO: Use layer-backed views for static content
staticView.wantsLayer = true

// ✅ DO: Batch view updates
NSAnimationContext.beginGrouping()
  stackView.addArrangedSubview(newView)
  stackView.layoutSubtreeIfNeeded()
NSAnimationContext.endGrouping()
```

**Testing**:
- Use Instruments (GPU utilization)
- Verify 60 FPS rendering
- Profile with multiple meetings displayed

### Medium-Risk Areas

#### Risk 4: @Observable to AppKit Bridge
**Severity**: 🟡 MEDIUM
**Likelihood**: 🟠 LOW-MEDIUM

**Problem**:
- SwiftUI's @Observable not designed for AppKit
- KVO bridge might not work in all cases
- Type compatibility issues

**Mitigation**:
- Use Combine publishers as primary observation mechanism
- Fallback to NotificationCenter for complex state
- Thoroughly test observation patterns early

#### Risk 5: Test Suite Breakage
**Severity**: 🟡 MEDIUM
**Likelihood**: 🟠 LOW-MEDIUM

**Problem**:
- 262 tests depend on business logic correctness
- UI tests may fail on constraint issues
- Regression tests not kept up to date

**Mitigation**:
- Run tests after each major conversion
- Fix failing tests immediately
- Maintain test coverage > 90%

#### Risk 6: Multi-Monitor Edge Cases
**Severity**: 🟡 MEDIUM
**Likelihood**: 🟠 LOW-MEDIUM

**Problem**:
- Window positioning issues across screens
- Liquid Glass rendering different per display
- Position restoration on disconnected monitor

**Mitigation**:
```swift
// ✅ Validate position is on available screen
if let screen = NSScreen.main,
   screen.visibleFrame.contains(NSRect(origin: position, size: windowSize)) {
    window.setFrameOrigin(position)
} else {
    // Position window on main screen
    window.center()
}
```

**Testing**:
- Test with 2 monitors (various DPI, resolutions)
- Test after disconnecting monitor
- Test with window on secondary screen

### Low-Risk Areas

#### Risk 7: Animation Performance
**Severity**: 🟢 LOW
**Likelihood**: 🟢 LOW

**Mitigation**:
- Use CABasicAnimation (efficient)
- Avoid frequent layout passes during animation
- Profile frame rate during animations

#### Risk 8: Accessibility Regression
**Severity**: 🟢 LOW
**Likelihood**: 🟢 LOW

**Mitigation**:
- Test with VoiceOver enabled
- Verify keyboard navigation works
- Maintain accessibility labels on all controls

---

## 11. Code Examples & Patterns

### Pattern 1: NSVisualEffectView with Liquid Glass

```swift
// Complete implementation
let effectView = NSVisualEffectView()

// Configure for Tahoe 2025
effectView.material = .hudWindow              // Semantic material
effectView.blendingMode = .behindWindow       // Behind content
effectView.state = .active                    // Always active
effectView.autoresizingMask = [.width, .height]

// Add to view hierarchy (as background)
containerView.addSubview(effectView, positioned: .below, relativeTo: nil)
effectView.frame = containerView.bounds

// Result: Live-updating glass effect ✅
```

### Pattern 2: NSStackView with Auto Layout

```swift
// Vertical meetings list
let mainStack = NSStackView()
mainStack.orientation = .vertical
mainStack.distribution = .fill
mainStack.alignment = .leading
mainStack.spacing = 8

// Add day sections
mainStack.addArrangedSubview(daySectionView1)
mainStack.addArrangedSubview(daySectionView2)

// Container with scroll view
let scrollView = NSScrollView()
scrollView.documentView = mainStack
containerView.addSubview(scrollView)

// Constraints - let scroll view fill container
scrollView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
    scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    scrollView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    scrollView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
])
```

### Pattern 3: Combine Observation

```swift
// Observe @Observable properties from AppKit
class MeetingsViewController: NSViewController {
    weak var calendarManager: CalendarManager?
    private var cancellables = Set<AnyCancellable>()

    func observeData() {
        // Observe meetings array
        calendarManager?.publisher(for: \.meetings)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] meetings in
                self?.updateMeetingsList(meetings)
            }
            .store(in: &cancellables)

        // Observe refresh state
        calendarManager?.publisher(for: \.isRefreshing)
            .sink { [weak self] isRefreshing in
                self?.updateLoadingState(isRefreshing)
            }
            .store(in: &cancellables)

        // Observe auth state
        calendarManager?.publisher(for: \.authState)
            .sink { [weak self] authState in
                self?.updateAuthState(authState)
            }
            .store(in: &cancellables)
    }

    deinit {
        // Automatic cleanup via cancellables
        cancellables.removeAll()
    }
}
```

### Pattern 4: NSButton Subclass

```swift
// Custom button with state management
class MeetingJoinButton: NSButton {
    let meeting: Meeting
    var isJoining = false {
        didSet {
            isEnabled = !isJoining
            updateTitle()
        }
    }

    init(meeting: Meeting) {
        self.meeting = meeting
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        title = "Join"
        font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        contentTintColor = meeting.platform.color
        bezelStyle = .rounded
        target = self
        action = #selector(performJoin)
    }

    private func updateTitle() {
        title = isJoining ? "Joining..." : "Join"
    }

    @objc private func performJoin() {
        guard let urlString = meeting.joinUrl,
              let url = URL(string: urlString) else { return }

        isJoining = true

        NSWorkspace.shared.open(url)

        // Reset state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isJoining = false
        }
    }
}
```

### Pattern 5: View Controller State Management

```swift
class ContentViewController: NSViewController {
    weak var appModel: AppModel?
    weak var calendarManager: CalendarManager?

    private var cancellables = Set<AnyCancellable>()
    private let meetingsListVC = MeetingsListViewController()
    private let emptyStateVC = EmptyStateViewController()
    private let loadingStateVC = LoadingStateViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(meetingsListVC)
        view.addSubview(meetingsListVC.view)

        setupDataBindings()
    }

    private func setupDataBindings() {
        // Observe auth state to determine which view to show
        calendarManager?.publisher(for: \.authState)
            .sink { [weak self] authState in
                self?.updateViewState(for: authState)
            }
            .store(in: &cancellables)

        // Observe loading state
        calendarManager?.publisher(for: \.isRefreshing)
            .sink { [weak self] isRefreshing in
                self?.updateLoadingIndicator(isRefreshing)
            }
            .store(in: &cancellables)
    }

    private func updateViewState(for authState: CalendarAuthState) {
        switch authState {
        case .notDetermined:
            showView(loadingStateVC)
        case .authorized, .fullAccess:
            showView(meetingsListVC)
        default:
            showView(emptyStateVC)
        }
    }

    private func showView(_ viewController: NSViewController) {
        removeCurrentView()
        addChild(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }

    private func removeCurrentView() {
        children.forEach { $0.removeFromParent(); $0.view.removeFromSuperview() }
    }
}
```

---

## 12. Performance Considerations

### View Hierarchy Optimization

**Good** (shallow, efficient):
```swift
panel
└── effect view (1 level)
    └── scroll view (1 level)
        └── stack view (1 level)
            └── row views (parallel, not nested)
```

**Bad** (deep, inefficient):
```swift
panel
└── container
    └── effect view
        └── scroll view
            └── clipView
                └── document view
                    └── stack view
                        └── ... (too deep)
```

**Recommendation**: Keep NSView hierarchy ≤ 5 levels deep.

### Rendering Performance

| Operation | Cost | Notes |
|-----------|------|-------|
| NSVisualEffectView (1) | Low | GPU-accelerated, essential |
| NSVisualEffectView (per row) | Medium | Acceptable for <50 rows |
| Excessive nested stacks | High | Flatten where possible |
| Frequent constraint changes | High | Batch with NSAnimationContext |
| Dynamic text layout | Low | Use monospaced for fixed width |

### Memory Management

**Measurements** (estimated):
- DocketPanel: ~2 MB
- Empty view hierarchy: ~5 MB
- With 20 meetings: ~15 MB
- NSVisualEffectView per row: +0.5 MB each

**Optimization**:
- Recycle NSView instances for large lists (not doing for Docket)
- Cache attributed strings (text rendering)
- Profile with Instruments (Memory gauge)

### Startup Time

**Current SwiftUI**: ~600ms (as observed)
**Target AppKit**: <500ms

**Breakdown**:
- App launch: 50ms
- Window creation: 100ms
- View hierarchy setup: 150ms
- Data binding: 100ms
- Calendar permissions: async (200ms background)

---

## 13. Accessibility (VoiceOver)

### Required Accessibility Labels

```swift
// MeetingRowView
meetingRowView.setAccessibilityElement(true)
meetingRowView.setAccessibilityLabel("Meeting: \(meeting.title)")
meetingRowView.setAccessibilityHelp(
    "Time: \(meeting.timeString), Platform: \(meeting.platform.displayName)"
)

// Join Button
joinButton.setAccessibilityLabel("Join meeting")
joinButton.setAccessibilityHelp("Opens \(meeting.platform.displayName) meeting URL")

// Copy Button
copyButton.setAccessibilityLabel("Copy meeting link")
copyButton.setAccessibilityHelp("Copies meeting URL to clipboard")
```

### Keyboard Navigation

```swift
// Make views focusable in tab order
button.canBecomeKeyView = true
textField.canBecomeKeyView = true

// Configure tab order
window.initialFirstResponder = startButton
```

### Testing VoiceOver

1. Enable: System Preferences → Accessibility → VoiceOver
2. Test: Cmd+F5 to toggle
3. Navigate: VO+Right Arrow (next), VO+Left Arrow (previous)
4. Interact: VO+Space (click), VO+Up/Down (read)

---

## 14. Internationalization

### RTL Support (Arabic, Hebrew)

**Use leading/trailing (not left/right):**

```swift
// ✅ DO:
NSLayoutConstraint.activate([
    subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
])

// ❌ DON'T:
NSLayoutConstraint.activate([
    subview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
    subview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
])
```

### Text Localization

```swift
// Use NSLocalizedString
label.stringValue = NSLocalizedString("Join", comment: "Button to join meeting")

// Date/Time formatting
let formatter = DateFormatter()
formatter.locale = Locale.autoupdatingCurrent  // Respects system locale
formatter.dateStyle = .short
formatter.timeStyle = .short
dateLabel.stringValue = formatter.string(from: meeting.startTime)
```

---

## 15. Deployment Strategy

### Version Strategy

**Current**: 1.x.x (SwiftUI)
**Next**: 2.0.0 (AppKit)

**Release Notes**:
```
Docket 2.0 - Complete AppKit Rewrite

Major Changes:
- Rebuilt UI with AppKit for native macOS integration
- Liquid Glass material background now updates in real-time
- Improved performance and memory efficiency
- Enhanced floating window behavior

Requirements:
- macOS 15.0 or later (no change)
- Apple Silicon or Intel Mac

Known Issues:
- None - comprehensive testing completed

Migration:
- Automatic update recommended
- Can downgrade to 1.x if issues occur
```

### Staged Rollout

1. **Alpha** (week 1): Internal testing only
2. **Beta** (weeks 2-3): ~1% of users via TestFlight
3. **Candidate RC** (week 4): ~10% of users
4. **General Release**: 100% of users

### Support Timeline

| Version | Status | Support Until |
|---------|--------|---|
| 1.x | Legacy | 6 months |
| 2.0 | Current | Latest |

---

## 16. Rollback Plan

### If Issues Arise

**Immediate Action**:
1. Identify root cause
2. Patch AppKit version (2.0.x) if possible
3. If unfixable, revert to 1.x

**Version Pinning**:
```
// In App Store Connect
Docket 2.0 - Available for macOS 15.0+
Docket 1.x - Legacy version (archived)
```

**User Communication**:
```
If you experience issues with 2.0:

1. Try restarting the app
2. Check system requirements (macOS 15.0+)
3. Report issue: https://github.com/TrevorS/Docket/issues
4. Downgrade to 1.x temporarily (see Releases page)
```

**Downgrade Instructions**:
1. Go to GitHub Releases
2. Download Docket-1.x.zip
3. Unzip and drag to Applications
4. Delete existing 2.0 version

---

## 17. Documentation Updates

### Files to Update

**CLAUDE.md** (Project Guidelines)
- [ ] Update framework from SwiftUI to AppKit
- [ ] Update architecture diagram
- [ ] Update file structure
- [ ] Update development guidelines
- [ ] Update testing approach

**DESIGN_SYSTEM.md** (Component Patterns)
- [ ] Add AppKit component patterns
- [ ] Document NSView subclassing approach
- [ ] Document layout patterns (NSStackView, Auto Layout)
- [ ] Add animation patterns (CABasicAnimation)

**TESTING_CHECKLIST.md** (QA Procedures)
- [ ] Add AppKit view testing approach
- [ ] Update component test patterns
- [ ] Add integration testing steps
- [ ] Add accessibility testing procedures

**README.md**
- [ ] Update "Technology" section
- [ ] Update "Architecture" section
- [ ] Update development commands
- [ ] Add AppKit development notes

### New Documentation

**docs/APPKIT_GUIDE.md**
- NSView subclassing patterns
- NSViewController best practices
- Combining AppKit + SwiftUI (@Observable)
- Memory management in AppKit
- Performance optimization tips

**docs/LIQUID_GLASS_GUIDE.md**
- Material selection for macOS 26
- Live-update patterns
- Blending mode selection
- VoiceOver support

---

## 18. Timeline Summary

### 4-Week Implementation Schedule

```
Week 1: Infrastructure ████░░░░░░░░░░░░░░░░░░░░░ 20%
├─ Days 1-2: DocketPanel + window setup
├─ Day 3: DocketWindowController
├─ Day 4: AppDelegate conversion
└─ Day 5: Liquid Glass polish

Week 2: Core Views ████░░░░░░░░░░░░░░░░░░░░░ 40%
├─ Days 6-7: MeetingsListViewController
├─ Days 8-9: MeetingRowView
└─ Day 10: Day sections + state views

Week 3: Components ████░░░░░░░░░░░░░░░░░░░░░ 60%
├─ Days 11-12: Button components
├─ Days 13-14: Status bar + display components
└─ Day 15: Animations

Week 4: Testing ████░░░░░░░░░░░░░░░░░░░░░ 100%
├─ Days 16-17: Test suite + fixes
├─ Day 18: Manual QA
├─ Day 19: Performance optimization
└─ Day 20: Documentation

Post-Launch:
└─ Week 5: Staged rollout + monitoring
```

### Success Metrics

✅ **Functional Metrics**:
- All 262 business logic tests pass
- Material background updates live
- Floating panel behaves correctly
- No regressions in core features

✅ **Performance Metrics**:
- Startup time < 500ms
- Memory usage < 50 MB
- 60 FPS rendering
- No memory leaks

✅ **Quality Metrics**:
- 100% code coverage for business logic
- 80%+ test coverage for UI layer
- Zero P0/P1 bugs in first week
- Accessibility score: A (VoiceOver)

---

## Appendix A: File Migration Checklist

```
✅ Files Remaining (No Changes Required):
├─ Meeting.swift
├─ MeetingPlatform.swift
├─ AppModel.swift
├─ CalendarManager.swift
├─ MeetingURLExtractor.swift
├─ Logger.swift
└─ EKEvent+CalendarEventLike.swift

✨ New Files (AppKit Infrastructure):
├─ AppDelegate.swift
├─ Windows/DocketPanel.swift
└─ Windows/DocketWindowController.swift

✨ New Controllers:
├─ Controllers/ContentViewController.swift
├─ Controllers/MeetingsListViewController.swift
├─ Controllers/EmptyStateViewController.swift
└─ Controllers/LoadingStateViewController.swift

🔄 Converted Components (SwiftUI → AppKit):
├─ Views/MeetingRowView.swift → NSView
├─ Views/DaySectionView.swift → NSView
├─ Views/StatusBar.swift → NSView
├─ Components/PinButton.swift → NSButton
├─ Components/HideCompletedButton.swift → NSButton
├─ Components/MeetingJoinButton.swift → NSButton
├─ Components/MeetingCopyButton.swift → NSButton
├─ Components/StatusBarRefreshItem.swift → NSView
├─ Components/PlatformIndicatorView.swift → NSView
├─ Components/MeetingTimeView.swift → NSView
├─ Components/MeetingDetailsView.swift → NSView
├─ Components/RefreshStatusIcon.swift → NSImageView
└─ Components/RefreshStatusText.swift → NSTextField

❌ Files to Delete:
├─ DocketApp.swift
├─ PreviewData.swift
├─ Views/EmptyMeetingsDayView.swift (consolidate)
└─ Views/LoadingStateView.swift (consolidate)

✨ Helper Files (New):
├─ Helpers/NSViewExtensions.swift
└─ Helpers/ColorExtensions.swift
```

---

## Appendix B: Architecture Comparison

### SwiftUI (Current)
```
pros:
  ✅ Modern, declarative syntax
  ✅ Quick iteration with previews
  ✅ Less boilerplate code
  ✅ Cross-platform (iOS, macOS, etc.)

cons:
  ❌ Material caching (no live update)
  ❌ Limited window control
  ❌ Not optimized for floating widgets
  ❌ Performance overhead for persistent windows
```

### AppKit (Target)
```
pros:
  ✅ Native macOS framework
  ✅ NSVisualEffectView updates live
  ✅ Full NSWindow/NSPanel control
  ✅ Optimized for floating windows
  ✅ Better performance for persistent UI

cons:
  ❌ More verbose (delegate pattern)
  ❌ No previews (use IB or manual testing)
  ❌ macOS-only (can't share with iOS)
  ❌ Steeper learning curve for new devs
```

### Verdict: AppKit is Better for This Use Case

A floating widget is fundamentally an AppKit use case. SwiftUI is better for main application UIs, but floating panels and specialized windows are where AppKit excels.

---

## Document Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 2025 | Initial comprehensive plan |

---

**End of Conversion Plan**

This document serves as the single source of truth for the AppKit conversion effort. All decisions, patterns, and timelines are documented here.

For questions or clarifications, refer to the relevant section or create a GitHub issue.
