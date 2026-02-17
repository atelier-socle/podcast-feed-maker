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

/// Represents a single difference between two podcast feeds.
///
/// Each difference captures the type of change (added, removed, or modified),
/// the dot-path to the affected field, and the old/new values as strings.
///
/// Example:
/// ```swift
/// // FeedDifference(changeType: .modified, field: "channel.title",
/// //     oldValue: "Old Title", newValue: "New Title")
/// ```
///
/// - SeeAlso: ``FeedDiff``
public struct FeedDifference: Sendable, Equatable {

    /// The type of change detected.
    public enum ChangeType: Sendable, Equatable {
        /// A field or item was added (not present in the left-hand feed).
        case added
        /// A field or item was removed (not present in the right-hand feed).
        case removed
        /// A field was modified (different values in both feeds).
        case modified
    }

    /// The type of change.
    public let changeType: ChangeType

    /// The dot-path to the affected field (e.g., `"channel.title"`, `"items[0].guid"`).
    public let field: String

    /// The previous value, or `nil` for `.added` changes.
    public let oldValue: String?

    /// The new value, or `nil` for `.removed` changes.
    public let newValue: String?

    /// Creates a new feed difference.
    ///
    /// - Parameters:
    ///   - changeType: The type of change.
    ///   - field: The dot-path to the affected field.
    ///   - oldValue: The previous value.
    ///   - newValue: The new value.
    public init(
        changeType: ChangeType,
        field: String,
        oldValue: String? = nil,
        newValue: String? = nil
    ) {
        self.changeType = changeType
        self.field = field
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

/// Compares two podcast feeds and produces a list of differences.
///
/// `FeedDiff` detects changes to channel metadata, added/removed items
/// (matched by GUID or title), and modified fields within matched items.
///
/// Example:
/// ```swift
/// let diff = FeedDiff()
/// let differences = diff.diff(oldFeed, newFeed)
/// for d in differences {
///     print("\(d.changeType): \(d.field)")
/// }
/// ```
///
/// - SeeAlso: ``FeedDifference``, ``PodcastFeedEngine``
public struct FeedDiff: Sendable {

    /// Creates a new feed diff engine.
    public init() {}

    /// Compares two feed models and returns detailed differences.
    ///
    /// - Parameters:
    ///   - lhs: The original (left-hand) feed.
    ///   - rhs: The updated (right-hand) feed.
    /// - Returns: An array of ``FeedDifference`` values describing all detected changes.
    public func diff(
        _ lhs: PodcastFeed, _ rhs: PodcastFeed
    ) -> [FeedDifference] {
        var results: [FeedDifference] = []

        guard let lhsChannel = lhs.channel,
            let rhsChannel = rhs.channel
        else {
            if lhs.channel == nil, rhs.channel != nil {
                results.append(FeedDifference(changeType: .added, field: "channel"))
            } else if lhs.channel != nil, rhs.channel == nil {
                results.append(FeedDifference(changeType: .removed, field: "channel"))
            }
            return results
        }

        diffChannel(lhsChannel, rhsChannel, into: &results)
        diffItems(lhsChannel.items, rhsChannel.items, into: &results)

        return results
    }

    /// Compares two XML feed strings by parsing them first.
    ///
    /// - Parameters:
    ///   - lhs: The original XML string.
    ///   - rhs: The updated XML string.
    /// - Returns: An array of ``FeedDifference`` values.
    /// - Throws: ``ParserError`` if either string cannot be parsed.
    public func diff(
        xml lhs: String, xml rhs: String
    ) throws -> [FeedDifference] {
        let parser = FeedParser()
        let lhsFeed = try parser.parse(lhs)
        let rhsFeed = try parser.parse(rhs)
        return diff(lhsFeed, rhsFeed)
    }

    // MARK: - Channel Diff

    private func diffChannel(
        _ lhs: Channel, _ rhs: Channel,
        into results: inout [FeedDifference]
    ) {
        compareField("channel.title", lhs.title, rhs.title, into: &results)
        compareField(
            "channel.link",
            lhs.link.absoluteString,
            rhs.link.absoluteString,
            into: &results
        )
        compareField("channel.description", lhs.description, rhs.description, into: &results)
        compareOptional("channel.language", lhs.language, rhs.language, into: &results)
        compareOptional("channel.copyright", lhs.copyright, rhs.copyright, into: &results)
        compareOptional("channel.itunesAuthor", lhs.itunesAuthor, rhs.itunesAuthor, into: &results)

        let lhsCats = lhs.itunesCategories.map(\.text).joined(separator: ", ")
        let rhsCats = rhs.itunesCategories.map(\.text).joined(separator: ", ")
        if lhsCats != rhsCats {
            compareField("channel.itunesCategories", lhsCats, rhsCats, into: &results)
        }

        compareOptionalBool("channel.itunesExplicit", lhs.itunesExplicit, rhs.itunesExplicit, into: &results)
        compareOptionalURL("channel.itunesImage", lhs.itunesImage, rhs.itunesImage, into: &results)
        compareOptional("channel.itunesType", lhs.itunesType?.rawValue, rhs.itunesType?.rawValue, into: &results)
        compareOptional("channel.podcastGuid", lhs.podcastGuid?.value, rhs.podcastGuid?.value, into: &results)
        compareOptionalBool("channel.locked", lhs.locked?.isLocked, rhs.locked?.isLocked, into: &results)
    }

    // MARK: - Item Matching & Diff

    private func diffItems(
        _ lhsItems: [Item], _ rhsItems: [Item],
        into results: inout [FeedDifference]
    ) {
        let lhsKeyed = keyItems(lhsItems)
        let rhsKeyed = keyItems(rhsItems)

        let lhsKeys = lhsKeyed.map(\.key)
        let rhsKeys = rhsKeyed.map(\.key)
        let lhsKeySet = Set(lhsKeys)
        let rhsKeySet = Set(rhsKeys)

        // Removed items
        for entry in lhsKeyed where !rhsKeySet.contains(entry.key) {
            let label = entry.item.title ?? entry.key
            results.append(
                FeedDifference(
                    changeType: .removed,
                    field: "items[\(label)]",
                    oldValue: entry.key
                ))
        }

        // Added items
        for entry in rhsKeyed where !lhsKeySet.contains(entry.key) {
            let label = entry.item.title ?? entry.key
            results.append(
                FeedDifference(
                    changeType: .added,
                    field: "items[\(label)]",
                    newValue: entry.key
                ))
        }

        // Modified items
        for lhsEntry in lhsKeyed {
            guard let rhsEntry = rhsKeyed.first(where: { $0.key == lhsEntry.key }) else {
                continue
            }
            diffItem(
                lhsEntry.item, rhsEntry.item,
                key: lhsEntry.key,
                into: &results
            )
        }
    }

    private struct KeyedItem {
        let key: String
        let item: Item
    }

    private func keyItems(_ items: [Item]) -> [KeyedItem] {
        items.enumerated().map { index, item in
            let key = item.guid?.value ?? item.title ?? "item[\(index)]"
            return KeyedItem(key: key, item: item)
        }
    }

    private func diffItem(
        _ lhs: Item, _ rhs: Item,
        key: String,
        into results: inout [FeedDifference]
    ) {
        let prefix = "items[\(key)]"
        compareOptional("\(prefix).title", lhs.title, rhs.title, into: &results)
        compareOptional("\(prefix).guid", lhs.guid?.value, rhs.guid?.value, into: &results)
        compareOptionalURL(
            "\(prefix).enclosure.url",
            lhs.enclosure?.url,
            rhs.enclosure?.url,
            into: &results
        )
        compareOptionalDate("\(prefix).pubDate", lhs.pubDate, rhs.pubDate, into: &results)
        compareOptionalInt("\(prefix).itunesDuration", lhs.itunesDuration, rhs.itunesDuration, into: &results)
        compareOptional("\(prefix).description", lhs.description, rhs.description, into: &results)
        compareOptionalBool("\(prefix).itunesExplicit", lhs.itunesExplicit, rhs.itunesExplicit, into: &results)
        compareOptionalInt("\(prefix).itunesSeason", lhs.itunesSeason, rhs.itunesSeason, into: &results)
        compareOptionalInt("\(prefix).itunesEpisode", lhs.itunesEpisode, rhs.itunesEpisode, into: &results)
        compareOptional(
            "\(prefix).itunesEpisodeType",
            lhs.itunesEpisodeType?.rawValue,
            rhs.itunesEpisodeType?.rawValue,
            into: &results
        )
    }

    // MARK: - Comparison Helpers

    private func compareField(
        _ field: String, _ lhs: String, _ rhs: String,
        into results: inout [FeedDifference]
    ) {
        if lhs != rhs {
            results.append(
                FeedDifference(
                    changeType: .modified, field: field,
                    oldValue: lhs, newValue: rhs
                ))
        }
    }

    private func compareOptional(
        _ field: String, _ lhs: String?, _ rhs: String?,
        into results: inout [FeedDifference]
    ) {
        switch (lhs, rhs) {
        case (.none, .some(let new)):
            results.append(FeedDifference(changeType: .added, field: field, newValue: new))
        case (.some(let old), .none):
            results.append(FeedDifference(changeType: .removed, field: field, oldValue: old))
        case (.some(let old), .some(let new)) where old != new:
            results.append(
                FeedDifference(
                    changeType: .modified, field: field,
                    oldValue: old, newValue: new
                ))
        default:
            break
        }
    }

    private func compareOptionalBool(
        _ field: String, _ lhs: Bool?, _ rhs: Bool?,
        into results: inout [FeedDifference]
    ) {
        compareOptional(field, lhs.map { "\($0)" }, rhs.map { "\($0)" }, into: &results)
    }

    private func compareOptionalInt(
        _ field: String, _ lhs: Int?, _ rhs: Int?,
        into results: inout [FeedDifference]
    ) {
        compareOptional(field, lhs.map { "\($0)" }, rhs.map { "\($0)" }, into: &results)
    }

    private func compareOptionalURL(
        _ field: String, _ lhs: URL?, _ rhs: URL?,
        into results: inout [FeedDifference]
    ) {
        compareOptional(
            field,
            lhs?.absoluteString,
            rhs?.absoluteString,
            into: &results
        )
    }

    private func compareOptionalDate(
        _ field: String, _ lhs: Date?, _ rhs: Date?,
        into results: inout [FeedDifference]
    ) {
        switch (lhs, rhs) {
        case (.none, .some(let new)):
            results.append(
                FeedDifference(
                    changeType: .added, field: field,
                    newValue: XMLBuilder.rfc2822Date(new)
                ))
        case (.some(let old), .none):
            results.append(
                FeedDifference(
                    changeType: .removed, field: field,
                    oldValue: XMLBuilder.rfc2822Date(old)
                ))
        case (.some(let old), .some(let new)):
            if abs(old.timeIntervalSince(new)) > 1.0 {
                results.append(
                    FeedDifference(
                        changeType: .modified, field: field,
                        oldValue: XMLBuilder.rfc2822Date(old),
                        newValue: XMLBuilder.rfc2822Date(new)
                    ))
            }
        case (.none, .none):
            break
        }
    }
}
