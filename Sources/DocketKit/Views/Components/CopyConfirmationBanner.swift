// ABOUTME: Animated confirmation banner with auto-hide timing for copy operations
// ABOUTME: Shows success message with green styling and automatically disappears after a set duration

import SwiftUI

struct CopyConfirmationBanner: View {
  @Binding var isVisible: Bool
  let message: String
  let autohideDuration: TimeInterval

  init(
    isVisible: Binding<Bool>, message: String = "Meeting link copied",
    autohideDuration: TimeInterval = 2.0
  ) {
    self._isVisible = isVisible
    self.message = message
    self.autohideDuration = autohideDuration
  }

  var body: some View {
    if isVisible {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
        Text(message)
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 4)
      .background(Color.green.opacity(0.1))
      .transition(.opacity.combined(with: .move(edge: .top)))
      .onAppear {
        startAutoHideTimer()
      }
      .onChange(of: isVisible) { _, newValue in
        if newValue {
          startAutoHideTimer()
        }
      }
    }
  }

  private func startAutoHideTimer() {
    DispatchQueue.main.asyncAfter(deadline: .now() + autohideDuration) {
      withAnimation(.easeInOut(duration: 0.3)) {
        isVisible = false
      }
    }
  }
}

#Preview("Visible Banner") {
  @Previewable @State var isVisible = true

  VStack {
    CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Meeting link copied"
    )

    Spacer()

    Button("Show Banner") {
      withAnimation(.easeInOut(duration: 0.3)) {
        isVisible = true
      }
    }
    .padding()
  }
}

#Preview("Hidden Banner") {
  @Previewable @State var isVisible = false

  VStack {
    CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Meeting link copied"
    )

    Spacer()

    Button("Show Banner") {
      withAnimation(.easeInOut(duration: 0.3)) {
        isVisible = true
      }
    }
    .padding()
  }
}

#Preview("Custom Message") {
  @Previewable @State var isVisible = true

  VStack {
    CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Custom confirmation message"
    )

    CopyConfirmationBanner(
      isVisible: $isVisible,
      message: "Another message with different text",
      autohideDuration: 1.0
    )

    Spacer()

    Button("Toggle Banner") {
      withAnimation(.easeInOut(duration: 0.3)) {
        isVisible.toggle()
      }
    }
    .padding()
  }
}
