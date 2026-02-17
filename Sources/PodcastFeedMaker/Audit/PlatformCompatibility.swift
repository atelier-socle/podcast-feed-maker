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
