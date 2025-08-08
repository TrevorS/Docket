// ABOUTME: Complex animated icon component with 5-state color machine and breathing animations
// ABOUTME: Manages sophisticated animation state transitions, timer lifecycle, and refresh status visualization

import SwiftUI

struct RefreshStatusIcon: View {
  let isRefreshing: Bool
  let isAutoRefreshActive: Bool
  let isAutoRefreshEnabled: Bool
  let lastRefresh: Date?

  @State private var isPulsing = false
  @State private var isPostRefreshFading = false
  @State private var fadeTimer: Timer?

  var body: some View {
    Image(systemName: iconName)
      .foregroundStyle(iconColor)
      .animation(
        .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing
      )
      .animation(.easeInOut(duration: 0.4), value: iconName)
      .animation(.easeInOut(duration: 0.4), value: isAutoRefreshActive)
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

#Preview("Normal Clock") {
  VStack(spacing: 16) {
    Text("Normal State")
      .font(.headline)

    RefreshStatusIcon(
      isRefreshing: false,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: Date().addingTimeInterval(-300)
    )
    .font(.title2)
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("Paused State") {
  VStack(spacing: 16) {
    Text("Paused State")
      .font(.headline)

    RefreshStatusIcon(
      isRefreshing: false,
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: true,
      lastRefresh: Date().addingTimeInterval(-300)
    )
    .font(.title2)
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("Breathing Animation") {
  VStack(spacing: 16) {
    Text("Refreshing (Breathing)")
      .font(.headline)

    RefreshStatusIcon(
      isRefreshing: true,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: Date().addingTimeInterval(-600)
    )
    .font(.title2)
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("All States") {
  VStack(spacing: 12) {
    Text("RefreshStatusIcon - All States")
      .font(.headline)

    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
      VStack {
        Text("Normal")
        RefreshStatusIcon(
          isRefreshing: false,
          isAutoRefreshActive: true,
          isAutoRefreshEnabled: true,
          lastRefresh: Date().addingTimeInterval(-300)
        )
        .font(.title3)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
      }

      VStack {
        Text("Paused")
        RefreshStatusIcon(
          isRefreshing: false,
          isAutoRefreshActive: false,
          isAutoRefreshEnabled: true,
          lastRefresh: Date().addingTimeInterval(-300)
        )
        .font(.title3)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
      }

      VStack {
        Text("Refreshing")
        RefreshStatusIcon(
          isRefreshing: true,
          isAutoRefreshActive: true,
          isAutoRefreshEnabled: true,
          lastRefresh: Date().addingTimeInterval(-600)
        )
        .font(.title3)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
      }

      VStack {
        Text("Disabled")
        RefreshStatusIcon(
          isRefreshing: false,
          isAutoRefreshActive: false,
          isAutoRefreshEnabled: false,
          lastRefresh: nil
        )
        .font(.title3)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
      }
    }
  }
  .padding()
}
