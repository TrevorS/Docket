// ABOUTME: Simplified state-driven animated icon component for refresh status visualization
// ABOUTME: Uses direct prop-based state management with no internal state or timers

import SwiftUI

struct RefreshStatusIcon: View {
  let isRefreshing: Bool
  let isAutoRefreshActive: Bool
  let isAutoRefreshEnabled: Bool
  let lastRefresh: Date?

  // MARK: - Computed Properties

  /// Simple boolean: should we show the pause icon?
  private var shouldShowPauseIcon: Bool {
    isAutoRefreshEnabled && !isAutoRefreshActive
  }

  /// Simple boolean: should we animate (breathe)?
  private var shouldAnimate: Bool {
    isRefreshing
  }

  // MARK: - View Body

  var body: some View {
    Image(systemName: iconName)
      .foregroundStyle(iconColor)
      .scaleEffect(shouldAnimate ? 1.2 : 1.0)
      .opacity(shouldAnimate ? 0.6 : 1.0)
      .animation(
        shouldAnimate
          ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
          : .easeInOut(duration: 0.3),
        value: shouldAnimate
      )
  }

  // MARK: - Visual Properties

  private var iconName: String {
    shouldShowPauseIcon ? "pause.circle.fill" : "clock"
  }

  private var iconColor: Color {
    if shouldShowPauseIcon {
      // Paused state - static blue
      return .blue.opacity(0.6)
    } else if isRefreshing {
      // Refreshing - pulsing blue
      return .blue
    } else if isAutoRefreshEnabled && isAutoRefreshActive {
      // Active and ready - subtle blue
      return .blue.opacity(0.7)
    } else {
      // Disabled or inactive - gray
      return .secondary
    }
  }
}

#Preview("Normal Active") {
  VStack(spacing: 16) {
    Text("Normal Active State")
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

#Preview("Refreshing Animation") {
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

#Preview("Disabled State") {
  VStack(spacing: 16) {
    Text("Disabled State")
      .font(.headline)

    RefreshStatusIcon(
      isRefreshing: false,
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: false,
      lastRefresh: nil
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
