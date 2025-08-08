// ABOUTME: Displays meeting time range and duration with state-based color coding
// ABOUTME: Shows formatted start-end times and duration with visual indicators for meeting status

import Foundation
import SwiftUI

/// A view that displays meeting time information with state-based coloring
struct MeetingTimeView: View {
  let meeting: Meeting

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "clock")
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(timeRangeText)
        .font(.subheadline.monospaced())
        .foregroundStyle(timeColor)

      if let duration = durationText {
        Text("•")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(duration)
          .font(.subheadline.monospaced())
          .foregroundStyle(timeColor)
      }
    }
  }

  private var timeColor: Color {
    if meeting.hasEnded {
      return .secondary
    } else if meeting.hasStarted {
      return .green.opacity(0.8)
    } else if meeting.isUpcoming {
      return .orange.opacity(0.8)
    } else {
      return .blue.opacity(0.8)
    }
  }

  private var timeRangeText: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short

    let startTime = formatter.string(from: meeting.startTime)
    let endTime = formatter.string(from: meeting.endTime)

    return "\(startTime) - \(endTime)"
  }

  private var durationText: String? {
    let duration = meeting.endTime.timeIntervalSince(meeting.startTime)
    let minutes = Int(duration / 60)

    if minutes <= 0 {
      return nil  // Don't show duration for zero or negative duration
    } else if minutes < 60 {
      return "\(minutes)m"
    } else {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60
      if remainingMinutes == 0 {
        return "\(hours)h"
      } else {
        return "\(hours)h \(remainingMinutes)m"
      }
    }
  }
}

#Preview("Upcoming Meeting") {
  let startTime = Date().addingTimeInterval(900)  // 15 minutes from now
  let endTime = startTime.addingTimeInterval(1800)  // 30 minutes duration
  let meeting = Meeting(
    id: UUID(),
    title: "Upcoming Meeting",
    startTime: startTime,
    endTime: endTime,
    joinUrl: "https://zoom.us/j/123456789",
    platform: .zoom,
    organizerName: "John Doe",
    organizerEmail: "john@company.com",
    attendeeCount: 3,
    calendarName: "Work Calendar",
    eventIdentifier: "preview-upcoming-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}

#Preview("Active Meeting") {
  let startTime = Date().addingTimeInterval(-600)  // 10 minutes ago
  let endTime = startTime.addingTimeInterval(2700)  // 45 minutes duration
  let meeting = Meeting(
    id: UUID(),
    title: "Active Meeting",
    startTime: startTime,
    endTime: endTime,
    joinUrl: "https://meet.google.com/abc-defg-hij",
    platform: .googleMeet,
    organizerName: "Jane Smith",
    organizerEmail: "jane@company.com",
    attendeeCount: 5,
    calendarName: "Work Calendar",
    eventIdentifier: "preview-active-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}

#Preview("Ended Meeting") {
  let startTime = Date().addingTimeInterval(-3600)  // 1 hour ago
  let endTime = startTime.addingTimeInterval(1800)  // 30 minutes duration
  let meeting = Meeting(
    id: UUID(),
    title: "Ended Meeting",
    startTime: startTime,
    endTime: endTime,
    joinUrl: nil,
    platform: .unknown,
    organizerName: nil,
    organizerEmail: nil,
    attendeeCount: 0,
    calendarName: "Work Calendar",
    eventIdentifier: "preview-ended-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}

#Preview("Short Meeting (15m)") {
  let startTime = Date().addingTimeInterval(300)  // 5 minutes from now
  let endTime = startTime.addingTimeInterval(900)  // 15 minutes duration
  let meeting = Meeting(
    id: UUID(),
    title: "Short Standup",
    startTime: startTime,
    endTime: endTime,
    joinUrl: "https://zoom.us/j/987654321",
    platform: .zoom,
    organizerName: "Team Lead",
    organizerEmail: "team@company.com",
    attendeeCount: 8,
    calendarName: "Work Calendar",
    eventIdentifier: "preview-short-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}

#Preview("Long Meeting (2h 30m)") {
  let startTime = Date().addingTimeInterval(1800)  // 30 minutes from now
  let endTime = startTime.addingTimeInterval(9000)  // 2.5 hours duration
  let meeting = Meeting(
    id: UUID(),
    title: "All Hands Meeting",
    startTime: startTime,
    endTime: endTime,
    joinUrl: "https://meet.google.com/xyz-uvw-rst",
    platform: .googleMeet,
    organizerName: "CEO",
    organizerEmail: "ceo@company.com",
    attendeeCount: 50,
    calendarName: "Company Calendar",
    eventIdentifier: "preview-long-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}

#Preview("All Day Meeting") {
  let calendar = Calendar.current
  let startTime = calendar.startOfDay(for: Date())
  let endTime = calendar.date(byAdding: .day, value: 1, to: startTime)!
  let meeting = Meeting(
    id: UUID(),
    title: "Conference Day",
    startTime: startTime,
    endTime: endTime,
    joinUrl: "https://zoom.us/j/conference",
    platform: .zoom,
    organizerName: "Event Team",
    organizerEmail: "events@company.com",
    attendeeCount: 100,
    calendarName: "Company Calendar",
    eventIdentifier: "preview-allday-time"
  )

  MeetingTimeView(meeting: meeting)
    .padding()
}
