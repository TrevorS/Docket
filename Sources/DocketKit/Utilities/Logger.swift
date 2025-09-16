// ABOUTME: Simple logging utility for consistent debug output and production safety
// ABOUTME: Provides level-based logging that can be disabled for release builds

import Foundation

/// Simple logging utility for structured debug output
public enum Logger {

  public enum Level: String, CaseIterable {
    case debug = "🔍"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
    case success = "✅"
  }

  /// Log a message with the specified level
  /// - Parameters:
  ///   - level: The log level
  ///   - message: The message to log
  ///   - file: Source file (automatically captured)
  ///   - function: Source function (automatically captured)
  ///   - line: Source line (automatically captured)
  public static func log(
    _ level: Level,
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    #if DEBUG
      let fileName = URL(fileURLWithPath: file).lastPathComponent
      let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(message)"
      print(logMessage)
    #endif
  }

  /// Log a debug message
  public static func debug(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    log(.debug, message, file: file, function: function, line: line)
  }

  /// Log an info message
  public static func info(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    log(.info, message, file: file, function: function, line: line)
  }

  /// Log a warning message
  public static func warning(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    log(.warning, message, file: file, function: function, line: line)
  }

  /// Log an error message
  public static func error(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    log(.error, message, file: file, function: function, line: line)
  }

  /// Log a success message
  public static func success(
    _ message: String, file: String = #file, function: String = #function, line: Int = #line
  ) {
    log(.success, message, file: file, function: function, line: line)
  }
}
