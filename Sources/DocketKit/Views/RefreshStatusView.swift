// ABOUTME: Bottom overlay status view showing last refresh time and loading state
// ABOUTME: Appears at bottom of meetings list with refresh timestamp and progress indicator

import SwiftUI

/// Status view showing last refresh time, current loading state, and auto-refresh status
struct RefreshStatusView: View {
  let lastRefresh: Date?
  let isRefreshing: Bool
  let isAutoRefreshEnabled: Bool
  let isAutoRefreshActive: Bool
  let onToggleAutoRefresh: () -> Void

  init(
    lastRefresh: Date?, isRefreshing: Bool, isAutoRefreshEnabled: Bool = true,
    isAutoRefreshActive: Bool = true, onToggleAutoRefresh: @escaping () -> Void = {}
  ) {
    self.lastRefresh = lastRefresh
    self.isRefreshing = isRefreshing
    self.isAutoRefreshEnabled = isAutoRefreshEnabled
    self.isAutoRefreshActive = isAutoRefreshActive
    self.onToggleAutoRefresh = onToggleAutoRefresh
  }

  var body: some View {
    HStack {
      Spacer()

      // Narrow centered content - clickable button
      Button(action: onToggleAutoRefresh) {
        HStack(spacing: 8) {
          RefreshStatusIcon(
            isRefreshing: isRefreshing,
            isAutoRefreshActive: isAutoRefreshActive,
            isAutoRefreshEnabled: isAutoRefreshEnabled,
            lastRefresh: lastRefresh
          )

          RefreshStatusText(lastRefresh: lastRefresh)

          // No longer showing separate paused text - pause icon replaces clock
          // No progress spinner - breathing animation indicates refresh state
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
      }
      .buttonStyle(.plain)
      .contentShape(RoundedRectangle(cornerRadius: 6))

      Spacer()
    }
    .padding(.bottom, 16)
  }

}

#Preview("With Refresh Time") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: Date().addingTimeInterval(-300),  // 5 minutes ago
      isRefreshing: false
    ) {
      print("Toggle auto-refresh (preview)")
    }
  }
  .background(Color.gray.opacity(0.1))
}

#Preview("Currently Refreshing") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: Date().addingTimeInterval(-600),  // 10 minutes ago
      isRefreshing: true
    ) {
      print("Toggle auto-refresh (preview)")
    }
  }
  .background(Color.gray.opacity(0.1))
}

#Preview("No Refresh Yet") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: nil,
      isRefreshing: false
    ) {
      print("Toggle auto-refresh (preview)")
    }
  }
  .background(Color.gray.opacity(0.1))
}

#Preview("Paused State") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: Date().addingTimeInterval(-180),  // 3 minutes ago
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: false
    ) {
      print("Toggle auto-refresh (preview)")
    }
  }
  .background(Color.gray.opacity(0.1))
}
