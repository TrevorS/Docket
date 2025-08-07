// ABOUTME: Comprehensive empty state view handling different calendar authorization states
// ABOUTME: Shows appropriate messages and actions based on permission status and error conditions

import SwiftUI

/// Empty state view that handles different authorization states and provides appropriate actions
struct EmptyStateView: View {
  let authState: CalendarAuthState
  let onRetry: () -> Void
  let onGrantAccess: () async -> Void
  let onOpenSettings: () -> Void

  var body: some View {
    Group {
      switch authState {
      case .denied:
        ContentUnavailableView {
          Label("Calendar Access Denied", systemImage: "calendar")
        } description: {
          Text("Please grant calendar access in System Settings to see your Zoom meetings.")
        } actions: {
          Button("Open Settings") {
            onOpenSettings()
          }
          .buttonStyle(.borderedProminent)
        }

      case .restricted:
        ContentUnavailableView {
          Label("Calendar Access Restricted", systemImage: "calendar")
        } description: {
          Text("Calendar access is restricted by system policies.")
        }

      case let .error(message):
        ContentUnavailableView {
          Label("Error Loading Calendar", systemImage: "exclamationmark.triangle")
        } description: {
          Text(message)
        } actions: {
          Button("Try Again") {
            onRetry()
          }
          .buttonStyle(.borderedProminent)
        }

      case .fullAccess, .authorized:
        ContentUnavailableView {
          Label("No Zoom Meetings", systemImage: "calendar")
        } description: {
          Text("You don't have any Zoom meetings in the next 3 days.")
        } actions: {
          Button("Refresh") {
            onRetry()
          }
          .buttonStyle(.bordered)
        }

      case .notDetermined, .writeOnly:
        ContentUnavailableView {
          Label("Calendar Access Required", systemImage: "calendar")
        } description: {
          Text("Grant calendar access to see your Zoom meetings.")
        } actions: {
          Button("Grant Access") {
            Task {
              await onGrantAccess()
            }
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
  }
}

#Preview("Access Denied") {
  EmptyStateView(
    authState: .denied,
    onRetry: {},
    onGrantAccess: {},
    onOpenSettings: {}
  )
}

#Preview("Error State") {
  EmptyStateView(
    authState: .error("Failed to connect to calendar service"),
    onRetry: {},
    onGrantAccess: {},
    onOpenSettings: {}
  )
}

#Preview("No Meetings") {
  EmptyStateView(
    authState: .fullAccess,
    onRetry: {},
    onGrantAccess: {},
    onOpenSettings: {}
  )
}

#Preview("Access Required") {
  EmptyStateView(
    authState: .notDetermined,
    onRetry: {},
    onGrantAccess: {},
    onOpenSettings: {}
  )
}
