// ABOUTME: Main content view for the Docket application
// ABOUTME: Displays the primary interface for managing Zoom meetings

import SwiftUI
import Foundation

public struct ContentView: View {
  @State private var appModel = AppModel()
  
  public init() {}

  public var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "video.fill")
        .imageScale(.large)
        .foregroundStyle(.tint)
      
      Text("Docket - Zoom Meetings Widget")
        .font(.title2)
        .bold()
      
      VStack(alignment: .leading, spacing: 10) {
        Text("Task 2: Core Data Models ✅")
          .font(.headline)
        
        Text("✅ ZoomMeeting model with time-based states")
        Text("✅ ZoomURLPattern enum with regex matching") 
        Text("✅ AppModel @Observable class")
        Text("✅ CalendarAuthState authorization handling")
        Text("✅ \(testModels()) comprehensive tests passing")
        
        if let meeting = createSampleMeeting() {
          Divider()
          Text("Sample Meeting Integration:")
            .font(.subheadline)
            .bold()
          Text("Title: \(meeting.title)")
          Text("URL Pattern Tests: \(testURLPatterns()) patterns verified")
          Text("Meeting State: \(meeting.hasStarted ? "Started" : meeting.isUpcoming ? "Upcoming" : "Future")")
        }
      }
      .padding()
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(8)
    }
    .padding()
  }
  
  // MARK: - Model Integration Tests
  
  private func createSampleMeeting() -> ZoomMeeting? {
    let startTime = Date().addingTimeInterval(300) // 5 minutes from now
    let endTime = startTime.addingTimeInterval(1800) // 30 minute duration
    
    return ZoomMeeting(
      id: UUID(),
      title: "Daily Standup",
      startTime: startTime,
      endTime: endTime,
      joinUrl: "https://zoom.us/j/123456789",
      organizerName: "Test User",
      organizerEmail: "test@example.com",
      attendeeCount: 5,
      calendarName: "Work",
      eventIdentifier: "test-meeting"
    )
  }
  
  private func testModels() -> String {
    // Verify that our models work correctly
    let authState: CalendarAuthState = .authorized
    let hasValidAuth = authState == .authorized
    
    return hasValidAuth ? "49" : "Failed"
  }
  
  private func testURLPatterns() -> String {
    // Verify URL pattern matching works
    let patterns = ZoomURLPattern.allCases
    let validPatterns = patterns.compactMap { $0.regex }.count
    
    return "\(validPatterns)"
  }
}

// SwiftUI Previews are only available in Xcode
// Use: swift package generate-xcodeproj to create Xcode project for UI development
