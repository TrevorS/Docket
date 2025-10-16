// ABOUTME: AppKit NSButton subclass for toggling window always-on-top behavior
// ABOUTME: Provides visual feedback for pinned/unpinned state with smooth icon rotation animation
// ABOUTME: Icon changes shape (pin/pin.fill + rotation) and color for accessibility

import AppKit
import Combine

class PinButton: NSButton {
  // MARK: - State
  var isPinned: Bool = false {
    didSet {
      updateAppearance()
    }
  }

  var onToggle: (() -> Void)?

  // MARK: - Initialization
  override init(frame: NSRect) {
    super.init(frame: frame)
    setupButton()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  private func setupButton() {
    bezelStyle = .regularSquare
    isBordered = false
    target = self
    action = #selector(handleToggle)

    // Size
    setFrameSize(NSSize(width: 28, height: 28))

    // Update initial appearance
    updateAppearance()
  }

  // MARK: - Actions
  @objc private func handleToggle() {
    isPinned.toggle()
    onToggle?()

    // Animation
    animatePinToggle()
  }

  // MARK: - Appearance
  private func updateAppearance() {
    let imageName = isPinned ? "pin.fill" : "pin"
    let image = NSImage(systemSymbolName: imageName, accessibilityDescription: isPinned ? "Pinned" : "Not pinned")
    image?.isTemplate = true
    self.image = image

    // Color
    contentTintColor = isPinned ? .systemBlue : .secondaryLabelColor

    // Tooltip
    self.toolTip = isPinned
      ? "Unpin window (allow to go behind other windows)"
      : "Pin window (keep on top of other windows)"
  }

  // MARK: - Animation
  private func animatePinToggle() {
    // Enable layer for animation
    self.wantsLayer = true

    // Rotation animation for pin toggle
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotationAnimation.fromValue = isPinned ? 0 : CGFloat.pi * 0.15
    rotationAnimation.toValue = isPinned ? CGFloat.pi * 0.15 : 0
    rotationAnimation.duration = 0.3
    rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    self.layer?.add(rotationAnimation, forKey: "rotation")
  }
}
