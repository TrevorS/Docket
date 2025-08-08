// ABOUTME: Displays platform indicator badge with icon and name for meeting platforms
// ABOUTME: Shows color-coded indicators for Zoom, Google Meet, and unknown platforms with proper styling

import SwiftUI

/// A view that displays a platform indicator badge with icon and name
struct PlatformIndicatorView: View {
  let platform: MeetingPlatform

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: platform.iconName)
        .font(.caption2)
        .foregroundStyle(platformColor)
      Text(platform.shortName)
        .font(.caption2.weight(.medium))
        .foregroundStyle(platformColor)
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(platformColor.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 4))
  }

  private var platformColor: Color {
    switch platform {
    case .zoom:
      return .blue
    case .googleMeet:
      return .green
    case .unknown:
      return .gray
    }
  }
}

#Preview("Zoom Platform") {
  PlatformIndicatorView(platform: .zoom)
    .padding()
}

#Preview("Google Meet Platform") {
  PlatformIndicatorView(platform: .googleMeet)
    .padding()
}

#Preview("Unknown Platform") {
  PlatformIndicatorView(platform: .unknown)
    .padding()
}

#Preview("All Platforms") {
  VStack(alignment: .leading, spacing: 8) {
    PlatformIndicatorView(platform: .zoom)
    PlatformIndicatorView(platform: .googleMeet)
    PlatformIndicatorView(platform: .unknown)
  }
  .padding()
}
