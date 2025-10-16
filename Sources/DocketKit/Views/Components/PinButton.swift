// ABOUTME: Pin button component for toggling window always-on-top behavior
// ABOUTME: Provides visual feedback for pinned/unpinned state with smooth animations
// ABOUTME: Icon changes shape (pin/pin.fill + rotation) and color for accessibility

import SwiftUI

public struct PinButton: View {
  @Binding var isPinned: Bool

  public init(isPinned: Binding<Bool>) {
    self._isPinned = isPinned
  }

  public var body: some View {
    Button(action: {
      isPinned.toggle()
    }) {
      Image(systemName: isPinned ? "pin.fill" : "pin")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(isPinned ? Color.blue : Color.secondary)
        .rotationEffect(.degrees(isPinned ? 15 : 0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPinned)
    }
    .buttonStyle(.plain)
    .help(
      isPinned
        ? "Unpin window (allow to go behind other windows)"
        : "Pin window (keep on top of other windows)"
    )
  }
}

#Preview {
  HStack(spacing: 16) {
    VStack {
      Text("Unpinned")
        .font(.caption)
      PinButton(isPinned: .constant(false))
    }

    VStack {
      Text("Pinned")
        .font(.caption)
      PinButton(isPinned: .constant(true))
    }
  }
  .padding()
}
