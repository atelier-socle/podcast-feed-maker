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

/// Validates a ``PodcastFeed`` against platform-specific requirements.
///
/// `FeedValidator` is the primary public API for feed validation. It checks
/// feeds against the rules of one or more podcast platforms and returns
/// structured results with severity levels.
///
/// ## Supported Platforms
///
/// - ``ValidationPlatform/apple`` — Apple Podcasts
/// - ``ValidationPlatform/spotify`` — Spotify
/// - ``ValidationPlatform/amazon`` — Amazon Music / Audible
/// - ``ValidationPlatform/podcastIndex`` — Podcast Index
/// - ``ValidationPlatform/psp1`` — Podcast Standards Project v1
///
/// ## Usage
///
/// ```swift
/// let validator = FeedValidator()
/// let report = validator.validate(feed, for: .apple)
/// if report.isValid {
///     print("Feed passes Apple Podcasts validation")
/// } else {
///     for error in report.errors {
///         print("ERROR: \(error.field) — \(error.message)")
///     }
/// }
/// ```
///
/// ## Custom Rules
///
/// Extend validation by implementing ``ValidationRule``:
///
/// ```swift
/// let results = validator.validate(feed, rules: [MyCustomRule()])
/// ```
public struct FeedValidator: Sendable {

    /// Creates a new feed validator.
    public init() {}

    // MARK: - Single Platform

    /// Validates a feed against a single platform.
    ///
    /// Cross-cutting checks (GUID uniqueness, URL format, etc.) are
    /// always included in addition to platform-specific rules.
    ///
    /// - Parameters:
    ///   - feed: The feed to validate.
    ///   - platform: The target platform.
    /// - Returns: A ``ValidationReport`` for the platform.
    public func validate(
        _ feed: PodcastFeed, for platform: ValidationPlatform
    ) -> ValidationReport {
        let platformResults = platformValidation(feed, for: platform)
        let crossCuttingResults = CrossCuttingValidation.validate(feed)
        let allResults = platformResults + crossCuttingResults
        return ValidationReport(platform: platform, results: allResults)
    }

    // MARK: - Multiple Platforms

    /// Validates a feed against multiple platforms.
    ///
    /// - Parameters:
    ///   - feed: The feed to validate.
    ///   - platforms: The target platforms.
    /// - Returns: An array of ``ValidationReport``, one per platform.
    public func validate(
        _ feed: PodcastFeed, for platforms: [ValidationPlatform]
    ) -> [ValidationReport] {
        platforms.map { validate(feed, for: $0) }
    }

    // MARK: - All Platforms

    /// Validates a feed against all supported platforms.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: An array of ``ValidationReport``, one per platform.
    public func validateAll(
        _ feed: PodcastFeed
    ) -> [ValidationReport] {
        validate(feed, for: ValidationPlatform.allCases)
    }

    // MARK: - Custom Rules

    /// Validates a feed using custom rules.
    ///
    /// - Parameters:
    ///   - feed: The feed to validate.
    ///   - rules: The custom validation rules to apply.
    /// - Returns: Combined results from all rules.
    public func validate(
        _ feed: PodcastFeed, rules: [any ValidationRule]
    ) -> [ValidationResult] {
        rules.flatMap { $0.validate(feed) }
            .sorted { $0.severity > $1.severity }
    }

    // MARK: - Internal Dispatch

    private func platformValidation(
        _ feed: PodcastFeed, for platform: ValidationPlatform
    ) -> [ValidationResult] {
        switch platform {
        case .apple:
            AppleValidation.validate(feed)
        case .spotify:
            SpotifyValidation.validate(feed)
        case .amazon:
            AmazonValidation.validate(feed)
        case .podcastIndex:
            PodcastIndexValidation.validate(feed)
        case .psp1:
            PSP1Validation.validate(feed)
        }
    }
}
