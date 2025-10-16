// ABOUTME: View controller for empty state (no calendar access or no meetings)
// ABOUTME: Displays permission requests or no meetings message

import AppKit

class EmptyStateViewController: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor

    // Setup empty state UI
    let label = NSTextField()
    label.stringValue = "No meetings scheduled"
    label.isEditable = false
    label.isBezeled = false
    label.drawsBackground = false
    label.font = NSFont.systemFont(ofSize: 14)
    label.textColor = .secondaryLabelColor

    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
}
