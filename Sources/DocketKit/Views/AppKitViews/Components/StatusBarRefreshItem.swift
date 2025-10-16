// ABOUTME: AppKit NSView subclass for status bar refresh item
// ABOUTME: Composes RefreshStatusIcon (clickable) and RefreshStatusText in compact horizontal layout

import AppKit

class StatusBarRefreshItem: NSView {
  // MARK: - Properties
  var lastRefresh: Date? {
    didSet {
      iconView.lastRefresh = lastRefresh
      textView.lastRefresh = lastRefresh
    }
  }

  var isRefreshing: Bool = false {
    didSet {
      iconView.isRefreshing = isRefreshing
    }
  }

  var isAutoRefreshEnabled: Bool = false {
    didSet {
      iconView.isAutoRefreshEnabled = isAutoRefreshEnabled
    }
  }

  var isAutoRefreshActive: Bool = false {
    didSet {
      iconView.isAutoRefreshActive = isAutoRefreshActive
    }
  }

  var onToggleAutoRefresh: (() -> Void)?

  // MARK: - Subviews
  private let iconButton = NSButton()
  private let iconView = RefreshStatusIcon()
  private let textView = RefreshStatusText()

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
    // Configure icon button
    iconButton.bezelStyle = .regularSquare
    iconButton.isBordered = false
    iconButton.target = self
    iconButton.action = #selector(handleToggle)

    // Add icon to button
    iconButton.addSubview(iconView)
    iconView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      iconView.centerXAnchor.constraint(equalTo: iconButton.centerXAnchor),
      iconView.centerYAnchor.constraint(equalTo: iconButton.centerYAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 12),
      iconView.heightAnchor.constraint(equalToConstant: 12),
    ])

    // Configure text view
    textView.translatesAutoresizingMaskIntoConstraints = false

    // Add subviews to main view
    addSubview(iconButton)
    addSubview(textView)

    // Setup constraints
    iconButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      // Icon button on left
      iconButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      iconButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      iconButton.widthAnchor.constraint(equalToConstant: 24),
      iconButton.heightAnchor.constraint(equalToConstant: 24),

      // Text on right of icon
      textView.leadingAnchor.constraint(equalTo: iconButton.trailingAnchor, constant: 4),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor),
      textView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])

    // Size this view
    setFrameSize(NSSize(width: 160, height: 20))

    updateTooltip()
  }

  // MARK: - Actions
  @objc private func handleToggle() {
    onToggleAutoRefresh?()
  }

  // MARK: - Tooltip
  private func updateTooltip() {
    if let lastRefresh = lastRefresh {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      iconButton.toolTip = "Updated \(formatter.string(from: lastRefresh))"
    } else {
      iconButton.toolTip = "Not refreshed yet"
    }
  }
}
