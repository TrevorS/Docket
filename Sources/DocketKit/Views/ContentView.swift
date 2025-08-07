// ABOUTME: Main content view for the Docket application
// ABOUTME: Displays the primary interface for managing Zoom meetings

import SwiftUI

public struct ContentView: View {
  public init() {}

  public var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, Docket!")
    }
    .padding()
  }
}

// SwiftUI Previews are only available in Xcode
// Use: swift package generate-xcodeproj to create Xcode project for UI development
