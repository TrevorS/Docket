// ABOUTME: Bottom status bar component displaying refresh status and hide toggle
// ABOUTME: Full-width macOS-style status bar with left and right aligned items
// ABOUTME: Uses Liquid Glass (.ultraThinMaterial) per Apple guidelines for functional navigation layer

import SwiftUI

public struct StatusBar: View {
  let lastRefresh: Date?
  let isRefreshing: Bool
  let isAutoRefreshEnabled: Bool
  let isAutoRefreshActive: Bool
  @Binding var isHidingCompleted: Bool
  let onToggleAutoRefresh: () -> Void

  public init(
    lastRefresh: Date?, isRefreshing: Bool, isAutoRefreshEnabled: Bool, isAutoRefreshActive: Bool,
    isHidingCompleted: Binding<Bool>, onToggleAutoRefresh: @escaping () -> Void
  ) {
    self.lastRefresh = lastRefresh
    self.isRefreshing = isRefreshing
    self.isAutoRefreshEnabled = isAutoRefreshEnabled
    self.isAutoRefreshActive = isAutoRefreshActive
    self._isHidingCompleted = isHidingCompleted
    self.onToggleAutoRefresh = onToggleAutoRefresh
  }

  public var body: some View {
    VStack(spacing: 0) {
      // Top divider
      Divider()

      // Status bar content
      HStack(spacing: 16) {
        Spacer()

        // Right: Refresh status
        StatusBarRefreshItem(
          lastRefresh: lastRefresh,
          isRefreshing: isRefreshing,
          isAutoRefreshEnabled: isAutoRefreshEnabled,
          isAutoRefreshActive: isAutoRefreshActive,
          onToggleAutoRefresh: onToggleAutoRefresh
        )

        // Right: Hide completed toggle (compact size)
        HideCompletedButton(isHiding: $isHidingCompleted, size: "compact")
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .frame(height: 28)
    }
  }
}

#Preview("Normal State") {
  VStack {
    Spacer()

    StatusBar(
      lastRefresh: Date().addingTimeInterval(-300),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: .constant(true),
      onToggleAutoRefresh: {
        print("Toggle auto-refresh")
      }
    )
  }
  .frame(width: 460, height: 520)
  .background(Color.gray.opacity(0.1))
}

#Preview("Refreshing State") {
  VStack {
    Spacer()

    StatusBar(
      lastRefresh: Date().addingTimeInterval(-600),
      isRefreshing: true,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: .constant(false),
      onToggleAutoRefresh: {
        print("Toggle auto-refresh")
      }
    )
  }
  .frame(width: 460, height: 520)
  .background(Color.gray.opacity(0.1))
}

#Preview("Paused State") {
  VStack {
    Spacer()

    StatusBar(
      lastRefresh: Date().addingTimeInterval(-180),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: false,
      isHidingCompleted: .constant(true),
      onToggleAutoRefresh: {
        print("Resume auto-refresh")
      }
    )
  }
  .frame(width: 460, height: 520)
  .background(Color.gray.opacity(0.1))
}

#Preview("No Refresh Yet") {
  VStack {
    Spacer()

    StatusBar(
      lastRefresh: nil,
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: .constant(true),
      onToggleAutoRefresh: {
        print("Toggle auto-refresh")
      }
    )
  }
  .frame(width: 460, height: 520)
  .background(Color.gray.opacity(0.1))
}

#Preview("Interactive") {
  @Previewable @State var isHiding = true
  @Previewable @State var isActive = true

  VStack(spacing: 0) {
    // Debug info
    HStack {
      Text("Hiding: \(isHiding ? "ON" : "OFF")")
        .font(.caption)
      Spacer()
      Text("Auto-refresh: \(isActive ? "Active" : "Paused")")
        .font(.caption)
    }
    .padding()
    .background(Color.secondary.opacity(0.1))

    Spacer()

    StatusBar(
      lastRefresh: Date().addingTimeInterval(-420),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: isActive,
      isHidingCompleted: $isHiding,
      onToggleAutoRefresh: {
        isActive.toggle()
        print("Auto-refresh toggled: \(isActive)")
      }
    )
  }
  .frame(width: 460, height: 520)
}

#Preview("In App Context") {
  NavigationStack {
    VStack(spacing: 0) {
      List {
        Section("Today") {
          Text("Meeting 1")
          Text("Meeting 2")
          Text("Meeting 3")
        }
      }

      StatusBar(
        lastRefresh: Date().addingTimeInterval(-240),
        isRefreshing: false,
        isAutoRefreshEnabled: true,
        isAutoRefreshActive: true,
        isHidingCompleted: .constant(true),
        onToggleAutoRefresh: {
          print("Toggle auto-refresh")
        }
      )
    }
    .navigationTitle("Docket")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        PinButton(isPinned: .constant(false))
      }
    }
  }
  .frame(width: 460, height: 520)
}
