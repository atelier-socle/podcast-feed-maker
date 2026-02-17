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

// MARK: - Snapshot Helper

extension FeedTemplate {

    /// Converts this template to a ``ComposedTemplate`` for modification.
    ///
    /// Used internally by fluent builder methods to create a mutable copy
    /// of any `FeedTemplate` conforming type.
    internal func toComposed() -> ComposedTemplate {
        ComposedTemplate(
            name: name,
            level: level,
            platformPreset: platformPreset,
            requiredChannelTags: requiredChannelTags,
            recommendedChannelTags: recommendedChannelTags,
            requiredItemTags: requiredItemTags,
            recommendedItemTags: recommendedItemTags,
            namespaces: namespaces
        )
    }
}

// MARK: - Fluent Builder Methods

extension FeedTemplate {

    /// Returns a new template with additional required channel tags.
    ///
    /// ```swift
    /// let enhanced = StandardTemplate()
    ///     .requiring(.podcastTranscript, .podcastPerson)
    /// ```
    ///
    /// - Parameter tags: The tags to add to the required channel set.
    /// - Returns: A composed template with the additional requirements.
    public func requiring(_ tags: FeedTag...) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: base.name,
            level: base.level,
            platformPreset: base.platformPreset,
            requiredChannelTags: base.requiredChannelTags.union(tags),
            recommendedChannelTags: base.recommendedChannelTags,
            requiredItemTags: base.requiredItemTags,
            recommendedItemTags: base.recommendedItemTags,
            namespaces: base.namespaces
        )
    }

    /// Returns a new template with additional recommended channel tags.
    ///
    /// - Parameter tags: The tags to add to the recommended channel set.
    /// - Returns: A composed template with the additional recommendations.
    public func recommending(_ tags: FeedTag...) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: base.name,
            level: base.level,
            platformPreset: base.platformPreset,
            requiredChannelTags: base.requiredChannelTags,
            recommendedChannelTags: base.recommendedChannelTags.union(tags),
            requiredItemTags: base.requiredItemTags,
            recommendedItemTags: base.recommendedItemTags,
            namespaces: base.namespaces
        )
    }

    /// Returns a new template with additional required item tags.
    ///
    /// ```swift
    /// let strict = BasicTemplate()
    ///     .requiringItems(.itemGuid, .itemPubDate)
    /// ```
    ///
    /// - Parameter tags: The tags to add to the required item set.
    /// - Returns: A composed template with the additional item requirements.
    public func requiringItems(_ tags: FeedTag...) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: base.name,
            level: base.level,
            platformPreset: base.platformPreset,
            requiredChannelTags: base.requiredChannelTags,
            recommendedChannelTags: base.recommendedChannelTags,
            requiredItemTags: base.requiredItemTags.union(tags),
            recommendedItemTags: base.recommendedItemTags,
            namespaces: base.namespaces
        )
    }

    /// Returns a new template with additional recommended item tags.
    ///
    /// - Parameter tags: The tags to add to the recommended item set.
    /// - Returns: A composed template with the additional item recommendations.
    public func recommendingItems(_ tags: FeedTag...) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: base.name,
            level: base.level,
            platformPreset: base.platformPreset,
            requiredChannelTags: base.requiredChannelTags,
            recommendedChannelTags: base.recommendedChannelTags,
            requiredItemTags: base.requiredItemTags,
            recommendedItemTags: base.recommendedItemTags.union(tags),
            namespaces: base.namespaces
        )
    }

    /// Returns a new template targeting the specified platform preset.
    ///
    /// ```swift
    /// let template = StandardTemplate()
    ///     .targeting(.universal)
    /// ```
    ///
    /// - Parameter preset: The platform preset to target.
    /// - Returns: A composed template with the overridden platforms.
    public func targeting(_ preset: PlatformPreset) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: base.name,
            level: base.level,
            platformPreset: preset,
            requiredChannelTags: base.requiredChannelTags,
            recommendedChannelTags: base.recommendedChannelTags,
            requiredItemTags: base.requiredItemTags,
            recommendedItemTags: base.recommendedItemTags,
            namespaces: base.namespaces
        )
    }

    /// Returns a new template targeting the specified platforms.
    ///
    /// ```swift
    /// let template = StandardTemplate()
    ///     .targeting(.apple, .spotify, .podcastIndex)
    /// ```
    ///
    /// - Parameter platforms: The individual platforms to target.
    /// - Returns: A composed template with the overridden platforms.
    public func targeting(_ platforms: ValidationPlatform...) -> ComposedTemplate {
        targeting(.custom(Set(platforms)))
    }

    /// Returns a new template with the specified name.
    ///
    /// ```swift
    /// let template = StandardTemplate()
    ///     .requiring(.podcastTranscript)
    ///     .named("Network Standard")
    /// ```
    ///
    /// - Parameter name: The new name for the template.
    /// - Returns: A composed template with the overridden name.
    public func named(_ name: String) -> ComposedTemplate {
        let base = toComposed()
        return ComposedTemplate(
            name: name,
            level: base.level,
            platformPreset: base.platformPreset,
            requiredChannelTags: base.requiredChannelTags,
            recommendedChannelTags: base.recommendedChannelTags,
            requiredItemTags: base.requiredItemTags,
            recommendedItemTags: base.recommendedItemTags,
            namespaces: base.namespaces
        )
    }
}
