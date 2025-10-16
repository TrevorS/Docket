// ABOUTME: AppKit NSApplicationDelegate for Docket
// ABOUTME: Main app entry point managing window lifecycle and singletons
// ABOUTME: Replaces previous SwiftUI App structure for native macOS 26 integration

import AppKit
import Combine

// MARK: - Notification Names

extension Notification.Name {
  static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
  static let appDidResignActive = Notification.Name("appDidResignActive")
  static let alwaysOnTopDidChange = Notification.Name("alwaysOnTopDidChange")
}

// MARK: - App Entry Point

public class AppDelegate: NSObject, NSApplicationDelegate {
  // MARK: - Singletons

  var appModel = AppModel()
  var calendarManager = CalendarManager()
  var windowController: DocketWindowController?

  // MARK: - App Lifecycle

  public func applicationDidFinishLaunching(_ notification: Notification) {
    // Create floating panel with default size
    let panelRect = NSRect(x: 100, y: 100, width: 460, height: 620)
    let panel = DocketPanel(
      contentRect: panelRect,
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )

    // Create root content view controller
    let contentVC = ContentViewController()

    // Setup window controller to manage panel lifecycle
    windowController = DocketWindowController(
      window: panel,
      contentViewController: contentVC
    )

    // Inject models into content view controller
    contentVC.appModel = appModel
    contentVC.calendarManager = calendarManager

    // Show the window
    panel.makeKeyAndOrderFront(nil)
    panel.orderFrontRegardless()

    // Activate app
    NSApp.activate(ignoringOtherApps: true)

    // Start auto-refresh
    calendarManager.startAutoRefresh()

    // Setup always-on-top observer
    setupAlwaysOnTopObserver()

    Logger.success("App launched successfully")
  }

  public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  public func applicationDidBecomeActive(_ notification: Notification) {
    // Resume auto-refresh when app becomes active
    Task { @MainActor in
      calendarManager.resumeAutoRefresh()
      // Post notification for SwiftUI views
      NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
    }
  }

  public func applicationDidResignActive(_ notification: Notification) {
    // Don't pause auto-refresh - users want widget visible when app is in background
    // Post notification for SwiftUI views
    NotificationCenter.default.post(name: .appDidResignActive, object: nil)
  }

  // MARK: - Private Methods

  private func setupAlwaysOnTopObserver() {
    guard let windowController = windowController else { return }
    NotificationCenter.default.addObserver(
      forName: .alwaysOnTopDidChange,
      object: nil,
      queue: .main
    ) { [weak windowController] notification in
      if let alwaysOnTop = notification.userInfo?["alwaysOnTop"] as? Bool {
        Task { @MainActor in
          windowController?.panel.level = alwaysOnTop ? .floating : .normal
        }
      }
    }
  }
}
