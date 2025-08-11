// ABOUTME: Clean state-driven animated icon component for refresh status visualization
// ABOUTME: Uses enum-based state management with clear state transitions and debugging

import SwiftUI

enum RefreshStatus: CustomStringConvertible {
  case paused  // Auto-refresh enabled but paused
  case refreshing  // Currently refreshing
  case fadingOut  // Just finished refreshing, fading back to normal
  case active  // Auto-refresh active, waiting for next cycle
  case disabled  // Auto-refresh disabled

  var description: String {
    switch self {
    case .paused: return "paused"
    case .refreshing: return "refreshing"
    case .fadingOut: return "fadingOut"
    case .active: return "active"
    case .disabled: return "disabled"
    }
  }
}

struct RefreshStatusIcon: View {
  let isRefreshing: Bool
  let isAutoRefreshActive: Bool
  let isAutoRefreshEnabled: Bool
  let lastRefresh: Date?

  @State private var isPulsing = false
  @State private var isPostRefreshFading = false
  @State private var fadeTimer: Timer?

  // MARK: - Computed Properties

  private var refreshStatus: RefreshStatus {
    let status: RefreshStatus

    if isAutoRefreshEnabled && !isAutoRefreshActive {
      status = .paused
    } else if isRefreshing {
      status = .refreshing
    } else if isPostRefreshFading {
      status = .fadingOut
    } else if isAutoRefreshEnabled && isAutoRefreshActive {
      status = .active
    } else {
      status = .disabled
    }

    // Debug logging disabled - orange clock issue resolved
    // print("🔍 RefreshStatusIcon - Status: \(status), enabled: \(isAutoRefreshEnabled), active: \(isAutoRefreshActive), refreshing: \(isRefreshing), fading: \(isPostRefreshFading)")

    return status
  }

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
    switch refreshStatus {
    case .paused:
      return "pause.circle.fill"
    default:
      return "clock"
    }
  }

  private var iconColor: Color {
    let color: Color
    switch refreshStatus {
    case .paused:
      // Paused state - show static blue pause icon (no breathing) - NEVER orange
      color = .blue.opacity(0.5)
    // print("🎨 RefreshStatusIcon - Color: PAUSED -> blue.opacity(0.5)")
    case .refreshing:
      // Breathing effect during active refresh: fade between secondary and blue
      color = isPulsing ? .blue.opacity(0.8) : .secondary
    // print("🎨 RefreshStatusIcon - Color: REFRESHING -> \(isPulsing ? "blue.opacity(0.8)" : "secondary")")
    case .fadingOut:
      // Fading from blue back to gray after refresh completes
      color = isPulsing ? .blue.opacity(0.4) : .secondary
    // print("🎨 RefreshStatusIcon - Color: FADING_OUT -> \(isPulsing ? "blue.opacity(0.4)" : "secondary")")
    case .active:
      // Auto-refresh is enabled and active but not currently refreshing - show blue
      color = .blue.opacity(0.6)
    // print("🎨 RefreshStatusIcon - Color: ACTIVE -> blue.opacity(0.6)")
    case .disabled:
      // Auto-refresh inactive or disabled - show secondary
      color = .secondary
    // print("🎨 RefreshStatusIcon - Color: DISABLED -> secondary")
    }
    return color
  }

  private func startPulsingIfNeeded() {
    fadeTimer?.invalidate()
    fadeTimer = nil

    switch refreshStatus {
    case .paused:
      // Never pulse when paused (static blue state)
      isPostRefreshFading = false
      withAnimation(.easeInOut(duration: 0.3)) {
        isPulsing = false
      }

    case .refreshing:
      // Start the breathing animation during active refresh
      isPostRefreshFading = false
      withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
        isPulsing = true
      }

    case .fadingOut:
      // Continue gentler pulsing during fade-out
      withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
        isPulsing = true
      }

    case .active, .disabled:
      // Stop the breathing animation for normal states
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
