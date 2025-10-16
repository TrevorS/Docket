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

    // TODO: Add day sections with meetings
  }
}
