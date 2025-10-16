// ABOUTME: AppKit copy button for meeting URLs with clipboard functionality
// ABOUTME: Simple icon button that copies URL to clipboard

import AppKit

/// An NSButton that handles meeting URL copying to clipboard
class MeetingCopyButton: NSButton {
  let meetingUrl: String?
  let onCopy: (String) -> Void

  init(meetingUrl: String?, onCopy: @escaping (String) -> Void) {
    self.meetingUrl = meetingUrl
    self.onCopy = onCopy
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    bezelStyle = .inline
    setButtonType(.momentaryPushIn)

    // Use clipboard icon
    let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .regular)
    let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)?
      .withSymbolConfiguration(config)
    setImage(image, for: .normal)

    contentTintColor = .secondaryLabelColor
    target = self
    action = #selector(performCopy)
    translatesAutoresizingMaskIntoConstraints = false
    toolTip = "Copy meeting link"
    isEnabled = canCopy

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 24),
      heightAnchor.constraint(equalToConstant: 24),
    ])
  }

  private var canCopy: Bool {
    guard let url = meetingUrl else { return false }
    return !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  @objc private func performCopy() {
    guard let url = meetingUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty else {
      return
    }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(url, forType: .string)

    onCopy(url)
  }
}
