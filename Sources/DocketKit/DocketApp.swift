// ABOUTME: Main SwiftUI application structure for Docket
// ABOUTME: Defines the app entry point and window configuration

import AppKit
import SwiftUI

public struct DocketApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  public init() {}

  public var body: some Scene {
    WindowGroup("Docket - Zoom Meetings") {
      ContentView()
        .frame(minWidth: 550, minHeight: 450)
        .onAppear {
          // Activate the app and bring window to front
          NSApp.activate(ignoringOtherApps: true)
        }
    }
    .windowStyle(.automatic)
    .windowResizability(.contentMinSize)
    .defaultSize(width: 720, height: 780)
    .commands {
      CommandGroup(replacing: .newItem) {}
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Delay to ensure windows are created in Xcode debugging environment
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // Ensure the app activates and shows window
      NSApp.activate(ignoringOtherApps: true)

      // Make sure we have at least one window
      if !NSApp.windows.isEmpty {
        for window in NSApp.windows {
          window.makeKeyAndOrderFront(nil)
          window.orderFrontRegardless()  // Force window to front
        }
      }
    }
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
