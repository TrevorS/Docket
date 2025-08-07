// ABOUTME: URL pattern matching for different types of Zoom meeting URLs
// ABOUTME: Provides regex patterns for standard, government, protocol, and vanity Zoom URLs

import Foundation

/// Enum representing different types of Zoom URL patterns with corresponding regex patterns
public enum ZoomURLPattern: String, CaseIterable, Sendable {
    /// Standard Zoom URLs (zoom.us domain)
    case standard = "https?://[\\w.-]*zoom\\.us/[^\\s]+"
    
    /// Government Zoom URLs (zoomgov.com domain)
    case government = "https?://[\\w.-]*zoomgov\\.com/[^\\s]+"
    
    /// Zoom protocol URLs (zoommtg:// scheme)
    case `protocol` = "zoommtg://[^\\s]+"
    
    /// Vanity Zoom URLs (*.zoom.us subdomains)
    case vanity = "https?://[\\w.-]*\\.zoom\\.us/[^\\s]+"
    
    /// Compiled regex pattern for this URL type
    public var regex: NSRegularExpression? {
        try? NSRegularExpression(pattern: rawValue, options: [])
    }
}