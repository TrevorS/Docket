// ABOUTME: AppKit meeting time display with state-based color coding
// ABOUTME: Shows clock icon, time range, and duration

import AppKit

/// An NSView that displays meeting time with state-based coloring
class MeetingTimeView: NSView {
  let meeting: Meeting

  private let stackView = NSStackView()
  private let iconView = NSImageView()
  private let timeField = NSTextField()
  private let bulletField = NSTextField()
  private let durationField = NSTextField()

  init(meeting: Meeting) {
    self.meeting = meeting
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
    iconView.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
    iconView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 11, weight: .regular)
    iconView.contentTintColor = .secondaryLabelColor
    iconView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(iconView)

    // Configure time field
    timeField.stringValue = timeRangeText
    timeField.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    timeField.textColor = timeColor
    timeField.backgroundColor = .clear
    timeField.isBordered = false
    timeField.isEditable = false
    timeField.isSelectable = false
    timeField.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(timeField)

    // Configure bullet separator (only if there's duration)
    if durationText != nil {
      bulletField.stringValue = "•"
      bulletField.font = NSFont.systemFont(ofSize: 10, weight: .regular)
      bulletField.textColor = .secondaryLabelColor
      bulletField.backgroundColor = .clear
      bulletField.isBordered = false
      bulletField.isEditable = false
      bulletField.isSelectable = false
      bulletField.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(bulletField)

      // Configure duration field
      durationField.stringValue = durationText ?? ""
      durationField.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      durationField.textColor = timeColor
      durationField.backgroundColor = .clear
      durationField.isBordered = false
      durationField.isEditable = false
      durationField.isSelectable = false
      durationField.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(durationField)
    }

    // Setup constraints
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 11),
      iconView.heightAnchor.constraint(equalToConstant: 11),
    ])
  }

  private var timeColor: NSColor {
    if meeting.hasEnded {
      return .secondaryLabelColor
    } else if meeting.hasStarted {
      return .systemGreen.withAlphaComponent(0.8)
    } else if meeting.isUpcoming {
      return .systemOrange.withAlphaComponent(0.8)
    } else {
      return .systemBlue.withAlphaComponent(0.8)
    }
  }

  private var timeRangeText: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short

    let startTime = formatter.string(from: meeting.startTime)
    let endTime = formatter.string(from: meeting.endTime)

    return "\(startTime) - \(endTime)"
  }

  private var durationText: String? {
    let duration = meeting.endTime.timeIntervalSince(meeting.startTime)
    let minutes = Int(duration / 60)

    if minutes <= 0 {
      return nil
    } else if minutes < 60 {
      return "\(minutes)m"
    } else {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60
      if remainingMinutes == 0 {
        return "\(hours)h"
      } else {
        return "\(hours)h \(remainingMinutes)m"
      }
    }
  }
}
