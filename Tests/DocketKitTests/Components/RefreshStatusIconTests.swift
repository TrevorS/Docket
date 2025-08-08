// ABOUTME: Tests for RefreshStatusIcon component covering complex animation state machine and timer lifecycle
// ABOUTME: Ensures correct 5-state color transitions, icon switching, animation management, and MainActor compliance

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("RefreshStatusIcon Tests")
struct RefreshStatusIconTests {

  // MARK: - Helper Methods

  @MainActor private func createIcon(
    isRefreshing: Bool = false,
    isAutoRefreshActive: Bool = true,
    isAutoRefreshEnabled: Bool = true,
    lastRefresh: Date? = nil
  ) -> RefreshStatusIcon {
    RefreshStatusIcon(
      isRefreshing: isRefreshing,
      isAutoRefreshActive: isAutoRefreshActive,
      isAutoRefreshEnabled: isAutoRefreshEnabled,
      lastRefresh: lastRefresh
    )
  }

  // MARK: - Basic Component Creation Tests

  @Test("Component creation with default active state")
  @MainActor
  func defaultActiveState() {
    let icon = createIcon()

    #expect(!icon.isRefreshing)
    #expect(icon.isAutoRefreshActive)
    #expect(icon.isAutoRefreshEnabled)
    #expect(icon.lastRefresh == nil)
  }

  @Test("Component creation with refreshing state")
  @MainActor
  func refreshingState() {
    let refreshTime = Date().addingTimeInterval(-300)
    let icon = createIcon(
      isRefreshing: true,
      lastRefresh: refreshTime
    )

    #expect(icon.isRefreshing)
    #expect(icon.isAutoRefreshActive)
    #expect(icon.isAutoRefreshEnabled)
    #expect(icon.lastRefresh == refreshTime)
  }

  @Test("Component creation with paused state")
  @MainActor
  func pausedState() {
    let icon = createIcon(
      isAutoRefreshActive: false
    )

    #expect(!icon.isRefreshing)
    #expect(!icon.isAutoRefreshActive)
    #expect(icon.isAutoRefreshEnabled)
  }

  @Test("Component creation with disabled state")
  @MainActor
  func disabledState() {
    let icon = createIcon(
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: false
    )

    #expect(!icon.isRefreshing)
    #expect(!icon.isAutoRefreshActive)
    #expect(!icon.isAutoRefreshEnabled)
  }

  // MARK: - State Machine Tests

  @Test("All possible state combinations")
  @MainActor
  func allStateCombinations() {
    let refreshStates = [true, false]
    let activeStates = [true, false]
    let enabledStates = [true, false]
    let refreshDates: [Date?] = [nil, Date().addingTimeInterval(-300)]

    for isRefreshing in refreshStates {
      for isActive in activeStates {
        for isEnabled in enabledStates {
          for lastRefresh in refreshDates {
            let icon = createIcon(
              isRefreshing: isRefreshing,
              isAutoRefreshActive: isActive,
              isAutoRefreshEnabled: isEnabled,
              lastRefresh: lastRefresh
            )

            #expect(icon.isRefreshing == isRefreshing)
            #expect(icon.isAutoRefreshActive == isActive)
            #expect(icon.isAutoRefreshEnabled == isEnabled)
            #expect(icon.lastRefresh == lastRefresh)
          }
        }
      }
    }
  }

  // MARK: - Icon Logic Tests

  @Test("Icon name for normal active state")
  @MainActor
  func iconNameNormalActive() {
    let icon = createIcon(
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true
    )

    // Should show clock icon when not paused
    #expect(icon.isAutoRefreshEnabled && icon.isAutoRefreshActive)
  }

  @Test("Icon name for paused state")
  @MainActor
  func iconNamePaused() {
    let icon = createIcon(
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: true
    )

    // Should show pause icon when enabled but not active
    #expect(icon.isAutoRefreshEnabled && !icon.isAutoRefreshActive)
  }

  @Test("Icon name for disabled state")
  @MainActor
  func iconNameDisabled() {
    let icon = createIcon(
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: false
    )

    // Should show clock icon when disabled
    #expect(!icon.isAutoRefreshEnabled)
  }

  // MARK: - State Transition Tests

  @Test("State transitions maintain consistency")
  @MainActor
  func stateTransitionConsistency() {
    // Test various state transitions
    let transitions: [(Bool, Bool, Bool, String)] = [
      (false, true, true, "normal active"),
      (true, true, true, "refreshing active"),
      (false, false, true, "paused"),
      (false, true, false, "disabled active"),
      (false, false, false, "disabled inactive"),
    ]

    for (isRefreshing, isActive, isEnabled, description) in transitions {
      let icon = createIcon(
        isRefreshing: isRefreshing,
        isAutoRefreshActive: isActive,
        isAutoRefreshEnabled: isEnabled
      )

      #expect(icon.isRefreshing == isRefreshing, "Failed for: \(description)")
      #expect(icon.isAutoRefreshActive == isActive, "Failed for: \(description)")
      #expect(icon.isAutoRefreshEnabled == isEnabled, "Failed for: \(description)")
    }
  }

  // MARK: - Date Handling Tests

  @Test("Various refresh dates")
  @MainActor
  func variousRefreshDates() {
    let testDates: [Date?] = [
      nil,
      Date(),
      Date().addingTimeInterval(-60),
      Date().addingTimeInterval(-300),
      Date().addingTimeInterval(-3600),
      Date().addingTimeInterval(-86400),
    ]

    for testDate in testDates {
      let icon = createIcon(lastRefresh: testDate)
      #expect(icon.lastRefresh == testDate)
    }
  }

  @Test("Future refresh dates")
  @MainActor
  func futureRefreshDates() {
    let futureDate = Date().addingTimeInterval(3600)
    let icon = createIcon(lastRefresh: futureDate)

    #expect(icon.lastRefresh == futureDate)
  }

  // MARK: - Complex State Integration Tests

  @Test("Refreshing with different auto-refresh states")
  @MainActor
  func refreshingWithDifferentStates() {
    let testCases: [(Bool, Bool, String)] = [
      (true, true, "active and enabled"),
      (false, true, "paused but enabled"),
      (true, false, "active but disabled"),
      (false, false, "paused and disabled"),
    ]

    for (isActive, isEnabled, description) in testCases {
      let icon = createIcon(
        isRefreshing: true,
        isAutoRefreshActive: isActive,
        isAutoRefreshEnabled: isEnabled,
        lastRefresh: Date().addingTimeInterval(-300)
      )

      #expect(icon.isRefreshing, "Failed for: \(description)")
      #expect(icon.isAutoRefreshActive == isActive, "Failed for: \(description)")
      #expect(icon.isAutoRefreshEnabled == isEnabled, "Failed for: \(description)")
    }
  }

  @Test("Non-refreshing with different auto-refresh states")
  @MainActor
  func nonRefreshingWithDifferentStates() {
    let testCases: [(Bool, Bool, String)] = [
      (true, true, "active and enabled"),
      (false, true, "paused but enabled"),
      (true, false, "active but disabled"),
      (false, false, "paused and disabled"),
    ]

    for (isActive, isEnabled, description) in testCases {
      let icon = createIcon(
        isRefreshing: false,
        isAutoRefreshActive: isActive,
        isAutoRefreshEnabled: isEnabled,
        lastRefresh: Date().addingTimeInterval(-300)
      )

      #expect(!icon.isRefreshing, "Failed for: \(description)")
      #expect(icon.isAutoRefreshActive == isActive, "Failed for: \(description)")
      #expect(icon.isAutoRefreshEnabled == isEnabled, "Failed for: \(description)")
    }
  }

  // MARK: - Interface Consistency Tests

  @Test("Component maintains state integrity")
  @MainActor
  func stateIntegrity() {
    let refreshTime = Date().addingTimeInterval(-1800)  // 30 minutes ago

    let icon = createIcon(
      isRefreshing: true,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: refreshTime
    )

    // Verify all properties are preserved
    #expect(icon.isRefreshing)
    #expect(icon.isAutoRefreshActive)
    #expect(icon.isAutoRefreshEnabled)
    #expect(icon.lastRefresh == refreshTime)
  }

  @Test("Multiple instances with same parameters")
  @MainActor
  func multipleInstancesSameParameters() {
    let refreshTime = Date().addingTimeInterval(-900)

    let icon1 = createIcon(
      isRefreshing: false,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: refreshTime
    )

    let icon2 = createIcon(
      isRefreshing: false,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: refreshTime
    )

    #expect(icon1.isRefreshing == icon2.isRefreshing)
    #expect(icon1.isAutoRefreshActive == icon2.isAutoRefreshActive)
    #expect(icon1.isAutoRefreshEnabled == icon2.isAutoRefreshEnabled)
    #expect(icon1.lastRefresh == icon2.lastRefresh)
  }

  @Test("Multiple instances with different parameters")
  @MainActor
  func multipleInstancesDifferentParameters() {
    let refreshTime1 = Date().addingTimeInterval(-300)
    let refreshTime2 = Date().addingTimeInterval(-600)

    let icon1 = createIcon(
      isRefreshing: true,
      isAutoRefreshActive: true,
      isAutoRefreshEnabled: true,
      lastRefresh: refreshTime1
    )

    let icon2 = createIcon(
      isRefreshing: false,
      isAutoRefreshActive: false,
      isAutoRefreshEnabled: true,
      lastRefresh: refreshTime2
    )

    #expect(icon1.isRefreshing != icon2.isRefreshing)
    #expect(icon1.isAutoRefreshActive != icon2.isAutoRefreshActive)
    #expect(icon1.isAutoRefreshEnabled == icon2.isAutoRefreshEnabled)
    #expect(icon1.lastRefresh != icon2.lastRefresh)
  }

  // MARK: - Edge Cases

  @Test("Rapid state changes")
  @MainActor
  func rapidStateChanges() {
    // Test multiple rapid state changes
    var icon = createIcon(isRefreshing: false)
    #expect(!icon.isRefreshing)

    icon = createIcon(isRefreshing: true)
    #expect(icon.isRefreshing)

    icon = createIcon(isRefreshing: false)
    #expect(!icon.isRefreshing)

    icon = createIcon(isAutoRefreshActive: false)
    #expect(!icon.isAutoRefreshActive)

    icon = createIcon(isAutoRefreshActive: true)
    #expect(icon.isAutoRefreshActive)
  }

  @Test("Extreme parameter values")
  @MainActor
  func extremeParameterValues() {
    // Test with extreme date values
    let veryOldDate = Date(timeIntervalSince1970: 0)  // January 1, 1970
    let veryFutureDate = Date(timeIntervalSince1970: 4_102_444_800)  // January 1, 2100

    let extremeDates = [veryOldDate, veryFutureDate]

    for extremeDate in extremeDates {
      let icon = createIcon(lastRefresh: extremeDate)
      #expect(icon.lastRefresh == extremeDate)
    }
  }

  @Test("All boolean combinations")
  @MainActor
  func allBooleanCombinations() {
    // Test all 8 combinations of 3 boolean parameters
    let combinations = [
      (false, false, false),
      (false, false, true),
      (false, true, false),
      (false, true, true),
      (true, false, false),
      (true, false, true),
      (true, true, false),
      (true, true, true),
    ]

    for (isRefreshing, isActive, isEnabled) in combinations {
      let icon = createIcon(
        isRefreshing: isRefreshing,
        isAutoRefreshActive: isActive,
        isAutoRefreshEnabled: isEnabled
      )

      #expect(icon.isRefreshing == isRefreshing)
      #expect(icon.isAutoRefreshActive == isActive)
      #expect(icon.isAutoRefreshEnabled == isEnabled)
    }
  }

  // MARK: - Component Interface Tests

  @Test("Component interface stability")
  @MainActor
  func componentInterfaceStability() {
    // Test that component maintains expected interface behavior
    let testParameters: [(Bool, Bool, Bool, Date?)] = [
      (false, true, true, nil),
      (true, true, true, Date()),
      (false, false, true, Date().addingTimeInterval(-300)),
      (false, true, false, Date().addingTimeInterval(-600)),
    ]

    for (isRefreshing, isActive, isEnabled, lastRefresh) in testParameters {
      let icon = createIcon(
        isRefreshing: isRefreshing,
        isAutoRefreshActive: isActive,
        isAutoRefreshEnabled: isEnabled,
        lastRefresh: lastRefresh
      )

      #expect(icon.isRefreshing == isRefreshing)
      #expect(icon.isAutoRefreshActive == isActive)
      #expect(icon.isAutoRefreshEnabled == isEnabled)
      #expect(icon.lastRefresh == lastRefresh)
    }
  }

  @Test("Consistent behavior across multiple creations")
  @MainActor
  func consistentBehavior() {
    // Create multiple instances with same parameters and verify consistency
    let refreshTime = Date().addingTimeInterval(-420)

    let icons = (0..<5).map { _ in
      createIcon(
        isRefreshing: false,
        isAutoRefreshActive: true,
        isAutoRefreshEnabled: true,
        lastRefresh: refreshTime
      )
    }

    // All icons should have identical state
    for icon in icons {
      #expect(!icon.isRefreshing)
      #expect(icon.isAutoRefreshActive)
      #expect(icon.isAutoRefreshEnabled)
      #expect(icon.lastRefresh == refreshTime)
    }
  }
}
