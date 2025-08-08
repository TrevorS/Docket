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

  @State private var isPulsing = false
  @State private var isPostRefreshFading = false
  @State private var fadeTimer: Timer?

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
          Image(systemName: iconName)
            .foregroundStyle(iconColor)
            .animation(
              .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing
            )
            .animation(.easeInOut(duration: 0.4), value: iconName)
            .animation(.easeInOut(duration: 0.4), value: isAutoRefreshActive)

          if let lastRefresh = lastRefresh {
            Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
              .font(.caption)
              .foregroundStyle(.secondary)
          } else {
            Text("Not refreshed yet")
              .font(.caption)
              .foregroundStyle(.secondary)
          }

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
    .onAppear {
      startPulsingIfNeeded()
    }
    .onChange(of: isRefreshing) { _, refreshing in
      startPulsingIfNeeded()
    }
    .onChange(of: isAutoRefreshActive) { _, active in
      startPulsingIfNeeded()
    }
    .onChange(of: lastRefresh) { _, _ in
      handleRefreshComplete()
    }
  }

  private var iconName: String {
    if isAutoRefreshEnabled && !isAutoRefreshActive {
      return "pause.circle.fill"
    } else {
      return "clock"
    }
  }

  private var iconColor: Color {
    if isAutoRefreshEnabled && !isAutoRefreshActive {
      // Paused state - show static orange pause icon (no breathing)
      return .orange
    } else if isRefreshing {
      // Breathing effect during active refresh: fade between secondary and blue
      return isPulsing ? .blue.opacity(0.8) : .secondary
    } else if isPostRefreshFading {
      // Fading from blue back to gray after refresh completes
      return isPulsing ? .blue.opacity(0.4) : .secondary
    } else if isAutoRefreshEnabled && isAutoRefreshActive {
      // Auto-refresh is enabled and active but not currently refreshing - show blue
      return .blue.opacity(0.6)
    } else {
      // Auto-refresh inactive or disabled - show secondary
      return .secondary
    }
  }

  private func startPulsingIfNeeded() {
    fadeTimer?.invalidate()
    fadeTimer = nil

    // Never pulse when paused (orange state)
    if isAutoRefreshEnabled && !isAutoRefreshActive {
      isPostRefreshFading = false
      withAnimation(.easeInOut(duration: 0.3)) {
        isPulsing = false
      }
      return
    }

    if isRefreshing {
      // Start the breathing animation during active refresh
      isPostRefreshFading = false
      withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
        isPulsing = true
      }
    } else if isPostRefreshFading {
      // Continue gentler pulsing during fade-out
      withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
        isPulsing = true
      }
    } else {
      // Stop the breathing animation
      isPostRefreshFading = false
      withAnimation(.easeInOut(duration: 0.3)) {
        isPulsing = false
      }
    }
  }

  private func handleRefreshComplete() {
    // Only trigger fade-out if we just finished refreshing and auto-refresh is active
    guard !isRefreshing && isAutoRefreshActive && isAutoRefreshEnabled else {
      return
    }

    // Start fade-out phase: continue pulsing but gentler, then stop after delay
    isPostRefreshFading = true
    startPulsingIfNeeded()

    // Stop the fade-out animation after 2 seconds
    fadeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
      Task { @MainActor in
        self.isPostRefreshFading = false
        self.startPulsingIfNeeded()
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
