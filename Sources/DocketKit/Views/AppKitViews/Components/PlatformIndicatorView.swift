// ABOUTME: AppKit platform indicator badge with icon and name
// ABOUTME: Shows color-coded indicators for Zoom, Google Meet, and unknown platforms

import AppKit

/// An NSView that displays a platform indicator badge with icon and name
class PlatformIndicatorView: NSView {
  let platform: MeetingPlatform

  private let stackView = NSStackView()
  private let iconView = NSImageView()
  private let labelField = NSTextField()

  init(platform: MeetingPlatform) {
    self.platform = platform
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    wantsLayer = true

    // Configure stack view
    stackView.orientation = .horizontal
    stackView.spacing = 4
    stackView.alignment = .centerY
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)

    // Configure icon view
    iconView.image = NSImage(systemSymbolName: platform.iconName, accessibilityDescription: nil)
    iconView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 10, weight: .regular)
    iconView.contentTintColor = platformColor
    iconView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(iconView)

    // Configure label field
    labelField.stringValue = platform.shortName
    labelField.font = NSFont.systemFont(ofSize: 10, weight: .medium)
    labelField.textColor = platformColor
    labelField.backgroundColor = .clear
    labelField.isBordered = false
    labelField.isEditable = false
    labelField.isSelectable = false
    labelField.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(labelField)

    // Apply background
    layer?.backgroundColor = platformColor.withAlphaComponent(0.1).cgColor
    layer?.cornerRadius = 4

    // Setup constraints
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -6),
      iconView.widthAnchor.constraint(equalToConstant: 10),
      iconView.heightAnchor.constraint(equalToConstant: 10),
    ])
  }

  private var platformColor: NSColor {
    switch platform {
    case .zoom:
      return .systemBlue
    case .googleMeet:
      return .systemGreen
    case .unknown:
      return .systemGray
    }
  }
}
