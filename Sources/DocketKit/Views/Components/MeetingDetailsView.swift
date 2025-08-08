// ABOUTME: Meeting organizer and attendee information display component
// ABOUTME: Shows organizer name and attendee count with consistent formatting and icons

import SwiftUI

struct MeetingDetailsView: View {
  let organizerName: String?
  let attendeeCount: Int

  var body: some View {
    HStack(spacing: 12) {
      if let organizer = organizerName, !organizer.isEmpty {
        HStack(spacing: 4) {
          Image(systemName: "person.crop.circle")
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(organizer)
            .font(.caption2.monospaced())
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }

      if attendeeCount > 0 {
        HStack(spacing: 4) {
          Image(systemName: "person.2")
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(attendeeText)
            .font(.caption2.monospaced())
            .foregroundStyle(.secondary)
        }
      }

      Spacer()
    }
  }

  private var attendeeText: String {
    "\(attendeeCount) \(attendeeCount == 1 ? "person" : "people")"
  }
}

#Preview("With Organizer & Attendees") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "John Smith",
      attendeeCount: 5
    )
  }
  .padding()
}

#Preview("Organizer Only") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "Sarah Johnson",
      attendeeCount: 0
    )
  }
  .padding()
}

#Preview("Attendees Only") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: nil,
      attendeeCount: 12
    )
  }
  .padding()
}

#Preview("Minimal Info") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "",
      attendeeCount: 0
    )
  }
  .padding()
}
