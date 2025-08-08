// ABOUTME: Text display component for refresh timestamps with conditional formatting
// ABOUTME: Shows formatted refresh time or fallback message when no refresh has occurred

import SwiftUI

struct RefreshStatusText: View {
  let lastRefresh: Date?

  var body: some View {
    if let lastRefresh = lastRefresh {
      Text("Updated \(lastRefresh, format: .dateTime.hour().minute())")
        .font(.caption)
        .foregroundStyle(.secondary)
    } else {
      Text("Not refreshed yet")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview("Recent Refresh") {
  VStack(spacing: 16) {
    Text("5 minutes ago")
      .font(.headline)
    RefreshStatusText(lastRefresh: Date().addingTimeInterval(-300))
      .padding()
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("Old Refresh") {
  VStack(spacing: 16) {
    Text("2 hours ago")
      .font(.headline)
    RefreshStatusText(lastRefresh: Date().addingTimeInterval(-7200))
      .padding()
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("No Refresh Yet") {
  VStack(spacing: 16) {
    Text("Nil state")
      .font(.headline)
    RefreshStatusText(lastRefresh: nil)
      .padding()
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}

#Preview("Multiple Times") {
  VStack(spacing: 12) {
    Text("Different Refresh Times")
      .font(.headline)

    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Just now:")
        Spacer()
        RefreshStatusText(lastRefresh: Date())
      }

      HStack {
        Text("1 min ago:")
        Spacer()
        RefreshStatusText(lastRefresh: Date().addingTimeInterval(-60))
      }

      HStack {
        Text("15 min ago:")
        Spacer()
        RefreshStatusText(lastRefresh: Date().addingTimeInterval(-900))
      }

      HStack {
        Text("1 hour ago:")
        Spacer()
        RefreshStatusText(lastRefresh: Date().addingTimeInterval(-3600))
      }

      HStack {
        Text("Never:")
        Spacer()
        RefreshStatusText(lastRefresh: nil)
      }
    }
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }
}
