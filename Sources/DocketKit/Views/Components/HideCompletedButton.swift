// ABOUTME: Toggle button for hiding completed meetings after 5 minutes
// ABOUTME: Simple toggle with state-based color indication

import SwiftUI

public struct HideCompletedButton: View {
  @Binding var isHiding: Bool
  let size: String

  public init(isHiding: Binding<Bool>, size: String = "normal") {
    self._isHiding = isHiding
    self.size = size
  }

  public var body: some View {
    Button(action: {
      isHiding.toggle()
    }) {
      Image(systemName: isHiding ? "eye.slash" : "eye")
        .font(.system(size: size == "compact" ? 11 : 14, weight: .medium))
        .foregroundStyle(isHiding ? Color.secondary : Color.blue)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHiding)
    }
    .buttonStyle(.plain)
    .help(
      isHiding
        ? "Show all completed meetings (currently hiding meetings 5 minutes after completion)"
        : "Hide meetings 5 minutes after completion"
    )
  }
}

#Preview("Both States - Normal Size") {
  HStack(spacing: 24) {
    VStack(spacing: 8) {
      Text("Hiding (Default)")
        .font(.caption)
        .foregroundStyle(.secondary)
      HideCompletedButton(isHiding: .constant(true))
      Text("eye.slash • secondary")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    Divider()
      .frame(height: 60)

    VStack(spacing: 8) {
      Text("Showing All")
        .font(.caption)
        .foregroundStyle(.secondary)
      HideCompletedButton(isHiding: .constant(false))
      Text("eye • blue")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
  }
  .padding()
}

#Preview("Both States - Compact Size") {
  HStack(spacing: 24) {
    VStack(spacing: 8) {
      Text("Hiding (Default)")
        .font(.caption2)
        .foregroundStyle(.secondary)
      HideCompletedButton(isHiding: .constant(true), size: "compact")
      Text("eye.slash • secondary")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    Divider()
      .frame(height: 40)

    VStack(spacing: 8) {
      Text("Showing All")
        .font(.caption2)
        .foregroundStyle(.secondary)
      HideCompletedButton(isHiding: .constant(false), size: "compact")
      Text("eye • blue")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
  }
  .padding()
}

#Preview("In Toolbar Context") {
  NavigationStack {
    VStack {
      Text("Preview of toolbar buttons")
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationTitle("Docket")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        HStack(spacing: 8) {
          HideCompletedButton(isHiding: .constant(true))
          PinButton(isPinned: .constant(false))
        }
      }
    }
  }
  .frame(width: 500, height: 300)
}

#Preview("Interactive Toggle") {
  @Previewable @State var isHiding = true

  VStack(spacing: 16) {
    Text("Click to toggle")
      .font(.headline)

    HideCompletedButton(isHiding: $isHiding)

    Text(isHiding ? "Hiding meetings 5+ min after completion" : "Showing all completed meetings")
      .font(.caption)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
  }
  .padding()
}

#Preview("Dark Mode") {
  HStack(spacing: 24) {
    VStack {
      Text("Hiding (Default)")
        .font(.caption)
      HideCompletedButton(isHiding: .constant(true))
    }

    VStack {
      Text("Showing All")
        .font(.caption)
      HideCompletedButton(isHiding: .constant(false))
    }
  }
  .padding()
  .preferredColorScheme(.dark)
}
