// ABOUTME: AppKit NSTextField subclass for displaying refresh timestamp
// ABOUTME: Formats lastRefresh Date with time-only display or fallback message

import AppKit

class RefreshStatusText: NSTextField {
  // MARK: - State
  var lastRefresh: Date? {
    didSet {
      updateText()
    }
  }

  // MARK: - Initialization
  override init(frame: NSRect) {
    super.init(frame: frame)
    setupTextField()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  private func setupTextField() {
    // Configuration
    self.isEditable = false
    self.isBezeled = false
    self.drawsBackground = false
    self.font = .systemFont(ofSize: 10, weight: .regular)
    self.textColor = .secondaryLabelColor
    self.alignment = .right

    updateText()
  }

  // MARK: - Update
  private func updateText() {
    if let lastRefresh = lastRefresh {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      self.stringValue = "Updated \(formatter.string(from: lastRefresh))"
    } else {
      self.stringValue = "Not refreshed yet"
    }
  }

  // MARK: - Sizing
  override var intrinsicContentSize: NSSize {
    let calculatedSize = self.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: 200, height: 20)) ?? NSSize(width: 100, height: 14)
    return calculatedSize
  }
}
