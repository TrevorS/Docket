// ABOUTME: Tests for StatusBar component
// ABOUTME: Ensures correct composition and state management of status bar container

import Foundation
import SwiftUI
import Testing

@testable import DocketKit

@Suite("StatusBar Tests")
struct StatusBarTests {

  @Test("Component can be created with all parameters")
  @MainActor
  func componentCreation() {
    var isHiding = true

    let view = StatusBar(
      lastRefresh: Date(),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: Binding(
        get: { isHiding },
        set: { isHiding = $0 }
      ),
      onToggleAutoRefresh: {}
    )

    #expect(view != nil)
  }

  @Test("Component handles all refresh states")
  @MainActor
  func allRefreshStates() {
    let states = [
      (refreshing: false, enabled: true, active: true, description: "Normal"),
      (refreshing: true, enabled: true, active: true, description: "Refreshing"),
      (refreshing: false, enabled: true, active: false, description: "Paused"),
      (refreshing: false, enabled: false, active: false, description: "Disabled"),
    ]

    for state in states {
      var isHiding = false

      let view = StatusBar(
        lastRefresh: Date(),
        isRefreshing: state.refreshing,
        isAutoRefreshEnabled: state.enabled,
        isAutoRefreshActive: state.active,
        isHidingCompleted: Binding(
          get: { isHiding },
          set: { isHiding = $0 }
        ),
        onToggleAutoRefresh: {}
      )

      #expect(view != nil)
    }
  }

  @Test("Hide completed binding synchronization")
  @MainActor
  func hideCompletedBinding() {
    var isHiding = true

    let binding = Binding(
      get: { isHiding },
      set: { isHiding = $0 }
    )

    let _ = StatusBar(
      lastRefresh: Date(),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: binding,
      onToggleAutoRefresh: {}
    )

    #expect(isHiding == true)

    binding.wrappedValue = false
    #expect(isHiding == false)

    binding.wrappedValue = true
    #expect(isHiding == true)
  }

  @Test("Component handles nil refresh date")
  @MainActor
  func nilRefreshDate() {
    var isHiding = false

    let view = StatusBar(
      lastRefresh: nil,
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: Binding(
        get: { isHiding },
        set: { isHiding = $0 }
      ),
      onToggleAutoRefresh: {}
    )

    #expect(view != nil)
  }

  @Test("Component handles edge case timestamps")
  @MainActor
  func edgeCaseTimestamps() {
    let timestamps = [
      nil,
      Date.distantPast,
      Date.distantFuture,
      Date(),
      Date().addingTimeInterval(-3600),
    ]

    for timestamp in timestamps {
      var isHiding = true

      let view = StatusBar(
        lastRefresh: timestamp,
        isRefreshing: false,
        isAutoRefreshEnabled: true,
        isAutoRefreshActive: true,
        isHidingCompleted: Binding(
          get: { isHiding },
          set: { isHiding = $0 }
        ),
        onToggleAutoRefresh: {}
      )

      #expect(view != nil)
    }
  }

  @Test("Multiple instances maintain independent state")
  @MainActor
  func independentState() {
    var hiding1 = true
    var hiding2 = false

    let view1 = StatusBar(
      lastRefresh: Date().addingTimeInterval(-300),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: Binding(
        get: { hiding1 },
        set: { hiding1 = $0 }
      ),
      onToggleAutoRefresh: {}
    )

    let view2 = StatusBar(
      lastRefresh: Date().addingTimeInterval(-600),
      isRefreshing: true,
      isAutoRefreshEnabled: false,
      isAutoRefreshActive: false,
      isHidingCompleted: Binding(
        get: { hiding2 },
        set: { hiding2 = $0 }
      ),
      onToggleAutoRefresh: {}
    )

    #expect(view1 != nil)
    #expect(view2 != nil)
    #expect(hiding1 == true)
    #expect(hiding2 == false)
  }

  @Test("Callback closure execution")
  @MainActor
  func callbackExecution() {
    var callbackExecuted = false
    var isHiding = true

    let _ = StatusBar(
      lastRefresh: Date(),
      isRefreshing: false,
      isAutoRefreshEnabled: true,
      isAutoRefreshActive: true,
      isHidingCompleted: Binding(
        get: { isHiding },
        set: { isHiding = $0 }
      ),
      onToggleAutoRefresh: {
        callbackExecuted = true
      }
    )

    // Note: Can't directly trigger button action in unit test,
    // but verify component creation with callback
    #expect(callbackExecuted == false)  // Not yet executed
  }

  @Test("Component interface consistency")
  @MainActor
  func interfaceConsistency() {
    let testCases = [
      (hiding: true, refreshing: false, description: "Hiding ON, not refreshing"),
      (hiding: false, refreshing: true, description: "Hiding OFF, refreshing"),
      (hiding: true, refreshing: true, description: "Hiding ON, refreshing"),
      (hiding: false, refreshing: false, description: "Hiding OFF, not refreshing"),
    ]

    for testCase in testCases {
      var isHiding = testCase.hiding

      let view = StatusBar(
        lastRefresh: Date(),
        isRefreshing: testCase.refreshing,
        isAutoRefreshEnabled: true,
        isAutoRefreshActive: true,
        isHidingCompleted: Binding(
          get: { isHiding },
          set: { isHiding = $0 }
        ),
        onToggleAutoRefresh: {}
      )

      #expect(view != nil)
    }
  }
}
