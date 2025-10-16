// ABOUTME: AppKit join button with platform-specific styling and loading state
// ABOUTME: Handles meeting state logic and async join operations

import AppKit

/// An NSButton that handles meeting join functionality
class MeetingJoinButton: NSButton {
  let meeting: Meeting
  let onJoin: (URL) -> Void

  private var isJoining = false

  init(meeting: Meeting, onJoin: @escaping (URL) -> Void) {
    self.meeting = meeting
    self.onJoin = onJoin
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    bezelStyle = .rounded
    setButtonType(.momentaryPushIn)
    title = buttonText
    font = NSFont.systemFont(ofSize: 11, weight: .semibold)
    contentTintColor = baseColor
    wantsLayer = true
    target = self
    action = #selector(performJoin)
    translatesAutoresizingMaskIntoConstraints = false
    toolTip = tooltipText

    // Set background color
    layer?.backgroundColor = baseColor.cgColor
    layer?.cornerRadius = 6

    // Padding
    widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
  }

  private var buttonText: String {
    isJoining ? "Joining..." : "Join"
  }

  private var baseColor: NSColor {
    meeting.platform.nsColor
  }

  private var tooltipText: String {
    if shouldDisable {
      return "No meeting URL available"
    } else if meeting.hasStarted {
      return "Join active \(meeting.platform.displayName) meeting"
    } else {
      return "Join \(meeting.platform.displayName) meeting"
    }
  }

  private var shouldDisable: Bool {
    guard let joinUrl = meeting.joinUrl else { return true }
    return joinUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  @objc private func performJoin() {
    guard let joinUrlString = meeting.joinUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
      !joinUrlString.isEmpty,
      let url = URL(string: joinUrlString)
    else {
      return
    }

    isJoining = true
    isEnabled = false
    title = buttonText

    Task {
      defer {
        Task { @MainActor in
          self.isJoining = false
          self.isEnabled = true
          self.title = self.buttonText
        }
      }

      await MainActor.run {
        self.onJoin(url)
      }
    }
  }
}
