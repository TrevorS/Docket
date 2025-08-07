// ABOUTME: Main SwiftUI application structure for Docket
// ABOUTME: Defines the app entry point and window configuration

import SwiftUI

public struct DocketApp: App {
  public init() {}

  public var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 400, minHeight: 300)
    }
    .windowStyle(.automatic)
    .windowResizability(.contentMinSize)
    .defaultSize(width: 500, height: 400)
  }
}
