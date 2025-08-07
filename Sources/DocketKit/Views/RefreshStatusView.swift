// ABOUTME: Bottom overlay status view showing last refresh time and loading state
// ABOUTME: Appears at bottom of meetings list with refresh timestamp and progress indicator

import SwiftUI

/// Status view showing last refresh time and current loading state
struct RefreshStatusView: View {
  let lastRefresh: Date?
  let isRefreshing: Bool

  var body: some View {
    if let lastRefresh = lastRefresh {
      HStack {
        Image(systemName: "clock")
          .foregroundStyle(.secondary)
        Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
          .font(.caption)
          .foregroundStyle(.secondary)

        if isRefreshing {
          Spacer()
          ProgressView()
            .scaleEffect(0.8)
        }
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
      .padding()
    }
  }
}

#Preview("With Refresh Time") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: Date().addingTimeInterval(-300),  // 5 minutes ago
      isRefreshing: false
    )
  }
  .background(Color.gray.opacity(0.1))
}

#Preview("Currently Refreshing") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: Date().addingTimeInterval(-600),  // 10 minutes ago
      isRefreshing: true
    )
  }
  .background(Color.gray.opacity(0.1))
}

#Preview("No Refresh Yet") {
  VStack {
    Spacer()
    RefreshStatusView(
      lastRefresh: nil,
      isRefreshing: false
    )
  }
  .background(Color.gray.opacity(0.1))
}
