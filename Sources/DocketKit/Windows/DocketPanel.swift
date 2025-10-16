// ABOUTME: AppKit NSPanel subclass for Docket floating window
// ABOUTME: Implements Liquid Glass material background with live updating
// ABOUTME: Configured as floating panel for always-visible widget behavior

import AppKit

class DocketPanel: NSPanel {

  override init(
    contentRect: NSRect,
    styleMask: NSWindow.StyleMask,
    backing: NSWindow.BackingStoreType,
    defer flag: Bool
  ) {
    super.init(
      contentRect: contentRect,
      styleMask: styleMask,
      backing: backing,
      defer: flag
    )

    setupPanelConfiguration()
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
}
