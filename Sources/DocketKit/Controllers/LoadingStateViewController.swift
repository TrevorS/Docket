// ABOUTME: View controller for loading state
// ABOUTME: Displays spinner while waiting for calendar permissions or meeting data

import AppKit

class LoadingStateViewController: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor

    Logger.info("LoadingStateViewController viewDidLoad - view frame: \(view.frame)")

    // Setup loading spinner
    let spinner = NSProgressIndicator()
    spinner.style = .spinning
    spinner.startAnimation(nil)

    view.addSubview(spinner)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])

    Logger.info("Added spinner to LoadingStateViewController")
  }
}
