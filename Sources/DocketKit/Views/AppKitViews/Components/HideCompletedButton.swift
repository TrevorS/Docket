// ABOUTME: AppKit NSButton subclass for toggling visibility of completed meetings
// ABOUTME: Provides state-based icon and color indication with smooth animation
// ABOUTME: Supports compact and normal sizes for flexible layout

import AppKit
import Combine

class HideCompletedButton: NSButton {
  // MARK: - State
  enum Size {
    case normal
    case compact
  }

  var isHiding: Bool = false {
    didSet {
      updateAppearance()
    }
  }

  let size: Size
  var onToggle: (() -> Void)?

  // MARK: - Initialization
  init(frame: NSRect = .zero, size: Size = .normal) {
    self.size = size
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
    let frameSize: CGSize =
      size == .compact
      ? CGSize(width: 24, height: 24)
      : CGSize(width: 28, height: 28)
    setFrameSize(frameSize)

    // Update initial appearance
    updateAppearance()
  }

  // MARK: - Actions
  @objc private func handleToggle() {
    isHiding.toggle()
    onToggle?()

    // Animation
    animateToggle()
  }

  // MARK: - Appearance
  private func updateAppearance() {
    let imageName = isHiding ? "eye.slash" : "eye"
    let image = NSImage(
      systemSymbolName: imageName, accessibilityDescription: isHiding ? "Hidden" : "Visible")
    image?.isTemplate = true
    self.image = image

    // Color
    contentTintColor = isHiding ? .secondaryLabelColor : .systemBlue

    // Tooltip
    self.toolTip =
      isHiding
      ? "Show all completed meetings (currently hiding meetings 5 minutes after completion)"
      : "Hide meetings 5 minutes after completion"
  }

  // MARK: - Animation
  private func animateToggle() {
    // Enable layer for animation
    self.wantsLayer = true

    // Opacity animation for toggle
    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.fromValue = 0.7
    opacityAnimation.toValue = 1.0
    opacityAnimation.duration = 0.2
    opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    self.layer?.add(opacityAnimation, forKey: "opacity")
  }
}
