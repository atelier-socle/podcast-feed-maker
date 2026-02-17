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
import Testing

@testable import PodcastFeedMaker

@Suite("TemplateValidationResult")
struct TemplateValidationResultTests {

    @Test("result stores severity, tag, and message")
    func basicProperties() {
        let result = TemplateValidationResult(
            severity: .error,
            tag: .itunesImage,
            message: "Missing artwork"
        )
        #expect(result.severity == .error)
        #expect(result.tag == .itunesImage)
        #expect(result.message == "Missing artwork")
    }

    @Test("results are Equatable")
    func equatable() {
        let a = TemplateValidationResult(severity: .error, tag: .title, message: "Missing")
        let b = TemplateValidationResult(severity: .error, tag: .title, message: "Missing")
        let c = TemplateValidationResult(severity: .warning, tag: .title, message: "Missing")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("results are Hashable")
    func hashable() {
        let a = TemplateValidationResult(severity: .error, tag: .title, message: "A")
        let b = TemplateValidationResult(severity: .error, tag: .title, message: "B")
        let set: Set<TemplateValidationResult> = [a, b]
        #expect(set.count == 2)
    }

    @Test("suggestedLevel defaults to nil")
    func suggestedLevelDefaultNil() {
        let result = TemplateValidationResult(severity: .error, tag: .title, message: "Missing")
        #expect(result.suggestedLevel == nil)
    }

    @Test("suggestedLevel can be set explicitly")
    func suggestedLevelExplicit() {
        let result = TemplateValidationResult(
            severity: .info,
            tag: .podcastValue,
            message: "Expert feature",
            suggestedLevel: .expert
        )
        #expect(result.suggestedLevel == .expert)
    }
}

@Suite("TemplateValidationReport")
struct TemplateValidationReportTests {

    @Test("report sorts results by severity descending")
    func sortOrder() {
        let results = [
            TemplateValidationResult(severity: .info, tag: .podcastValue, message: "Info"),
            TemplateValidationResult(severity: .error, tag: .title, message: "Error"),
            TemplateValidationResult(severity: .warning, tag: .language, message: "Warning")
        ]
        let report = TemplateValidationReport(level: .basic, results: results)
        #expect(report.results[0].severity == .error)
        #expect(report.results[1].severity == .warning)
        #expect(report.results[2].severity == .info)
    }

    @Test("errors, warnings, infos filters work")
    func filterAccessors() {
        let results = [
            TemplateValidationResult(severity: .error, tag: .title, message: "E1"),
            TemplateValidationResult(severity: .error, tag: .link, message: "E2"),
            TemplateValidationResult(severity: .warning, tag: .language, message: "W1"),
            TemplateValidationResult(severity: .info, tag: .podcastValue, message: "I1")
        ]
        let report = TemplateValidationReport(level: .standard, results: results)
        #expect(report.errors.count == 2)
        #expect(report.warnings.count == 1)
        #expect(report.infos.count == 1)
    }

    @Test("isCompliant returns true when no errors")
    func compliantNoErrors() {
        let results = [
            TemplateValidationResult(severity: .warning, tag: .language, message: "W"),
            TemplateValidationResult(severity: .info, tag: .podcastValue, message: "I")
        ]
        let report = TemplateValidationReport(level: .basic, results: results)
        #expect(report.isCompliant)
    }

    @Test("isCompliant returns false when errors present")
    func notCompliantWithErrors() {
        let results = [
            TemplateValidationResult(severity: .error, tag: .title, message: "Missing")
        ]
        let report = TemplateValidationReport(level: .basic, results: results)
        #expect(!report.isCompliant)
    }

    @Test("level is preserved from init")
    func levelPreserved() {
        let report = TemplateValidationReport(level: .advanced, results: [])
        #expect(report.level == .advanced)
    }
}
