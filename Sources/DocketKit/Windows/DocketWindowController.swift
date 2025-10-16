// ABOUTME: NSWindowController for DocketPanel lifecycle management
// ABOUTME: Handles window position persistence and restoration
// ABOUTME: Manages content view controller initialization

import AppKit

class DocketWindowController: NSWindowController {
  let panel: DocketPanel
  let contentVC: NSViewController

  init(window: DocketPanel, contentViewController: NSViewController) {
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

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func restoreWindowPosition() {
    let defaults = UserDefaults.standard

    // Check if we have saved position
    if let positionData = defaults.data(forKey: "DocketWindowPosition") {
      if let position = try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: NSValue.self, from: positionData)?.pointValue
      {
        // Validate that the position is still on screen
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        if screenFrame.contains(NSRect(origin: position, size: panel.frame.size)) {
          panel.setFrameOrigin(position)
        }
      }
    }
  }

  private func setupWindowPositionObserver() {
    NotificationCenter.default.addObserver(
      forName: NSWindow.didMoveNotification,
      object: panel,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.saveWindowPosition()
      }
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
