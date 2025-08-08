// ABOUTME: Main SwiftUI application structure for Docket
// ABOUTME: Defines the app entry point and floating window configuration

import AppKit
import SwiftUI

public struct DocketApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  public init() {}

  public var body: some Scene {
    WindowGroup("Docket - Zoom Meetings") {
      ContentView()
        .frame(minWidth: 550, minHeight: 600)
        .onAppear {
          // Activate the app and bring window to front
          NSApp.activate(ignoringOtherApps: true)
        }
    }
    .windowStyle(.automatic)
    .windowResizability(.contentSize)
    .defaultSize(width: 720, height: 950)
    .commands {
      CommandGroup(replacing: .newItem) {}
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Delay to ensure windows are created in Xcode debugging environment
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      Task { @MainActor in
        self.configureFloatingWindows()
      }
    }
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  @MainActor
  private func configureFloatingWindows() {
    // Configure all app windows to float above other applications
    for window in NSApp.windows {
      // Set window level to float above normal windows but below screen savers
      window.level = .floating

      // Configure window behavior
      window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

      // Restore window position from user defaults
      restoreWindowPosition(window)

      // Activate and bring to front
      window.makeKeyAndOrderFront(nil)
      window.orderFrontRegardless()
    }

    // Ensure the app activates
    NSApp.activate(ignoringOtherApps: true)
  }

  @MainActor
  private func restoreWindowPosition(_ window: NSWindow) {
    let defaults = UserDefaults.standard

    // Check if we have saved position
    if let positionData = defaults.data(forKey: "DocketWindowPosition") {
      if let position = try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: NSValue.self, from: positionData)?.pointValue
      {
        // Validate that the position is still on screen
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        if screenFrame.contains(NSRect(origin: position, size: window.frame.size)) {
          window.setFrameOrigin(position)
        }
      }
    }

    // Save position when window moves
    NotificationCenter.default.addObserver(
      forName: NSWindow.didMoveNotification,
      object: window,
      queue: .main
    ) { [weak window] _ in
      guard let window = window else { return }
      Task { @MainActor in
        let positionValue = NSValue(point: window.frame.origin)
        let positionData = try? NSKeyedArchiver.archivedData(
          withRootObject: positionValue, requiringSecureCoding: true)
        UserDefaults.standard.set(positionData, forKey: "DocketWindowPosition")
      }
    }
  }
}
