// ABOUTME: Bottom overlay status view showing last refresh time and loading state
// ABOUTME: Appears at bottom of meetings list with refresh timestamp and progress indicator

import SwiftUI

/// Status view showing last refresh time, current loading state, and auto-refresh status
struct RefreshStatusView: View {
  let lastRefresh: Date?
  let isRefreshing: Bool
  let isAutoRefreshEnabled: Bool
  let isAutoRefreshActive: Bool

  @State private var isPulsing = false

  init(
    lastRefresh: Date?, isRefreshing: Bool, isAutoRefreshEnabled: Bool = true,
    isAutoRefreshActive: Bool = false
  ) {
    self.lastRefresh = lastRefresh
    self.isRefreshing = isRefreshing
    self.isAutoRefreshEnabled = isAutoRefreshEnabled
    self.isAutoRefreshActive = isAutoRefreshActive
  }

  var body: some View {
    if let lastRefresh = lastRefresh {
      HStack {
        Spacer()

        // Narrow centered content
        HStack(spacing: 8) {
          Image(systemName: "clock")
            .foregroundStyle(clockColor)
            .animation(
              .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)

          Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
            .font(.caption)
            .foregroundStyle(.secondary)

          // Auto-refresh status indicator (paused only)
          if isAutoRefreshEnabled && !isAutoRefreshActive {
            HStack(spacing: 4) {
              Image(systemName: "pause.circle")
                .foregroundStyle(.orange)
                .font(.caption2)
              Text("Paused")
                .font(.caption2)
                .foregroundStyle(.orange)
            }
          }

          if isRefreshing {
            ProgressView()
              .scaleEffect(0.8)
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))

        Spacer()
      }
      .padding(.bottom, 16)
      .onAppear {
        startPulsingIfNeeded()
      }
      .onChange(of: isRefreshing) { _, refreshing in
        startPulsingIfNeeded()
      }
      .onChange(of: isAutoRefreshActive) { _, active in
        startPulsingIfNeeded()
      }
    }
  }

  private var clockColor: Color {
    if isRefreshing {
      // Breathing effect during active refresh: fade between secondary and blue
      return isPulsing ? .blue.opacity(0.8) : .secondary
    } else if isAutoRefreshEnabled && isAutoRefreshActive {
      // Auto-refresh is enabled and active but not currently refreshing - show blue
      return .blue.opacity(0.6)
    } else {
      // Auto-refresh inactive or disabled - show secondary
      return .secondary
    }
  }

  private func startPulsingIfNeeded() {
    if isRefreshing {
      // Start the breathing animation only during active refresh
      withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
        isPulsing = true
      }
    } else {
      // Stop the breathing animation when not refreshing
      withAnimation(.easeInOut(duration: 0.3)) {
        isPulsing = false
      }
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
