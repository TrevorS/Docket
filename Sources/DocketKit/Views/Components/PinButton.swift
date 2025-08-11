// ABOUTME: Pin button component for toggling window always-on-top behavior
// ABOUTME: Provides visual feedback for pinned/unpinned state with smooth animations

import SwiftUI

struct PinButton: View {
  @Binding var isPinned: Bool
  @State private var isHovered = false

  var body: some View {
    Button(action: {
      isPinned.toggle()
    }) {
      Image(systemName: isPinned ? "pin.fill" : "pin")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(isPinned ? .blue : .secondary)
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isPinned)
    }
    .buttonStyle(.plain)
    .help(
      isPinned
        ? "Unpin window (allow to go behind other windows)"
        : "Pin window (keep on top of other windows)"
    )
    .onHover { hovering in
      isHovered = hovering
    }
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
