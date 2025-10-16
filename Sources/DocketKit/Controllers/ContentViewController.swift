// ABOUTME: Root view controller for the main content area
// ABOUTME: Manages conditional display of meetings list, loading, or empty states
// ABOUTME: Acts as container for state transitions

import AppKit
import Combine

class ContentViewController: NSViewController {
  weak var appModel: AppModel?
  weak var calendarManager: CalendarManager?

  private var cancellables = Set<AnyCancellable>()
  private let meetingsListVC = MeetingsListViewController()
  private let emptyStateVC = EmptyStateViewController()
  private let loadingStateVC = LoadingStateViewController()
  private let statusBarView = StatusBarView()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup initial view
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor

    // Add Liquid Glass background (macOS 26 Tahoe)
    let effectView = NSVisualEffectView()
    effectView.material = .hudWindow
    effectView.blendingMode = .behindWindow
    effectView.state = .active
    effectView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(effectView, positioned: .below, relativeTo: nil)

    NSLayoutConstraint.activate([
      effectView.topAnchor.constraint(equalTo: view.topAnchor),
      effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      effectView.leftAnchor.constraint(equalTo: view.leftAnchor),
      effectView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])

    // Setup status bar FIRST with models
    statusBarView.appModel = appModel
    statusBarView.calendarManager = calendarManager
    statusBarView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(statusBarView)

    // Setup status bar constraints (pin to bottom)
    NSLayoutConstraint.activate([
      statusBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      statusBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
      statusBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
      statusBarView.heightAnchor.constraint(equalToConstant: 28),
    ])

    // Now add initial state view (loading)
    addChild(loadingStateVC)
    view.addSubview(loadingStateVC.view)
    setupConstraints(for: loadingStateVC.view)

    // Setup data bindings
    setupDataBindings()

    // Request calendar access
    Task {
      _ = await calendarManager?.requestAccess()
    }
  }

  private func setupDataBindings() {
    // Observe auth state to determine which view to show
    calendarManager?.authStatePublisher()
      .sink { [weak self] authState in
        self?.updateViewState(for: authState)
      }
      .store(in: &cancellables)
  }

  private func updateViewState(for authState: CalendarAuthState) {
    switch authState {
    case .notDetermined:
      showView(loadingStateVC)
    case .authorized, .fullAccess:
      showView(meetingsListVC)
    default:
      showView(emptyStateVC)
    }
  }

  private func showView(_ viewController: NSViewController) {
    // Setup view controller with models
    if let vc = viewController as? MeetingsListViewController {
      vc.appModel = appModel
      vc.calendarManager = calendarManager
    }

    // Remove current view
    children.forEach {
      $0.removeFromParent()
      $0.view.removeFromSuperview()
    }

    // Add new view controller
    addChild(viewController)
    viewController.view.frame = view.bounds
    view.addSubview(viewController.view)

    // Setup constraints - content view takes up space above status bar
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: statusBarView.topAnchor),
      viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
  }

  private func setupConstraints(for subview: NSView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: view.topAnchor),
      subview.bottomAnchor.constraint(equalTo: statusBarView.topAnchor),
      subview.leftAnchor.constraint(equalTo: view.leftAnchor),
      subview.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
  }
}
