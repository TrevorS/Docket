// ABOUTME: Loading state component for different loading scenarios
// ABOUTME: Shows animated loading indicator with contextual messages for permissions and data fetching

import SwiftUI

/// Loading state view with animated indicator and contextual message
struct LoadingStateView: View {
  let message: String
  let systemImage: String

  init(message: String, systemImage: String = "calendar.badge.clock") {
    self.message = message
    self.systemImage = systemImage
  }

  var body: some View {
    ContentUnavailableView {
      Label(message, systemImage: systemImage)
    } description: {
      Text(loadingDescription)
    }
    .symbolEffect(.pulse, isActive: true)
  }

  private var loadingDescription: String {
    switch message {
    case "Requesting Calendar Access":
      return "Please grant calendar access in the system dialog to view your meetings."
    case "Loading Meetings":
      return "Fetching your meetings from the calendar..."
    default:
      return "Please wait while we complete this operation."
    }
  }
}

#Preview("Requesting Access") {
  LoadingStateView(
    message: "Requesting Calendar Access",
    systemImage: "calendar"
  )
}

#Preview("Loading Meetings") {
  LoadingStateView(
    message: "Loading Meetings"
  )
}

#Preview("Generic Loading") {
  LoadingStateView(
    message: "Processing...",
    systemImage: "gear"
  )
}
