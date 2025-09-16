// ABOUTME: Main content view for the Docket application
// ABOUTME: Displays the meetings list interface for managing Zoom meetings

import Foundation
import SwiftUI

public struct ContentView: View {
  public init() {}

  public var body: some View {
    MeetingsListView()
  }

}

#Preview("Default State") {
  ContentView()
    .environment(AppModel())
}

#Preview("With Mock Calendar Manager") {
  ContentView()
    .environment(AppModel())
    .environment(PreviewData.MockCalendarManager())
}

#Preview("Dark Mode") {
  ContentView()
    .environment(AppModel())
    .environment(PreviewData.MockCalendarManager())
    .preferredColorScheme(.dark)
}

#Preview("App Window Size") {
  ContentView()
    .environment(AppModel())
    .environment(PreviewData.MockCalendarManager())
    .frame(width: 460, height: 520)
    .background(.regularMaterial)
}
