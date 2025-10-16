// ABOUTME: AppKit NSView subclass for bottom status bar
// ABOUTME: Displays refresh status on left and hide completed toggle on right with Liquid Glass background
// ABOUTME: Full-width bar with top divider, fixed height 28pt

import AppKit

class StatusBarViewImpl: NSView {
  // MARK: - Properties
  var lastRefresh: Date? {
    didSet {
      refreshItem.lastRefresh = lastRefresh
    }
  }

  var isRefreshing: Bool = false {
    didSet {
      refreshItem.isRefreshing = isRefreshing
    }
  }

  var isAutoRefreshEnabled: Bool = false {
    didSet {
      refreshItem.isAutoRefreshEnabled = isAutoRefreshEnabled
    }
  }

  var isAutoRefreshActive: Bool = false {
    didSet {
      refreshItem.isAutoRefreshActive = isAutoRefreshActive
    }
  }

  var isHidingCompleted: Bool = false {
    didSet {
      hideButton.isHiding = isHidingCompleted
    }
  }

  var onToggleAutoRefresh: (() -> Void)?
  var onToggleHideCompleted: (() -> Void)?

  // MARK: - Subviews
  private let effectView = NSVisualEffectView()
  private let divider = NSBox()
  private let contentStack = NSStackView()
  private let refreshItem = StatusBarRefreshItem()
  private let spacer = NSView()
  private let hideButton = HideCompletedButton(size: .compact)

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
    // Configure effect view (Liquid Glass background)
    effectView.material = .hudWindow
    effectView.blendingMode = .behindWindow
    effectView.state = .active
    addSubview(effectView, positioned: .below, relativeTo: nil)

    // Configure divider
    divider.boxType = .separator
    addSubview(divider)

    // Configure content stack
    contentStack.orientation = .horizontal
    contentStack.distribution = .fill
    contentStack.spacing = 8

    // Add refresh item
    refreshItem.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(refreshItem)

    // Add spacer
    spacer.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(spacer)

    // Add hide button
    hideButton.translatesAutoresizingMaskIntoConstraints = false
    hideButton.onToggle = { [weak self] in
      self?.onToggleHideCompleted?()
    }
    contentStack.addArrangedSubview(hideButton)

    // Add content stack
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentStack)

    // Setup constraints
    effectView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
      effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    // Divider at top
    divider.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leadingAnchor.constraint(equalTo: leadingAnchor),
      divider.trailingAnchor.constraint(equalTo: trailingAnchor),
      divider.heightAnchor.constraint(equalToConstant: 1),
    ])

    // Content stack with padding
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 6),
      contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
      contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
    ])

    // Fixed height: 28pt
    heightAnchor.constraint(equalToConstant: 28).isActive = true

    // Setup refresh item callback
    refreshItem.onToggleAutoRefresh = { [weak self] in
      self?.onToggleAutoRefresh?()
    }
  }
}
