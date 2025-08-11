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

#Preview {
  ContentView()
    .environment(AppModel())
}
