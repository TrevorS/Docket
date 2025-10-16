// ABOUTME: Main view controller for displaying the list of meetings
// ABOUTME: Manages NSScrollView + NSStackView for meeting rows
// ABOUTME: Integrates with CalendarManager for data binding

import AppKit
import Combine

class MeetingsListViewController: NSViewController {
  weak var appModel: AppModel?
  weak var calendarManager: CalendarManager?

  private let scrollView = NSScrollView()
  private let stackView = NSStackView()
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor

    setupUI()
    setupDataBindings()
  }

  private func setupUI() {
    // Configure scroll view
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    view.addSubview(scrollView)

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
      scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])

    // Configure stack view
    stackView.orientation = .vertical
    stackView.distribution = .fill
    stackView.alignment = .leading
    stackView.spacing = 8

    scrollView.documentView = stackView
  }

  private func setupDataBindings() {
    calendarManager?.meetingsPublisher()
      .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] _ in
        self?.updateMeetingsList()
      }
      .store(in: &cancellables)
  }

  private func updateMeetingsList() {
    // Clear existing views
    stackView.arrangedSubviews.forEach { view in
      stackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }

    guard let calendarManager = calendarManager, let appModel = appModel else {
      return
    }

    let hideCompleted = appModel.hideCompletedMeetingsAfter5Min

    // Define day sections: yesterday, today, tomorrow
    let sections = [
      ("Yesterday", calendarManager.yesterdayMeetings),
      ("Today", calendarManager.todayMeetings),
      ("Tomorrow", calendarManager.tomorrowMeetings),
    ]

    var hasAnyMeetings = false

    for (dayTitle, dayMeetings) in sections {
      // Filter out hidden meetings
      let filteredMeetings = dayMeetings.filter {
        !$0.shouldBeHidden(hideCompletedAfter5Min: hideCompleted)
      }

      // Skip empty sections
      if filteredMeetings.isEmpty {
        continue
      }

      hasAnyMeetings = true

      // Add day header
      let headerView = DaySectionHeaderView(title: dayTitle)
      stackView.addArrangedSubview(headerView)

      // Add meetings for this day
      for meeting in filteredMeetings {
        let meetingRow = MeetingRowViewImpl(
          meeting: meeting,
          onJoin: { url in
            let success = NSWorkspace.shared.open(url)
            if !success {
              Logger.error("Failed to open meeting URL: \(url)")
            }
          },
          onCopy: { url in
            Logger.info("Meeting URL copied to clipboard: \(url)")
          }
        )
        stackView.addArrangedSubview(meetingRow)
      }

      // Add spacing between sections (except after last section)
      if dayTitle != sections.last?.0 {
        let spacer = NSView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        stackView.addArrangedSubview(spacer)
      }
    }

    // If no meetings at all, show empty state message
    if !hasAnyMeetings {
      let emptyLabel = NSTextField()
      emptyLabel.stringValue = "No meetings today"
      emptyLabel.font = NSFont.systemFont(ofSize: 12)
      emptyLabel.textColor = .secondaryLabelColor
      emptyLabel.backgroundColor = .clear
      emptyLabel.isBordered = false
      emptyLabel.isEditable = false
      emptyLabel.isSelectable = false
      emptyLabel.alignment = .center
      emptyLabel.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(emptyLabel)
    }
  }
}
