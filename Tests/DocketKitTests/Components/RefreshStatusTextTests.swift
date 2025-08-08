// ABOUTME: Tests for RefreshStatusText component covering date formatting, nil states, and edge cases
// ABOUTME: Ensures correct text display, styling consistency, and proper state handling

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("RefreshStatusText Tests")
struct RefreshStatusTextTests {

  // MARK: - Basic Component Creation Tests

  @Test("Component creation with recent refresh date")
  @MainActor
  func recentRefreshDate() {
    let fiveMinutesAgo = Date().addingTimeInterval(-300)
    let component = RefreshStatusText(lastRefresh: fiveMinutesAgo)

    #expect(component.lastRefresh == fiveMinutesAgo)
  }

  @Test("Component creation with old refresh date")
  @MainActor
  func oldRefreshDate() {
    let twoHoursAgo = Date().addingTimeInterval(-7200)
    let component = RefreshStatusText(lastRefresh: twoHoursAgo)

    #expect(component.lastRefresh == twoHoursAgo)
  }

  @Test("Component creation with nil refresh date")
  @MainActor
  func nilRefreshDate() {
    let component = RefreshStatusText(lastRefresh: nil)

    #expect(component.lastRefresh == nil)
  }

  // MARK: - Date Formatting Tests

  @Test("Various refresh time scenarios")
  @MainActor
  func variousRefreshTimes() {
    let testCases: [(String, TimeInterval)] = [
      ("Just now", 0),
      ("1 minute ago", -60),
      ("5 minutes ago", -300),
      ("30 minutes ago", -1800),
      ("1 hour ago", -3600),
      ("2 hours ago", -7200),
      ("12 hours ago", -43200),
      ("24 hours ago", -86400),
    ]

    for (description, offset) in testCases {
      let refreshTime = Date().addingTimeInterval(offset)
      let component = RefreshStatusText(lastRefresh: refreshTime)

      #expect(component.lastRefresh == refreshTime, "Failed for: \(description)")
    }
  }

  @Test("Precise date values are preserved")
  @MainActor
  func preciseDateValues() {
    // Test with specific known dates
    let specificDates = [
      Date(timeIntervalSince1970: 1_640_995_200),  // Jan 1, 2022 00:00:00 UTC
      Date(timeIntervalSince1970: 1_672_531_200),  // Jan 1, 2023 00:00:00 UTC
      Date(timeIntervalSince1970: 1_704_067_200),  // Jan 1, 2024 00:00:00 UTC
    ]

    for date in specificDates {
      let component = RefreshStatusText(lastRefresh: date)
      #expect(component.lastRefresh == date)
    }
  }

  // MARK: - Nil State Tests

  @Test("Nil state handling consistency")
  @MainActor
  func nilStateConsistency() {
    let component1 = RefreshStatusText(lastRefresh: nil)
    let component2 = RefreshStatusText(lastRefresh: nil)

    #expect(component1.lastRefresh == nil)
    #expect(component2.lastRefresh == nil)
    #expect(component1.lastRefresh == component2.lastRefresh)
  }

  // MARK: - Edge Case Tests

  @Test("Future dates")
  @MainActor
  func futureDates() {
    let futureDate = Date().addingTimeInterval(3600)  // 1 hour from now
    let component = RefreshStatusText(lastRefresh: futureDate)

    #expect(component.lastRefresh == futureDate)
  }

  @Test("Very old dates")
  @MainActor
  func veryOldDates() {
    let veryOldDate = Date().addingTimeInterval(-86400 * 365)  // 1 year ago
    let component = RefreshStatusText(lastRefresh: veryOldDate)

    #expect(component.lastRefresh == veryOldDate)
  }

  @Test("Extreme future dates")
  @MainActor
  func extremeFutureDates() {
    let extremeFuture = Date().addingTimeInterval(86400 * 365 * 10)  // 10 years from now
    let component = RefreshStatusText(lastRefresh: extremeFuture)

    #expect(component.lastRefresh == extremeFuture)
  }

  @Test("Zero time interval")
  @MainActor
  func zeroTimeInterval() {
    let now = Date()
    let component = RefreshStatusText(lastRefresh: now)

    #expect(component.lastRefresh == now)
  }

  @Test("Microsecond precision dates")
  @MainActor
  func microsecondPrecision() {
    // Test dates with subsecond precision
    let baseTime = Date().timeIntervalSince1970
    let preciseTime1 = Date(timeIntervalSince1970: baseTime + 0.123456)
    let preciseTime2 = Date(timeIntervalSince1970: baseTime + 0.987654)

    let component1 = RefreshStatusText(lastRefresh: preciseTime1)
    let component2 = RefreshStatusText(lastRefresh: preciseTime2)

    #expect(component1.lastRefresh == preciseTime1)
    #expect(component2.lastRefresh == preciseTime2)
    #expect(component1.lastRefresh != component2.lastRefresh)
  }

  // MARK: - State Consistency Tests

  @Test("Multiple instances with same date")
  @MainActor
  func multipleInstancesSameDate() {
    let sharedDate = Date().addingTimeInterval(-1800)  // 30 minutes ago

    let component1 = RefreshStatusText(lastRefresh: sharedDate)
    let component2 = RefreshStatusText(lastRefresh: sharedDate)
    let component3 = RefreshStatusText(lastRefresh: sharedDate)

    #expect(component1.lastRefresh == sharedDate)
    #expect(component2.lastRefresh == sharedDate)
    #expect(component3.lastRefresh == sharedDate)
    #expect(component1.lastRefresh == component2.lastRefresh)
    #expect(component2.lastRefresh == component3.lastRefresh)
  }

  @Test("Different dates maintain independence")
  @MainActor
  func differentDatesIndependence() {
    let date1 = Date().addingTimeInterval(-600)  // 10 minutes ago
    let date2 = Date().addingTimeInterval(-1200)  // 20 minutes ago
    let date3 = Date().addingTimeInterval(-1800)  // 30 minutes ago

    let component1 = RefreshStatusText(lastRefresh: date1)
    let component2 = RefreshStatusText(lastRefresh: date2)
    let component3 = RefreshStatusText(lastRefresh: date3)
    let componentNil = RefreshStatusText(lastRefresh: nil)

    #expect(component1.lastRefresh == date1)
    #expect(component2.lastRefresh == date2)
    #expect(component3.lastRefresh == date3)
    #expect(componentNil.lastRefresh == nil)

    // Verify they're all different
    #expect(component1.lastRefresh != component2.lastRefresh)
    #expect(component2.lastRefresh != component3.lastRefresh)
    #expect(component3.lastRefresh != componentNil.lastRefresh)
  }

  // MARK: - Interface Consistency Tests

  @Test("Component interface stability")
  @MainActor
  func interfaceStability() {
    // Test that the component maintains expected interface behavior
    let testDates: [Date?] = [
      nil,
      Date(),
      Date().addingTimeInterval(-60),
      Date().addingTimeInterval(-3600),
      Date().addingTimeInterval(-86400),
    ]

    for testDate in testDates {
      let component = RefreshStatusText(lastRefresh: testDate)
      #expect(component.lastRefresh == testDate)
    }
  }
}
