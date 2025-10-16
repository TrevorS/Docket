// ABOUTME: AppKit individual meeting row component with time, status, and quick join
// ABOUTME: Displays meeting information with visual status indicators and actions

import AppKit

/// An NSView representing a single meeting row with all details and actions
class MeetingRowViewImpl: NSView {
  let meeting: Meeting
  let onJoin: (URL) -> Void
  let onCopy: (String) -> Void

  private let effectView = NSVisualEffectView()
  private let contentStack = NSStackView()
  private let detailsStack = NSStackView()
  private let actionsStack = NSStackView()
  private let titleField = NSTextField()
  private let platformView: PlatformIndicatorView
  private let timeView: MeetingTimeView
  private let detailsView: MeetingDetailsView
  private let joinButton: MeetingJoinButton
  private let copyButton: MeetingCopyButton

  init(meeting: Meeting, onJoin: @escaping (URL) -> Void, onCopy: @escaping (String) -> Void) {
    self.meeting = meeting
    self.onJoin = onJoin
    self.onCopy = onCopy

    self.platformView = PlatformIndicatorView(platform: meeting.platform)
    self.timeView = MeetingTimeView(meeting: meeting)
    self.detailsView = MeetingDetailsView(
      organizerName: meeting.organizerName, attendeeCount: meeting.attendeeCount,
      attendees: meeting.attendees)
    self.joinButton = MeetingJoinButton(meeting: meeting, onJoin: onJoin)
    self.copyButton = MeetingCopyButton(meetingUrl: meeting.joinUrl, onCopy: onCopy)

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

    // Add background visual effect view
    effectView.material = .hudWindow
    effectView.blendingMode = .behindWindow
    effectView.state = .active
    effectView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(effectView, positioned: .below, relativeTo: nil)

    NSLayoutConstraint.activate([
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
      effectView.leftAnchor.constraint(equalTo: leftAnchor),
      effectView.rightAnchor.constraint(equalTo: rightAnchor),
    ])

    // Apply corner radius
    layer?.cornerRadius = 8

    // Configure main horizontal stack (content + actions)
    contentStack.orientation = .horizontal
    contentStack.spacing = 12
    contentStack.alignment = .top
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentStack)

    // Configure title field
    titleField.stringValue = meeting.title
    titleField.font = NSFont.boldSystemFont(ofSize: 13)
    titleField.textColor = meeting.hasEnded ? .secondaryLabelColor : .labelColor
    titleField.backgroundColor = .clear
    titleField.isBordered = false
    titleField.isEditable = false
    titleField.isSelectable = false
    titleField.lineBreakMode = .byTruncatingTail
    titleField.translatesAutoresizingMaskIntoConstraints = false

    // Configure details vertical stack (title, time, platform+organizer+attendees)
    detailsStack.orientation = .vertical
    detailsStack.spacing = 6
    detailsStack.alignment = .leading
    detailsStack.translatesAutoresizingMaskIntoConstraints = false

    detailsStack.addArrangedSubview(titleField)
    detailsStack.addArrangedSubview(timeView)

    // Add horizontal stack for platform + organizer + attendees
    let platformDetailsStack = NSStackView()
    platformDetailsStack.orientation = .horizontal
    platformDetailsStack.spacing = 12
    platformDetailsStack.alignment = .centerY
    platformDetailsStack.translatesAutoresizingMaskIntoConstraints = false

    platformDetailsStack.addArrangedSubview(platformView)
    platformDetailsStack.addArrangedSubview(detailsView)

    detailsStack.addArrangedSubview(platformDetailsStack)

    // Configure actions horizontal stack (copy + join)
    actionsStack.orientation = .horizontal
    actionsStack.spacing = 8
    actionsStack.alignment = .centerY
    actionsStack.translatesAutoresizingMaskIntoConstraints = false

    // Only add copy button if meeting has URL
    if hasJoinUrl {
      actionsStack.addArrangedSubview(copyButton)
    }

    // Only add join button if meeting is not ended and has URL
    if shouldShowJoinButton {
      actionsStack.addArrangedSubview(joinButton)
    }

    // Add details and actions to main content stack
    contentStack.addArrangedSubview(detailsStack)
    contentStack.addArrangedSubview(actionsStack)

    // Setup main constraints
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      contentStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
      contentStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
      platformView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
      actionsStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
    ])
  }

  var shouldShowJoinButton: Bool {
    !meeting.hasEnded && hasJoinUrl
  }

  var hasJoinUrl: Bool {
    !(meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
  }
}
