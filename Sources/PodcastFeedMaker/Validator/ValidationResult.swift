import Foundation

// MARK: - ValidationResult

/// A single validation finding produced by the ``FeedValidator``.
///
/// Each result identifies the severity, the affected field, a human-readable
/// message, and optionally the platform whose rule was violated.
public struct ValidationResult: Sendable, Hashable, Equatable {

    /// The severity of this finding.
    public let severity: ValidationSeverity

    /// A human-readable description of the issue.
    public let message: String

    /// A dot-path identifying the affected field (e.g., `"channel.title"`,
    /// `"channel.items[0].enclosure.url"`).
    public let field: String

    /// The platform whose rule produced this result, or `nil` for
    /// cross-cutting (universal) checks.
    public let platform: ValidationPlatform?

    /// Creates a new validation result.
    ///
    /// - Parameters:
    ///   - severity: The severity level.
    ///   - message: A human-readable description.
    ///   - field: The dot-path to the affected field.
    ///   - platform: The platform, or `nil` for universal rules.
    public init(
        severity: ValidationSeverity,
        message: String,
        field: String,
        platform: ValidationPlatform? = nil
    ) {
        self.severity = severity
        self.message = message
        self.field = field
        self.platform = platform
    }
}

// MARK: - ValidationReport

/// A summary of validation findings for a single platform.
///
/// Use ``isValid`` to quickly check whether the feed passed validation
/// (no errors). Warnings and info results do not affect validity.
public struct ValidationReport: Sendable, Equatable {

    /// The platform these results apply to.
    public let platform: ValidationPlatform

    /// All results sorted by severity (errors first, then warnings, then info).
    public let results: [ValidationResult]

    /// Creates a new validation report.
    ///
    /// Results are automatically sorted by severity (errors first).
    ///
    /// - Parameters:
    ///   - platform: The target platform.
    ///   - results: The validation findings.
    public init(platform: ValidationPlatform, results: [ValidationResult]) {
        self.platform = platform
        self.results = results.sorted { $0.severity > $1.severity }
    }

    /// All results with severity ``ValidationSeverity/error``.
    public var errors: [ValidationResult] {
        results.filter { $0.severity == .error }
    }

    /// All results with severity ``ValidationSeverity/warning``.
    public var warnings: [ValidationResult] {
        results.filter { $0.severity == .warning }
    }

    /// All results with severity ``ValidationSeverity/info``.
    public var infos: [ValidationResult] {
        results.filter { $0.severity == .info }
    }

    /// Whether the feed passed validation (no errors).
    ///
    /// A feed is considered valid if there are no error-level results.
    /// Warnings and info results do not affect validity.
    public var isValid: Bool {
        errors.isEmpty
    }
}
