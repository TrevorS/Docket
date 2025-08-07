// ABOUTME: Main SwiftUI application structure for Docket
// ABOUTME: Defines the app entry point and window configuration

import SwiftUI

public struct DocketApp: App {
  public init() {}

  public var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .windowStyle(.automatic)
    .windowResizability(.contentSize)
  }
}
