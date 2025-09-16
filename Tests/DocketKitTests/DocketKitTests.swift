// ABOUTME: Unit tests for DocketKit core business logic
// ABOUTME: Tests models, managers, and utilities using Swift Testing framework

import Testing

@testable import DocketKit

struct DocketKitTests {

  @Test("ContentView can be created")
  @MainActor
  func contentViewCreation() async throws {
    _ = ContentView()
    // ContentView is a value type, so this test just verifies it compiles
    #expect(Bool(true))
  }

  // Note: Core functionality tests are implemented in separate test files:
  // - Meeting model tests: MeetingTests.swift
  // - CalendarManager tests: CalendarManagerTests.swift
  // - MeetingURLExtractor tests: MeetingURLExtractorTests.swift
  // - AppModel tests: AppModelTests.swift
}
