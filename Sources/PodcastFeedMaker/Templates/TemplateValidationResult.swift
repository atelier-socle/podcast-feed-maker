// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A single finding from template validation.
///
/// Template validation checks whether a feed satisfies a template's
/// required and recommended tags. Each result identifies the severity,
/// the missing or mismatched tag, and a human-readable message.
///
/// - SeeAlso: ``TemplateValidator``, ``TemplateValidationReport``
public struct TemplateValidationResult: Sendable, Hashable, Equatable {

    /// The severity of this finding.
    public let severity: ValidationSeverity

    /// The tag that triggered this finding.
    public let tag: FeedTag

    /// A human-readable description of the issue.
    public let message: String

    /// The suggested expertise level for level-mismatch findings.
    ///
    /// Populated only for info-level results that indicate a tag belongs to
    /// a higher expertise level than the template being validated against.
    /// `nil` for error and warning results.
    public let suggestedLevel: ExpertiseLevel?

    /// Creates a new template validation result.
    ///
    /// - Parameters:
    ///   - severity: The severity level.
    ///   - tag: The related tag.
    ///   - message: A human-readable description.
    ///   - suggestedLevel: The expertise level to upgrade to, if applicable.
    public init(
        severity: ValidationSeverity,
        tag: FeedTag,
        message: String,
        suggestedLevel: ExpertiseLevel? = nil
    ) {
        self.severity = severity
        self.tag = tag
        self.message = message
        self.suggestedLevel = suggestedLevel
    }
}

// MARK: - TemplateValidationReport

/// A summary of template validation findings.
///
/// Contains all results from validating a feed against a ``FeedTemplate``,
/// with convenience accessors for errors, warnings, info, and compliance status.
///
/// - SeeAlso: ``TemplateValidator``
public struct TemplateValidationReport: Sendable, Equatable {

    /// The expertise level of the template used for validation.
    public let level: ExpertiseLevel

    /// All results sorted by severity (errors first, then warnings, then info).
    public let results: [TemplateValidationResult]

    /// Creates a new template validation report.
    ///
    /// Results are automatically sorted by severity (errors first).
    ///
    /// - Parameters:
    ///   - level: The template's expertise level.
    ///   - results: The validation findings.
    public init(level: ExpertiseLevel, results: [TemplateValidationResult]) {
        self.level = level
        self.results = results.sorted { $0.severity > $1.severity }
    }

    /// All results with severity ``ValidationSeverity/error``.
    public var errors: [TemplateValidationResult] {
        results.filter { $0.severity == .error }
    }

    /// All results with severity ``ValidationSeverity/warning``.
    public var warnings: [TemplateValidationResult] {
        results.filter { $0.severity == .warning }
    }

    /// All results with severity ``ValidationSeverity/info``.
    public var infos: [TemplateValidationResult] {
        results.filter { $0.severity == .info }
    }

    /// Whether the feed meets all required tags for the template.
    ///
    /// A feed is compliant if there are no error-level results.
    /// Warnings (missing recommended tags) and info (level mismatches)
    /// do not affect compliance.
    public var isCompliant: Bool {
        errors.isEmpty
    }
}
