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

import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Audits a podcast feed and produces a quality report with scoring.
struct AuditCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "audit",
        abstract: "Audit a podcast feed for quality, compliance, and discoverability."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Option(name: .shortAndLong, help: "Output format: text, json.")
    var format: String = "text"

    @Option(name: .long, help: "Minimum score (0-100). Exit code 1 if score is below.")
    var minScore: Int?

    @Option(name: .long, help: "Compare with another feed and show evolution.")
    var compare: String?

    @Option(name: .long, help: "Show details for a specific category only.")
    var category: String?

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let auditor = FeedAuditor()

        if let compareSource = compare {
            try runComparison(auditor: auditor, feed: feed, compareSource: compareSource)
        } else {
            try runAudit(auditor: auditor, feed: feed)
        }
    }

    private func runAudit(auditor: FeedAuditor, feed: PodcastFeed) throws {
        let report = auditor.audit(feed)

        if format == "json" {
            let json = try OutputFormatter.jsonString(report)
            print(json)
        } else {
            printTextReport(report)
        }

        if let threshold = minScore, report.score < threshold {
            throw ExitCode(rawValue: ExitCodes.error)
        }
    }

    private func runComparison(
        auditor: FeedAuditor, feed: PodcastFeed, compareSource: String
    ) throws {
        let compareFeed = try FeedLoader.load(from: compareSource)
        let comparison = auditor.compare(before: feed, after: compareFeed)

        if format == "json" {
            let json = try OutputFormatter.jsonString(comparison)
            print(json)
        } else {
            printComparisonReport(comparison)
        }
    }
}

// MARK: - Text Report Output

extension AuditCommand {

    private func printTextReport(_ report: AuditReport) {
        let title = report.feedTitle ?? "(untitled)"
        printHeader(title: title, score: report.score, grade: report.grade)
        printCategoryScores(report.categoryScores)
        printCompatibility(report.compatibility)
        printRecommendations(report.recommendations)
    }

    private func printHeader(title: String, score: Int, grade: AuditGrade) {
        print(ColorOutput.bold("Feed Audit Report"))
        print(ColorOutput.bold("\"\(title)\""))
        let scoreText = "Score: \(score)/100 (\(grade.rawValue))"
        if score >= 90 {
            print(ColorOutput.success(scoreText))
        } else if score >= 60 {
            print(ColorOutput.warning(scoreText))
        } else {
            print(ColorOutput.error(scoreText))
        }
        print("")
    }

    private func printCategoryScores(_ scores: [AuditCategoryScore]) {
        let filtered: [AuditCategoryScore]
        if let cat = category {
            filtered = scores.filter { $0.category.rawValue == cat }
        } else {
            filtered = scores
        }

        print(ColorOutput.bold("Category Scores:"))
        for score in filtered {
            let name = OutputFormatter.pad(score.category.displayName + ":", to: 18)
            let points = "\(score.earned)/\(score.maximum)"
            let pct = "(\(score.percentage)%)"
            let bar = progressBar(score.percentage)
            print("  \(name) \(OutputFormatter.pad(points, to: 6)) \(OutputFormatter.pad(pct, to: 6)) \(bar)")
        }
        print("")
    }

    private func printCompatibility(_ results: [PlatformCompatibilityResult]) {
        print(ColorOutput.bold("Platform Compatibility:"))
        for result in results {
            let name = OutputFormatter.pad(result.platform, to: 18)
            let status: String
            switch result.status {
            case .ok:
                status = ColorOutput.success("OK")
            case .warnings:
                status = ColorOutput.warning("\(result.warningCount) warning(s)")
            case .incompatible:
                status = ColorOutput.error("\(result.errorCount) error(s)")
            }
            print("  \(name) \(status)")
        }
        print("")
    }

    private func printRecommendations(_ recommendations: [AuditRecommendation]) {
        guard !recommendations.isEmpty else {
            print(ColorOutput.success("No recommendations — excellent feed!"))
            return
        }

        print(ColorOutput.bold("Recommendations (\(recommendations.count)):"))
        print("")

        let critical = recommendations.filter { $0.priority == .critical }
        let recommended = recommendations.filter { $0.priority == .recommended }
        let niceToHave = recommendations.filter { $0.priority == .niceToHave }

        printPriorityGroup("CRITICAL", items: critical, color: ColorOutput.error)
        printPriorityGroup("RECOMMENDED", items: recommended, color: ColorOutput.warning)
        printPriorityGroup("NICE TO HAVE", items: niceToHave, color: ColorOutput.info)
    }

    private func printPriorityGroup(
        _ label: String,
        items: [AuditRecommendation],
        color: (String) -> String
    ) {
        guard !items.isEmpty else { return }
        print("  \(color(label)) (\(items.count)):")
        for (idx, rec) in items.enumerated() {
            print("  \(idx + 1). \(rec.message)")
            let impact = "+\(rec.potentialPoints) points (\(rec.category.displayName))"
            print("     \(ColorOutput.dim(impact))")
        }
        print("")
    }

    private func progressBar(_ percentage: Int) -> String {
        let filled = percentage / 10
        let empty = 10 - filled
        return String(repeating: "#", count: filled) + String(repeating: ".", count: empty)
    }
}

// MARK: - Comparison Report Output

extension AuditCommand {

    private func printComparisonReport(_ comparison: AuditComparison) {
        let deltaStr =
            comparison.scoreDelta >= 0
            ? "+\(comparison.scoreDelta)" : "\(comparison.scoreDelta)"
        let evolution = "\(comparison.beforeScore) -> \(comparison.afterScore) (\(deltaStr))"
        let gradeEvolution = "\(comparison.beforeGrade.rawValue) -> \(comparison.afterGrade.rawValue)"

        print(ColorOutput.bold("Score Evolution: \(evolution) — \(gradeEvolution)"))
        print("")

        let changed = comparison.categoryDeltas.filter { $0.delta != 0 }
        if !changed.isEmpty {
            print("  Category Changes:")
            for delta in changed {
                let name = OutputFormatter.pad(delta.category.displayName + ":", to: 18)
                let sign = delta.delta >= 0 ? "+" : ""
                print("    \(name) \(delta.beforeScore) -> \(delta.afterScore) (\(sign)\(delta.delta))")
            }
            print("")
        }

        if !comparison.resolvedRecommendations.isEmpty {
            print(ColorOutput.success("  Resolved (\(comparison.resolvedRecommendations.count)):"))
            for rec in comparison.resolvedRecommendations {
                print("    - \(rec.message)")
            }
            print("")
        }

        if !comparison.newRecommendations.isEmpty {
            print(ColorOutput.warning("  New (\(comparison.newRecommendations.count)):"))
            for rec in comparison.newRecommendations {
                print("    - \(rec.message)")
            }
            print("")
        }
    }
}
