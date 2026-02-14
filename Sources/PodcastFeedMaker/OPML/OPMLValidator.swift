import Foundation

/// Validates an ``OPMLDocument`` for conformity and best practices.
///
/// `OPMLValidator` checks the structure of an OPML document against
/// the OPML 2.0 specification and common podcast subscription patterns.
/// It produces an ``OPMLValidationReport`` with findings at error or
/// warning severity.
///
/// ## Usage
///
/// ```swift
/// let validator = OPMLValidator()
/// let report = validator.validate(document)
/// if report.isValid {
///     print("OPML is valid")
/// }
/// ```
///
/// - SeeAlso: ``OPMLDocument``, ``OPMLValidationReport``
public struct OPMLValidator: Sendable {

    /// Creates a new OPML validator.
    public init() {}

    /// Validates an OPML document.
    ///
    /// - Parameter document: The document to validate.
    /// - Returns: A validation report with all findings.
    public func validate(_ document: OPMLDocument) -> OPMLValidationReport {
        var issues: [OPMLValidationIssue] = []

        issues += validateVersion(document)
        issues += validateHead(document)
        issues += validateOutlines(document)
        issues += validateDuplicates(document)

        return OPMLValidationReport(issues: issues)
    }

    // MARK: - Version Checks

    private func validateVersion(
        _ document: OPMLDocument
    ) -> [OPMLValidationIssue] {
        var issues: [OPMLValidationIssue] = []

        let validVersions = ["1.0", "1.1", "2.0"]
        if !validVersions.contains(document.version) {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Unrecognized OPML version '\(document.version)'. Expected 1.0, 1.1, or 2.0.",
                    field: "opml.version"
                ))
        }

        return issues
    }

    // MARK: - Head Checks

    private func validateHead(
        _ document: OPMLDocument
    ) -> [OPMLValidationIssue] {
        var issues: [OPMLValidationIssue] = []

        if document.head == nil {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Missing <head> section. Title and owner metadata recommended.",
                    field: "opml.head"
                ))
        } else if document.head?.title == nil {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Missing <title> in <head>. Recommended for user display.",
                    field: "opml.head.title"
                ))
        }

        return issues
    }

    // MARK: - Outline Checks

    private func validateOutlines(
        _ document: OPMLDocument
    ) -> [OPMLValidationIssue] {
        var issues: [OPMLValidationIssue] = []

        if document.outlines.isEmpty {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Document has no outlines.",
                    field: "opml.body"
                ))
        }

        for (index, outline) in document.outlines.enumerated() {
            issues += validateOutline(outline, path: "outlines[\(index)]")
        }

        return issues
    }

    private func validateOutline(
        _ outline: OPMLOutline, path: String
    ) -> [OPMLValidationIssue] {
        var issues: [OPMLValidationIssue] = []

        // Empty text
        if outline.text.isEmpty {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Outline has empty text attribute.",
                    field: path
                ))
        }

        // RSS type without xmlUrl
        if outline.type?.lowercased() == "rss" && outline.xmlUrl == nil {
            issues.append(
                OPMLValidationIssue(
                    severity: .error,
                    message: "RSS outline missing xmlUrl attribute.",
                    field: "\(path).xmlUrl"
                ))
        }

        // xmlUrl without type=rss
        if outline.xmlUrl != nil && outline.type == nil {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Outline has xmlUrl but no type attribute. Consider adding type=\"rss\".",
                    field: "\(path).type"
                ))
        }

        // Non-HTTPS feed URL
        if let xmlUrl = outline.xmlUrl, xmlUrl.scheme == "http" {
            issues.append(
                OPMLValidationIssue(
                    severity: .warning,
                    message: "Feed URL uses HTTP. HTTPS recommended: \(xmlUrl.absoluteString)",
                    field: "\(path).xmlUrl"
                ))
        }

        // Recurse into children
        for (index, child) in outline.children.enumerated() {
            issues += validateOutline(child, path: "\(path).children[\(index)]")
        }

        return issues
    }

    // MARK: - Duplicate Checks

    private func validateDuplicates(
        _ document: OPMLDocument
    ) -> [OPMLValidationIssue] {
        var issues: [OPMLValidationIssue] = []

        let feeds = document.podcastFeeds
        var seenURLs: Set<String> = []

        for feed in feeds {
            guard let url = feed.xmlUrl?.absoluteString else { continue }
            if seenURLs.contains(url) {
                issues.append(
                    OPMLValidationIssue(
                        severity: .warning,
                        message: "Duplicate feed URL: \(url)",
                        field: "outlines.xmlUrl"
                    ))
            } else {
                seenURLs.insert(url)
            }
        }

        return issues
    }
}

// MARK: - OPMLValidationIssue

/// A single finding from OPML validation.
public struct OPMLValidationIssue: Sendable, Hashable, Equatable {

    /// The severity of this issue.
    public let severity: OPMLValidationSeverity

    /// A human-readable description of the issue.
    public let message: String

    /// A dot-path identifying the affected field.
    public let field: String

    /// Creates a new validation issue.
    ///
    /// - Parameters:
    ///   - severity: The severity level.
    ///   - message: A human-readable description.
    ///   - field: The dot-path to the affected field.
    public init(
        severity: OPMLValidationSeverity,
        message: String,
        field: String
    ) {
        self.severity = severity
        self.message = message
        self.field = field
    }
}

// MARK: - OPMLValidationSeverity

/// Severity levels for OPML validation issues.
public enum OPMLValidationSeverity: Comparable, Sendable, Hashable {
    /// The document fails validation.
    case error
    /// The document is suboptimal but usable.
    case warning
}

// MARK: - OPMLValidationReport

/// A summary of OPML validation findings.
public struct OPMLValidationReport: Sendable, Equatable {

    /// All issues sorted by severity (errors first).
    public let issues: [OPMLValidationIssue]

    /// Creates a new validation report.
    ///
    /// Issues are automatically sorted by severity (errors first).
    ///
    /// - Parameter issues: The validation findings.
    public init(issues: [OPMLValidationIssue]) {
        self.issues = issues.sorted { $0.severity > $1.severity }
    }

    /// All issues with severity ``OPMLValidationSeverity/error``.
    public var errors: [OPMLValidationIssue] {
        issues.filter { $0.severity == .error }
    }

    /// All issues with severity ``OPMLValidationSeverity/warning``.
    public var warnings: [OPMLValidationIssue] {
        issues.filter { $0.severity == .warning }
    }

    /// Whether the document passed validation (no errors).
    public var isValid: Bool {
        errors.isEmpty
    }
}
