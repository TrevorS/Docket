// ABOUTME: Status bar item showing refresh status and timestamp
// ABOUTME: Compact version reusing RefreshStatusIcon and RefreshStatusText for bottom status bar

import SwiftUI

struct StatusBarRefreshItem: View {
  let lastRefresh: Date?
  let isRefreshing: Bool
  let isAutoRefreshEnabled: Bool
  let isAutoRefreshActive: Bool
  let onToggleAutoRefresh: () -> Void

  var body: some View {
    Button(action: onToggleAutoRefresh) {
      RefreshStatusIcon(
        isRefreshing: isRefreshing,
        isAutoRefreshActive: isAutoRefreshActive,
        isAutoRefreshEnabled: isAutoRefreshEnabled,
        lastRefresh: lastRefresh
      )
      .font(.system(size: 11))
    }
    .buttonStyle(.plain)
    .background(.clear)
    .help(tooltipText)
  }

  private var tooltipText: String {
    if let lastRefresh = lastRefresh {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      return "Updated \(formatter.string(from: lastRefresh))"
    } else {
      return "Not refreshed yet"
    }
  }
}

#Preview("With Recent Refresh") {
  StatusBarRefreshItem(
    lastRefresh: Date().addingTimeInterval(-300),  // 5 minutes ago
    isRefreshing: false,
    isAutoRefreshEnabled: true,
    isAutoRefreshActive: true
  ) {
    print("Toggle auto-refresh")
  }
  .padding()
  .background(.regularMaterial)
}

#Preview("Currently Refreshing") {
  StatusBarRefreshItem(
    lastRefresh: Date().addingTimeInterval(-600),  // 10 minutes ago
    isRefreshing: true,
    isAutoRefreshEnabled: true,
    isAutoRefreshActive: true
  ) {
    print("Toggle auto-refresh")
  }
  .padding()
  .background(.regularMaterial)
}

#Preview("Paused State") {
  StatusBarRefreshItem(
    lastRefresh: Date().addingTimeInterval(-180),  // 3 minutes ago
    isRefreshing: false,
    isAutoRefreshEnabled: true,
    isAutoRefreshActive: false
  ) {
    print("Resume auto-refresh")
  }
  .padding()
  .background(.regularMaterial)
}

#Preview("No Refresh Yet") {
  StatusBarRefreshItem(
    lastRefresh: nil,
    isRefreshing: false,
    isAutoRefreshEnabled: true,
    isAutoRefreshActive: true
  ) {
    print("Toggle auto-refresh")
  }
  .padding()
  .background(.regularMaterial)
}

#Preview("In Status Bar Context") {
  HStack {
    StatusBarRefreshItem(
      lastRefresh: Date().addingTimeInterval(-420),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true
    ) {
      print("Toggle")
    }

    Spacer()

    HideCompletedButton(isHiding: .constant(true), size: "compact")
  }
  .padding(.horizontal, 12)
  .padding(.vertical, 6)
  .background(.regularMaterial)
  .frame(width: 400)
}
