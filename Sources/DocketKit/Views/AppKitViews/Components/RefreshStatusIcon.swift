// ABOUTME: AppKit NSImageView subclass for refresh status visualization
// ABOUTME: Displays state-driven icons (pause.circle.fill, clock) with color indication
// ABOUTME: Supports breathing animation for active refresh state

import AppKit

class RefreshStatusIcon: NSImageView {
  // MARK: - State
  var isRefreshing: Bool = false {
    didSet {
      updateAppearance()
    }
  }

  var isAutoRefreshActive: Bool = false {
    didSet {
      updateAppearance()
    }
  }

  var isAutoRefreshEnabled: Bool = false {
    didSet {
      updateAppearance()
    }
  }

  var lastRefresh: Date?

  // MARK: - Animation
  private var breatheAnimation: CABasicAnimation?

  // MARK: - Initialization
  override init(frame: NSRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  private func setupView() {
    self.imageScaling = .scaleProportionallyUpOrDown
    self.isEditable = false

    // Enable layer for animations
    self.wantsLayer = true

    updateAppearance()
  }

  // MARK: - Appearance
  private func updateAppearance() {
    // Update icon
    let imageName = shouldShowPauseIcon ? "pause.circle.fill" : "clock"
    let image = NSImage(systemSymbolName: imageName, accessibilityDescription: imageName)
    image?.isTemplate = true
    self.image = image

    // Update color
    self.contentTintColor = iconColor

    // Handle animation
    if isRefreshing {
      startBreatheAnimation()
    } else {
      stopBreatheAnimation()
    }
  }

  // MARK: - Computed Properties
  private var shouldShowPauseIcon: Bool {
    isAutoRefreshEnabled && !isAutoRefreshActive
  }

  private var iconColor: NSColor {
    if shouldShowPauseIcon {
      // Paused state - static blue
      return NSColor.systemBlue.withAlphaComponent(0.6)
    } else if isRefreshing {
      // Refreshing - pulsing blue
      return .systemBlue
    } else if isAutoRefreshEnabled && isAutoRefreshActive {
      // Active and ready - subtle blue
      return NSColor.systemBlue.withAlphaComponent(0.7)
    } else {
      // Disabled or inactive - gray
      return .secondaryLabelColor
    }
  }

  // MARK: - Animations
  private func startBreatheAnimation() {
    // Remove existing animation
    layer?.removeAnimation(forKey: "breathe")

    // Create breathing animation
    let breatheAnimation = CABasicAnimation(keyPath: "opacity")
    breatheAnimation.fromValue = 0.5
    breatheAnimation.toValue = 1.0
    breatheAnimation.duration = 1.2
    breatheAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    breatheAnimation.repeatCount = .infinity
    breatheAnimation.autoreverses = true

    layer?.add(breatheAnimation, forKey: "breathe")
    self.breatheAnimation = breatheAnimation
  }

  private func stopBreatheAnimation() {
    layer?.removeAnimation(forKey: "breathe")
    self.breatheAnimation = nil

    // Reset opacity to full
    layer?.opacity = 1.0
  }
}
