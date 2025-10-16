// ABOUTME: AppKit day section header component displaying date labels
// ABOUTME: Simple header for "Yesterday", "Today", "Tomorrow" sections

import AppKit

/// An NSView displaying a day section header
class DaySectionHeaderView: NSView {
  let title: String

  private let labelField = NSTextField()

  init(title: String) {
    self.title = title
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    wantsLayer = true
    translatesAutoresizingMaskIntoConstraints = false

    // Configure label
    labelField.stringValue = title
    labelField.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
    labelField.textColor = .labelColor
    labelField.backgroundColor = .clear
    labelField.isBordered = false
    labelField.isEditable = false
    labelField.isSelectable = false
    labelField.alignment = .natural
    labelField.translatesAutoresizingMaskIntoConstraints = false
    addSubview(labelField)

    // Setup constraints
    NSLayoutConstraint.activate([
      labelField.topAnchor.constraint(equalTo: topAnchor),
      labelField.bottomAnchor.constraint(equalTo: bottomAnchor),
      labelField.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
      labelField.rightAnchor.constraint(equalTo: rightAnchor),
      heightAnchor.constraint(equalToConstant: 20),
    ])
  }
}
