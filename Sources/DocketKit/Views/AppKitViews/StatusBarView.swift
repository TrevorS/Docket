// ABOUTME: AppKit status bar component displaying refresh status and hide toggle
// ABOUTME: Bottom-pinned bar with refresh icon, timestamp, and completed meetings filter

import AppKit
@preconcurrency import Combine

/// An NSView displaying the bottom status bar with refresh status and hide toggle
class StatusBarView: NSView {
  weak var appModel: AppModel?
  weak var calendarManager: CalendarManager?

  private var cancellables = Set<AnyCancellable>()

  private let divider = NSBox()
  private let stackView = NSStackView()
  private let refreshButton = NSButton()
  private let refreshLabel = NSTextField()
  private let hideButton = NSButton()
  private let spacer = NSView()

  override init(frame: NSRect) {
    super.init(frame: frame)
    setupUI()
    setupDataBindings()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    cancellables.removeAll()
  }

  private func setupUI() {
    wantsLayer = true
    translatesAutoresizingMaskIntoConstraints = false

    // Top divider line
    divider.boxType = .separator
    divider.translatesAutoresizingMaskIntoConstraints = false
    addSubview(divider)

    // Configure main horizontal stack
    stackView.orientation = .horizontal
    stackView.spacing = 16
    stackView.alignment = .centerY
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)

    // Add spacer (fills left side)
    spacer.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(spacer)

    // Configure refresh button
    refreshButton.bezelStyle = .inline
    refreshButton.setButtonType(.momentaryPushIn)
    let refreshConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .regular)
    let refreshImage = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: nil)?
      .withSymbolConfiguration(refreshConfig)
    refreshButton.image = refreshImage
    refreshButton.contentTintColor = .secondaryLabelColor
    refreshButton.target = self
    refreshButton.action = #selector(toggleAutoRefresh)
    refreshButton.translatesAutoresizingMaskIntoConstraints = false
    refreshButton.toolTip = "Toggle auto-refresh"
    stackView.addArrangedSubview(refreshButton)

    // Configure refresh label
    refreshLabel.stringValue = "Not refreshed yet"
    refreshLabel.font = NSFont.systemFont(ofSize: 10)
    refreshLabel.textColor = .secondaryLabelColor
    refreshLabel.backgroundColor = .clear
    refreshLabel.isBordered = false
    refreshLabel.isEditable = false
    refreshLabel.isSelectable = false
    refreshLabel.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(refreshLabel)

    // Configure hide completed button (eye icon)
    hideButton.bezelStyle = .inline
    hideButton.setButtonType(.onOff)
    let eyeConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .medium)
    let eyeImage = NSImage(systemSymbolName: "eye.slash", accessibilityDescription: nil)?
      .withSymbolConfiguration(eyeConfig)
    hideButton.image = eyeImage
    hideButton.contentTintColor = .secondaryLabelColor
    hideButton.state = .on  // Default: hiding completed
    hideButton.target = self
    hideButton.action = #selector(toggleHideCompleted)
    hideButton.translatesAutoresizingMaskIntoConstraints = false
    hideButton.toolTip = "Hide completed meetings"
    stackView.addArrangedSubview(hideButton)

    // Setup constraints
    NSLayoutConstraint.activate([
      // Divider at top
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leftAnchor.constraint(equalTo: leftAnchor),
      divider.rightAnchor.constraint(equalTo: rightAnchor),
      divider.heightAnchor.constraint(equalToConstant: 1),

      // Stack view
      stackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 6),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),

      // Button sizes
      refreshButton.widthAnchor.constraint(equalToConstant: 16),
      refreshButton.heightAnchor.constraint(equalToConstant: 16),
      hideButton.widthAnchor.constraint(equalToConstant: 16),
      hideButton.heightAnchor.constraint(equalToConstant: 16),

      // Height
      heightAnchor.constraint(equalToConstant: 28),
    ])
  }

  private func setupDataBindings() {
    guard let calendarManager = calendarManager else {
      return
    }

    // Observe lastRefresh changes
    calendarManager.isRefreshingPublisher()
      .combineLatest(
        calendarManager.isRefreshingPublisher()
          .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
          .mapToVoid()
          .prepend(())
      )
      .sink { [weak self] _, _ in
        self?.updateRefreshStatus()
      }
      .store(in: &cancellables)

    // Observe hideCompletedMeetingsAfter5Min changes
    NotificationCenter.default
      .publisher(for: Notification.Name("alwaysOnTopDidChange"))
      .sink { [weak self] _ in
        self?.updateHideButtonState()
      }
      .store(in: &cancellables)

    // Initial state
    updateRefreshStatus()
    updateHideButtonState()
  }

  private func updateRefreshStatus() {
    guard let calendarManager = calendarManager else { return }

    if let lastRefresh = calendarManager.lastRefresh {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      refreshLabel.stringValue = "Updated \(formatter.string(from: lastRefresh))"
    } else {
      refreshLabel.stringValue = "Not refreshed yet"
    }

    // Update icon based on refreshing state
    if calendarManager.isRefreshing {
      let spinConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .regular)
      let spinImage = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)?
        .withSymbolConfiguration(spinConfig)
      refreshButton.image = spinImage
    } else {
      let clockConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .regular)
      let clockImage = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(clockConfig)
      refreshButton.image = clockImage
    }
  }

  private func updateHideButtonState() {
    guard let appModel = appModel else { return }

    hideButton.state = appModel.hideCompletedMeetingsAfter5Min ? .on : .off

    // Update tooltip
    hideButton.toolTip =
      appModel.hideCompletedMeetingsAfter5Min
      ? "Showing completed meetings hidden"
      : "Showing all meetings"

    // Update icon
    let eyeConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .medium)
    let eyeImage = NSImage(
      systemSymbolName: appModel.hideCompletedMeetingsAfter5Min ? "eye.slash" : "eye",
      accessibilityDescription: nil
    )?
    .withSymbolConfiguration(eyeConfig)
    hideButton.image = eyeImage
  }

  @objc private func toggleHideCompleted() {
    guard let appModel = appModel else { return }
    appModel.hideCompletedMeetingsAfter5Min.toggle()
    updateHideButtonState()
  }

  @objc private func toggleAutoRefresh() {
    guard let calendarManager = calendarManager else { return }

    if calendarManager.isAutoRefreshActive {
      calendarManager.stopAutoRefresh()
    } else {
      calendarManager.startAutoRefresh()
    }
  }
}

// MARK: - Helper Publisher Extension

extension Publisher where Output == Bool {
  func mapToVoid() -> AnyPublisher<Void, Failure> {
    map { _ in () }.eraseToAnyPublisher()
  }
}
