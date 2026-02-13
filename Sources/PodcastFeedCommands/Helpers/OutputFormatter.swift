import Foundation
import PodcastFeedMaker

/// Formats CLI output in various styles.
enum OutputFormatter {

    // MARK: - Feed Summary

    /// Formats a human-readable feed summary.
    static func formatFeedSummary(_ feed: PodcastFeed, verbose: Bool = false) -> String {
        guard let channel = feed.channel else {
            return ColorOutput.warning("Feed has no channel element.")
        }

        var lines: [String] = []
        lines.append(ColorOutput.bold(channel.title))
        lines += summaryBasicFields(channel, feed: feed, verbose: verbose)
        if verbose {
            lines += summaryVerboseFields(channel)
        }

        return lines.joined(separator: "\n")
    }

    private static func summaryBasicFields(
        _ channel: Channel, feed: PodcastFeed, verbose: Bool
    ) -> [String] {
        var lines: [String] = []

        if let author = channel.itunesAuthor {
            lines.append("Author: \(author)")
        }

        let desc = channel.description
        if desc.count > 200 && !verbose {
            lines.append("Description: \(String(desc.prefix(200)))...")
        } else {
            lines.append("Description: \(desc)")
        }

        lines.append("Episodes: \(channel.items.count)")

        if !channel.itunesCategories.isEmpty {
            let cats = channel.itunesCategories.map(\.text).joined(separator: ", ")
            lines.append("Categories: \(cats)")
        }

        let ns = feed.namespaces.map(\.prefix).filter { !$0.isEmpty }.joined(separator: ", ")
        if !ns.isEmpty {
            lines.append("Namespaces: \(ns)")
        }

        if let lang = channel.language {
            lines.append("Language: \(lang)")
        }

        if let lastItem = channel.items.first {
            let date = lastItem.pubDate.map { " (\(formatDate($0)))" } ?? ""
            lines.append("Last episode: \(lastItem.title ?? "(untitled)")\(date)")
        }

        return lines
    }

    private static func summaryVerboseFields(_ channel: Channel) -> [String] {
        var lines: [String] = []
        if let image = channel.itunesImage {
            lines.append("Artwork: \(image.absoluteString)")
        }
        if let feedLink = channel.atomLinks.first(where: { $0.rel == "self" }) {
            lines.append("Feed URL: \(feedLink.href.absoluteString)")
        }
        if let guid = channel.podcastGuid {
            lines.append("GUID: \(guid.value)")
        }
        if let explicit = channel.itunesExplicit {
            lines.append("Explicit: \(explicit ? "true" : "false")")
        }
        if let type = channel.itunesType {
            lines.append("Type: \(type.rawValue)")
        }
        return lines
    }

    // MARK: - Episode Table

    /// Formats an episode table with columns.
    static func formatEpisodeTable(
        _ items: [Item],
        limit: Int? = nil,
        sort: EpisodeSort = .newest
    ) -> String {
        let sorted = sortedItems(items, by: sort)
        let displayed = limit.map { Array(sorted.prefix($0)) } ?? sorted

        guard !displayed.isEmpty else {
            return "No episodes found."
        }

        var lines: [String] = []
        let header = "\(pad("#", to: 4)) | \(pad("Title", to: 40)) | \(pad("Date", to: 12)) | \(pad("Duration", to: 8)) | Type"
        lines.append(ColorOutput.bold(header))
        lines.append(
            String(repeating: "-", count: 3) + "-+-"
                + String(repeating: "-", count: 40) + "-+-"
                + String(repeating: "-", count: 12) + "-+-"
                + String(repeating: "-", count: 8) + "-+-"
                + String(repeating: "-", count: 7))

        for (idx, item) in displayed.enumerated() {
            let num = pad("\(idx + 1)", to: 4)
            let title = truncate(item.title ?? "(untitled)", to: 40)
            let date = item.pubDate.map { formatDate($0) } ?? ""
            let duration = item.itunesDuration.map { formatDuration($0) } ?? ""
            let type = item.itunesEpisodeType?.rawValue ?? ""
            lines.append("\(num) | \(pad(title, to: 40)) | \(pad(date, to: 12)) | \(pad(duration, to: 8)) | \(type)")
        }

        if items.count > displayed.count {
            lines.append("(\(items.count) episodes total)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Validation Results

    /// Formats validation results for a platform.
    static func formatValidationReport(
        _ report: ValidationReport,
        verbose: Bool = false
    ) -> String {
        var lines: [String] = []

        let results =
            verbose
            ? report.results
            : report.results.filter { $0.severity != .info }

        for result in results {
            switch result.severity {
            case .error:
                lines.append("  \(ColorOutput.error("ERROR")): \(result.message)")
            case .warning:
                lines.append("  \(ColorOutput.warning("WARNING")): \(result.message)")
            case .info:
                lines.append("  \(ColorOutput.info("INFO")): \(result.message)")
            }
            if verbose, !result.field.isEmpty {
                lines.append("    at \(ColorOutput.dim(result.field))")
            }
        }

        let platform = report.platform.rawValue
        if report.isValid && report.warnings.isEmpty {
            lines.append(ColorOutput.success("  \(platform): 0 errors, 0 warnings"))
        } else {
            let status =
                report.isValid
                ? ColorOutput.warning("\(platform): 0 errors, \(report.warnings.count) warning(s)")
                : ColorOutput.error("\(platform): \(report.errors.count) error(s), \(report.warnings.count) warning(s)")
            lines.append("  \(status)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Diff

    /// Formats feed differences for display.
    static func formatDiff(
        _ differences: [FeedDifference],
        oldLabel: String,
        newLabel: String
    ) -> String {
        guard !differences.isEmpty else {
            return ColorOutput.success("No differences found.")
        }

        var lines: [String] = []
        lines.append(ColorOutput.bold("Feed Diff: \(oldLabel) <> \(newLabel)"))
        lines.append("")

        let (channelDiffs, itemDiffs) = partitionDiffs(differences)
        lines += formatChannelDiffs(channelDiffs)
        lines += formatItemDiffs(itemDiffs)

        let summary =
            "Summary: \(channelDiffs.count) channel change(s), "
            + "\(itemDiffs.filter { $0.changeType == .added }.count) added, "
            + "\(itemDiffs.filter { $0.changeType == .modified }.count) modified, "
            + "\(itemDiffs.filter { $0.changeType == .removed }.count) removed"
        lines.append(summary)

        return lines.joined(separator: "\n")
    }

    private static func partitionDiffs(
        _ diffs: [FeedDifference]
    ) -> (channel: [FeedDifference], items: [FeedDifference]) {
        var channel: [FeedDifference] = []
        var items: [FeedDifference] = []
        for diff in diffs {
            if diff.field.hasPrefix("channel.items") {
                items.append(diff)
            } else {
                channel.append(diff)
            }
        }
        return (channel, items)
    }

    private static func formatChannelDiffs(_ diffs: [FeedDifference]) -> [String] {
        guard !diffs.isEmpty else { return [] }
        var lines = [ColorOutput.bold("Channel:")]
        for diff in diffs {
            lines.append(formatSingleDiff(diff))
        }
        lines.append("")
        return lines
    }

    private static func formatItemDiffs(_ diffs: [FeedDifference]) -> [String] {
        guard !diffs.isEmpty else { return [] }
        var lines = [ColorOutput.bold("Episodes:")]
        for diff in diffs {
            switch diff.changeType {
            case .added:
                lines.append("  \(ColorOutput.success("+")) Added: \(diff.newValue ?? diff.field)")
            case .modified:
                lines.append("  \(ColorOutput.warning("~")) Modified: \(diff.field)")
                if let old = diff.oldValue, let new = diff.newValue {
                    lines.append("    \(truncate(old, to: 40)) -> \(truncate(new, to: 40))")
                }
            case .removed:
                lines.append("  \(ColorOutput.error("-")) Removed: \(diff.oldValue ?? diff.field)")
            }
        }
        lines.append("")
        return lines
    }

    // MARK: - Chapters

    /// Formats chapter list for display.
    static func formatChapters(_ chapters: [PodloveChapter]) -> String {
        guard !chapters.isEmpty else {
            return "No chapters found."
        }

        var lines: [String] = []
        for (idx, chapter) in chapters.enumerated() {
            let num = String(format: "%2d.", idx + 1)
            lines.append("\(num) [\(chapter.start)] \(chapter.title)")
            if let href = chapter.href {
                lines.append("    \(ColorOutput.dim(href.absoluteString))")
            }
        }
        return lines.joined(separator: "\n")
    }

    /// Formats JSON chapter list for display.
    static func formatJSONChapters(_ chapters: [JSONChapter]) -> String {
        guard !chapters.isEmpty else {
            return "No chapters found."
        }

        var lines: [String] = []
        for (idx, chapter) in chapters.enumerated() {
            let num = String(format: "%2d.", idx + 1)
            let time = formatDuration(Int(chapter.startTime))
            let title = chapter.title ?? "(untitled)"
            lines.append("\(num) [\(time)] \(title)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - JSON Encoding

    /// Encodes a Codable value as pretty-printed JSON.
    static func jsonString<T: Encodable>(_ value: T, pretty: Bool = true) throws -> String {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw OutputError.encodingFailed
        }
        return string
    }
}

// MARK: - Template Validation

extension OutputFormatter {

    /// Formats a template validation report for display.
    static func formatTemplateReport(
        _ report: TemplateValidationReport,
        verbose: Bool = false
    ) -> String {
        var lines: [String] = []

        let results =
            verbose
            ? report.results
            : report.results.filter { $0.severity != .info }

        for result in results {
            switch result.severity {
            case .error:
                lines.append("  \(ColorOutput.error("ERROR")): \(result.message)")
            case .warning:
                lines.append("  \(ColorOutput.warning("WARNING")): \(result.message)")
            case .info:
                lines.append("  \(ColorOutput.info("INFO")): \(result.message)")
            }
        }

        let level = report.level.description
        if report.isCompliant && report.warnings.isEmpty {
            lines.append(ColorOutput.success("  Template (\(level)): compliant"))
        } else {
            let parts = [
                report.errors.isEmpty ? nil : "\(report.errors.count) error(s)",
                report.warnings.isEmpty ? nil : "\(report.warnings.count) warning(s)",
                report.infos.isEmpty ? nil : "\(report.infos.count) info(s)"
            ].compactMap { $0 }
            let summary = parts.joined(separator: ", ")
            let status =
                report.isCompliant
                ? ColorOutput.warning("  Template (\(level)): \(summary)")
                : ColorOutput.error("  Template (\(level)): \(summary)")
            lines.append(status)
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: - Private Helpers

extension OutputFormatter {

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    static func truncate(_ string: String, to length: Int) -> String {
        if string.count <= length { return string }
        return String(string.prefix(length - 3)) + "..."
    }

    static func pad(_ string: String, to length: Int) -> String {
        if string.count >= length { return String(string.prefix(length)) }
        return string + String(repeating: " ", count: length - string.count)
    }

    static func formatSingleDiff(_ diff: FeedDifference) -> String {
        switch diff.changeType {
        case .added:
            return "  \(ColorOutput.success("+")) \(diff.field): \(diff.newValue ?? "")"
        case .removed:
            return "  \(ColorOutput.error("-")) \(diff.field): \(diff.oldValue ?? "")"
        case .modified:
            let old = truncate(diff.oldValue ?? "", to: 40)
            let new = truncate(diff.newValue ?? "", to: 40)
            return "  \(ColorOutput.warning("~")) \(diff.field): \"\(old)\" -> \"\(new)\""
        }
    }

    static func sortedItems(_ items: [Item], by sort: EpisodeSort) -> [Item] {
        switch sort {
        case .newest:
            return items.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
        case .oldest:
            return items.sorted { ($0.pubDate ?? .distantPast) < ($1.pubDate ?? .distantPast) }
        case .title:
            return items.sorted { ($0.title ?? "") < ($1.title ?? "") }
        }
    }
}

/// Episode sort order.
enum EpisodeSort: String, CaseIterable, Sendable {
    case newest
    case oldest
    case title
}

/// Output formatting errors.
enum OutputError: Error, CustomStringConvertible {
    case encodingFailed

    var description: String {
        switch self {
        case .encodingFailed:
            "Failed to encode output as UTF-8"
        }
    }
}
