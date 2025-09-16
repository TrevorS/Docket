// ABOUTME: Meeting organizer and attendee information display component
// ABOUTME: Shows organizer name and attendee count with consistent formatting and icons

import SwiftUI

struct MeetingDetailsView: View {
  let organizerName: String?
  let attendeeCount: Int
  let attendees: [(name: String?, email: String?)]

  @State private var showAttendeePopover = false
  @State private var isHovered = false

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
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .brightness(isHovered ? 0.1 : 0)
        .shadow(color: .accentColor.opacity(isHovered ? 0.3 : 0), radius: 2)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
          isHovered = hovering
        }
        .onTapGesture {
          showAttendeePopover = true
        }
        .popover(isPresented: $showAttendeePopover) {
          attendeePopoverContent
        }
      }

      Spacer()
    }
  }

  private var attendeeText: String {
    "\(attendeeCount) \(attendeeCount == 1 ? "person" : "people")"
  }

  private var attendeePopoverContent: some View {
    VStack(alignment: .leading, spacing: 4) {
      if attendees.isEmpty {
        Text("No attendee details available")
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(8)
      } else {
        Text("Attendees (\(attendees.count))")
          .font(.caption.weight(.semibold))
          .padding(.horizontal, 8)
          .padding(.top, 8)

        ForEach(Array(attendees.enumerated()), id: \.offset) { index, attendee in
          HStack(spacing: 6) {
            Image(systemName: "person.circle")
              .font(.caption)
              .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
              if let name = attendee.name, !name.isEmpty {
                Text(name)
                  .font(.caption)
                  .lineLimit(1)
              }

              if let email = attendee.email, !email.isEmpty {
                Text(email)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              } else if attendee.name?.isEmpty != false {
                Text("Unknown attendee")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .italic()
              }
            }

            Spacer()
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
        }
        .padding(.bottom, 4)
      }
    }
    .frame(maxWidth: 250)
  }
}

#Preview("With Organizer & Attendees") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "John Smith",
      attendeeCount: 5,
      attendees: [
        (name: "Alice Johnson", email: "alice@example.com"),
        (name: "Bob Wilson", email: "bob@example.com"),
        (name: "Carol Davis", email: nil),
        (name: nil, email: "dave@example.com"),
        (name: "Eve Brown", email: "eve@example.com"),
      ]
    )
  }
  .padding()
}

#Preview("Organizer Only") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "Sarah Johnson",
      attendeeCount: 0,
      attendees: []
    )
  }
  .padding()
}

#Preview("Attendees Only") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: nil,
      attendeeCount: 3,
      attendees: [
        (name: "John Doe", email: "john@company.com"),
        (name: "Jane Smith", email: nil),
        (name: "Mike Johnson", email: "mike.j@company.com"),
      ]
    )
  }
  .padding()
}

#Preview("Minimal Info") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "",
      attendeeCount: 0,
      attendees: []
    )
  }
  .padding()
}

#Preview("Large Meeting (50+ Attendees)") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "Conference Organizer",
      attendeeCount: 87,
      attendees: [
        (name: "John Smith", email: "john@company.com"),
        (name: "Alice Johnson", email: "alice@company.com"),
        (name: "Bob Wilson", email: nil),
        (name: "Carol Davis", email: "carol@external.com"),
        (name: nil, email: "anonymous@attendee.com"),
        (name: "David Lee", email: "david@company.com"),
        (name: "Emma Brown", email: "emma@partner.com"),
        (name: "Frank Miller", email: nil),
        (name: "Grace Chen", email: "grace@company.com"),
        (name: "Henry Taylor", email: "henry@external.com"),
        // Only showing first 10 of 87 attendees
      ]
    )
  }
  .padding()
}

#Preview("Empty Attendee Details") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "Meeting Host",
      attendeeCount: 5,
      attendees: []  // No attendee details available
    )
  }
  .padding()
}

#Preview("Mixed Attendee Data Quality") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "Project Manager",
      attendeeCount: 8,
      attendees: [
        (name: "Complete User", email: "complete@company.com"),
        (name: "Name Only", email: nil),
        (name: nil, email: "email-only@company.com"),
        (name: "", email: ""),  // Empty strings
        (name: "   ", email: "   "),  // Whitespace only
        (name: "Very Long Name That Should Be Truncated Properly", email: "long@company.com"),
        (name: "Normal User", email: "user@verylongdomainnamethatmightcauselayoutissues.com"),
        (name: nil, email: nil),  // Completely missing data
      ]
    )
  }
  .padding()
}

#Preview("Dark Mode") {
  VStack(alignment: .leading, spacing: 8) {
    MeetingDetailsView(
      organizerName: "John Smith",
      attendeeCount: 5,
      attendees: [
        (name: "Alice Johnson", email: "alice@example.com"),
        (name: "Bob Wilson", email: "bob@example.com"),
        (name: "Carol Davis", email: nil),
        (name: nil, email: "dave@example.com"),
        (name: "Eve Brown", email: "eve@example.com"),
      ]
    )
  }
  .padding()
  .preferredColorScheme(.dark)
}

#Preview("All Scenarios") {
  VStack(alignment: .leading, spacing: 16) {
    Text("MeetingDetailsView - All Scenarios")
      .font(.headline)

    VStack(alignment: .leading, spacing: 12) {
      // With full data
      MeetingDetailsView(
        organizerName: "John Smith",
        attendeeCount: 5,
        attendees: [
          (name: "Alice Johnson", email: "alice@example.com"),
          (name: "Bob Wilson", email: nil),
          (name: nil, email: "carol@example.com"),
        ]
      )

      Divider()

      // Organizer only
      MeetingDetailsView(
        organizerName: "Sarah Johnson",
        attendeeCount: 0,
        attendees: []
      )

      Divider()

      // Attendees only
      MeetingDetailsView(
        organizerName: nil,
        attendeeCount: 3,
        attendees: [
          (name: "Team Member", email: "member@company.com")
        ]
      )

      Divider()

      // Large meeting
      MeetingDetailsView(
        organizerName: "Conference Host",
        attendeeCount: 150,
        attendees: []
      )

      Divider()

      // Minimal
      MeetingDetailsView(
        organizerName: "",
        attendeeCount: 0,
        attendees: []
      )
    }
  }
  .padding()
}
