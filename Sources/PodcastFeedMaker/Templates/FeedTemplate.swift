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

/// A template defining the expected tags and namespaces for a podcast feed.
///
/// Templates describe which ``FeedTag`` values are required or recommended
/// at both channel and item levels, which ``PodcastNamespace`` values must
/// be declared, and which ``ValidationPlatform`` platforms the feed targets.
///
/// Four built-in templates are available via static accessors:
/// ``basic``, ``standard``, ``advanced``, and ``expert``.
///
/// - SeeAlso: ``TemplateValidator``, ``ExpertiseLevel``
public protocol FeedTemplate: Sendable {

    /// The expertise level this template represents.
    var level: ExpertiseLevel { get }

    /// A short human-readable name for the template.
    var name: String { get }

    /// Tags that must be present at the channel level.
    var requiredChannelTags: Set<FeedTag> { get }

    /// Tags that should be present at the channel level for best results.
    var recommendedChannelTags: Set<FeedTag> { get }

    /// Tags that must be present at the item level.
    var requiredItemTags: Set<FeedTag> { get }

    /// Tags that should be present at the item level for best results.
    var recommendedItemTags: Set<FeedTag> { get }

    /// The XML namespaces this template uses.
    var namespaces: Set<PodcastNamespace> { get }

    /// The platform preset this template targets.
    var platformPreset: PlatformPreset { get }
}

// MARK: - Static Accessors

extension FeedTemplate where Self == BasicTemplate {

    /// A basic template for minimal iTunes feeds (Apple + Spotify).
    public static var basic: BasicTemplate { BasicTemplate() }
}

extension FeedTemplate where Self == StandardTemplate {

    /// A standard template for PSP-1 compliant feeds.
    public static var standard: StandardTemplate { StandardTemplate() }
}

extension FeedTemplate where Self == AdvancedTemplate {

    /// An advanced template with Podcast NS 2.0 phases 1-3.
    public static var advanced: AdvancedTemplate { AdvancedTemplate() }
}

extension FeedTemplate where Self == ExpertTemplate {

    /// An expert template with full 7-namespace coverage.
    public static var expert: ExpertTemplate { ExpertTemplate() }
}

// MARK: - Convenience

extension FeedTemplate {

    /// All tags (required + recommended) at both channel and item levels.
    public var allTags: Set<FeedTag> {
        requiredChannelTags
            .union(recommendedChannelTags)
            .union(requiredItemTags)
            .union(recommendedItemTags)
    }
}
