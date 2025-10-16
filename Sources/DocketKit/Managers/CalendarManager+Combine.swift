// ABOUTME: Combine extension for CalendarManager
// ABOUTME: Provides Combine publishers for @Observable properties
// ABOUTME: Enables AppKit view controllers to observe data changes

import Combine
import Foundation

extension CalendarManager {
  /// Publisher for meetings array changes
  func meetingsPublisher() -> AnyPublisher<[Meeting], Never> {
    NotificationCenter.default
      .publisher(for: Notification.Name("CalendarManagerMeetingsDidChange"))
      .map { _ in self.meetings }
      .prepend(self.meetings)
      .eraseToAnyPublisher()
  }

  /// Publisher for auth state changes
  func authStatePublisher() -> AnyPublisher<CalendarAuthState, Never> {
    NotificationCenter.default
      .publisher(for: Notification.Name("CalendarManagerAuthStateDidChange"))
      .map { _ in self.authState }
      .prepend(self.authState)
      .eraseToAnyPublisher()
  }

  /// Publisher for isRefreshing state changes
  func isRefreshingPublisher() -> AnyPublisher<Bool, Never> {
    NotificationCenter.default
      .publisher(for: Notification.Name("CalendarManagerRefreshingDidChange"))
      .map { _ in self.isRefreshing }
      .prepend(self.isRefreshing)
      .eraseToAnyPublisher()
  }

  /// Internal: Notify observers of meetings change
  internal func notifyMeetingsChanged() {
    NotificationCenter.default.post(
      name: Notification.Name("CalendarManagerMeetingsDidChange"), object: nil)
  }

  /// Internal: Notify observers of auth state change
  internal func notifyAuthStateChanged() {
    NotificationCenter.default.post(
      name: Notification.Name("CalendarManagerAuthStateDidChange"), object: nil)
  }

  /// Internal: Notify observers of refresh state change
  internal func notifyRefreshingChanged() {
    NotificationCenter.default.post(
      name: Notification.Name("CalendarManagerRefreshingDidChange"), object: nil)
  }
}
