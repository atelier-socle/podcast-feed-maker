// MARK: - PlatformCompatibilityResult

/// Compatibility result for a single platform.
public struct PlatformCompatibilityResult: Sendable, Equatable, Codable {
    /// Platform name (e.g., "Apple Podcasts", "Spotify").
    public var platform: String

    /// Whether the feed is compatible.
    public var isCompatible: Bool

    /// Number of errors (blocks distribution).
    public var errorCount: Int

    /// Number of warnings (may cause issues).
    public var warningCount: Int

    /// Compatibility status for display.
    public var status: CompatibilityStatus

    /// Creates a new compatibility result.
    public init(
        platform: String,
        isCompatible: Bool,
        errorCount: Int,
        warningCount: Int,
        status: CompatibilityStatus
    ) {
        self.platform = platform
        self.isCompatible = isCompatible
        self.errorCount = errorCount
        self.warningCount = warningCount
        self.status = status
    }

    /// Compatibility status levels.
    public enum CompatibilityStatus: String, Sendable, Equatable, Codable {
        /// Fully compatible.
        case ok
        /// Compatible with warnings.
        case warnings
        /// Not compatible.
        case incompatible
    }
}
