// ABOUTME: AppKit meeting organizer and attendee information display
// ABOUTME: Shows organizer name and attendee count

import AppKit

/// An NSView that displays meeting organizer and attendee information
class MeetingDetailsView: NSView {
  let organizerName: String?
  let attendeeCount: Int
  let attendees: [(name: String?, email: String?)]

  private let stackView = NSStackView()

  init(organizerName: String?, attendeeCount: Int, attendees: [(name: String?, email: String?)]) {
    self.organizerName = organizerName
    self.attendeeCount = attendeeCount
    self.attendees = attendees
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
    stackView.spacing = 12
    stackView.alignment = .centerY
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)

    // Add organizer if present
    if let organizer = organizerName, !organizer.isEmpty {
      let organizerStack = NSStackView()
      organizerStack.orientation = .horizontal
      organizerStack.spacing = 4
      organizerStack.alignment = .centerY

      let organizerIcon = NSImageView()
      organizerIcon.image = NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: nil)
      organizerIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 9, weight: .regular)
      organizerIcon.contentTintColor = .secondaryLabelColor
      organizerIcon.translatesAutoresizingMaskIntoConstraints = false
      organizerStack.addArrangedSubview(organizerIcon)

      let organizerLabel = NSTextField()
      organizerLabel.stringValue = organizer
      organizerLabel.font = NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
      organizerLabel.textColor = .secondaryLabelColor
      organizerLabel.backgroundColor = .clear
      organizerLabel.isBordered = false
      organizerLabel.isEditable = false
      organizerLabel.isSelectable = false
      organizerLabel.lineBreakMode = .byTruncatingTail
      organizerLabel.translatesAutoresizingMaskIntoConstraints = false
      organizerStack.addArrangedSubview(organizerLabel)

      stackView.addArrangedSubview(organizerStack)

      NSLayoutConstraint.activate([
        organizerIcon.widthAnchor.constraint(equalToConstant: 9),
        organizerIcon.heightAnchor.constraint(equalToConstant: 9),
      ])
    }

    // Add attendee count if present
    if attendeeCount > 0 {
      let attendeeStack = NSStackView()
      attendeeStack.orientation = .horizontal
      attendeeStack.spacing = 4
      attendeeStack.alignment = .centerY

      let attendeeIcon = NSImageView()
      attendeeIcon.image = NSImage(systemSymbolName: "person.2", accessibilityDescription: nil)
      attendeeIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 9, weight: .regular)
      attendeeIcon.contentTintColor = .secondaryLabelColor
      attendeeIcon.translatesAutoresizingMaskIntoConstraints = false
      attendeeStack.addArrangedSubview(attendeeIcon)

      let attendeeLabel = NSTextField()
      attendeeLabel.stringValue = attendeeText
      attendeeLabel.font = NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
      attendeeLabel.textColor = .secondaryLabelColor
      attendeeLabel.backgroundColor = .clear
      attendeeLabel.isBordered = false
      attendeeLabel.isEditable = false
      attendeeLabel.isSelectable = false
      attendeeLabel.translatesAutoresizingMaskIntoConstraints = false
      attendeeStack.addArrangedSubview(attendeeLabel)

      stackView.addArrangedSubview(attendeeStack)

      NSLayoutConstraint.activate([
        attendeeIcon.widthAnchor.constraint(equalToConstant: 9),
        attendeeIcon.heightAnchor.constraint(equalToConstant: 9),
      ])
    }

    // Add spacer to push everything to left
    let spacer = NSView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(spacer)

    // Setup main constraints
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor),
    ])
  }

  private var attendeeText: String {
    "\(attendeeCount) \(attendeeCount == 1 ? "person" : "people")"
  }
}
