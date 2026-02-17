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

// MARK: - Round-Trip

/// Tests for OPML parse → generate → parse round-trip fidelity.
@Suite("OPML Round-Trip Showcase")
struct OPMLRoundTripShowcase {

    @Test("Parse → Generate → Parse — zero data loss on complete OPML")
    func fullRoundTrip() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head>
                    <title>Round Trip Test</title>
                    <ownerName>Jane</ownerName>
                    <ownerEmail>jane@example.com</ownerEmail>
                </head>
                <body>
                    <outline text="Tech" type="rss" \
            xmlUrl="https://example.com/tech.xml" \
            htmlUrl="https://example.com" \
            description="Tech podcast" language="en"/>
                    <outline text="Science" type="rss" \
            xmlUrl="https://example.com/science.xml"/>
                </body>
            </opml>
            """
        let parser = OPMLParser()
        let generator = OPMLGenerator()

        let doc1 = try parser.parse(xml)
        let regenerated = generator.generate(doc1)
        let doc2 = try parser.parse(regenerated)

        #expect(doc1.version == doc2.version)
        #expect(doc1.head?.title == doc2.head?.title)
        #expect(doc1.outlines.count == doc2.outlines.count)
        for (o1, o2) in zip(doc1.outlines, doc2.outlines) {
            #expect(o1.text == o2.text)
            #expect(o1.type == o2.type)
            #expect(o1.xmlUrl == o2.xmlUrl)
        }
    }

    @Test("Parse → Generate → Parse — custom attributes preserved")
    func customAttributeRoundTrip() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" \
            xmlUrl="https://example.com/feed.xml" \
            overcastId="42" customFlag="yes"/>
                </body>
            </opml>
            """
        let doc1 = try OPMLParser().parse(xml)
        let regenerated = OPMLGenerator().generate(doc1)
        let doc2 = try OPMLParser().parse(regenerated)

        #expect(doc2.outlines[0].customAttributes["overcastId"] == "42")
        #expect(doc2.outlines[0].customAttributes["customFlag"] == "yes")
    }

    @Test("Parse → Generate → Parse — nested categories preserved")
    func nestedRoundTrip() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Technology">
                        <outline text="Software">
                            <outline text="Deep" type="rss" \
            xmlUrl="https://example.com/deep.xml"/>
                        </outline>
                    </outline>
                </body>
            </opml>
            """
        let doc1 = try OPMLParser().parse(xml)
        let doc2 = try OPMLParser().parse(OPMLGenerator().generate(doc1))

        #expect(doc2.outlines[0].text == "Technology")
        #expect(doc2.outlines[0].children[0].text == "Software")
        #expect(doc2.outlines[0].children[0].children[0].text == "Deep")
    }

    @Test("Parse → Generate → Parse — head metadata preserved")
    func headMetadataRoundTrip() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head>
                    <title>Test</title>
                    <ownerName>Owner</ownerName>
                    <ownerEmail>owner@test.com</ownerEmail>
                    <ownerId>https://example.com/owner</ownerId>
                    <docs>http://dev.opml.org/spec2.html</docs>
                    <expansionState>1,2,3</expansionState>
                    <vertScrollState>10</vertScrollState>
                    <windowTop>50</windowTop>
                    <windowLeft>100</windowLeft>
                    <windowBottom>500</windowBottom>
                    <windowRight>700</windowRight>
                </head>
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let doc1 = try OPMLParser().parse(xml)
        let doc2 = try OPMLParser().parse(OPMLGenerator().generate(doc1))

        let h1 = try #require(doc1.head)
        let h2 = try #require(doc2.head)

        #expect(h1.title == h2.title)
        #expect(h1.ownerName == h2.ownerName)
        #expect(h1.ownerId == h2.ownerId)
        #expect(h1.docs == h2.docs)
        #expect(h1.expansionState == h2.expansionState)
        #expect(h1.vertScrollState == h2.vertScrollState)
        #expect(h1.windowTop == h2.windowTop)
    }

    @Test("Generate → Parse → Generate — XML string stability")
    func xmlStability() throws {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Stability Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed A", type: "rss",
                    xmlUrl: makeURL("https://example.com/a.xml")
                ),
                OPMLOutline(
                    text: "Feed B", type: "rss",
                    xmlUrl: makeURL("https://example.com/b.xml")
                )
            ]
        )

        let xml1 = OPMLGenerator().generate(doc)
        let parsed = try OPMLParser().parse(xml1)
        let xml2 = OPMLGenerator().generate(parsed)

        #expect(xml1 == xml2)
    }
}

// MARK: - Validator

/// Tests for ``OPMLValidator`` — document conformity checking.
@Suite("OPML Validator Showcase")
struct OPMLValidatorShowcase {

    @Test("Validate valid OPML — no errors, no warnings")
    func validateValid() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Valid"),
            outlines: [
                OPMLOutline(
                    text: "Feed", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
        #expect(report.warnings.isEmpty)
    }

    @Test("Validate error — RSS outline missing xmlUrl")
    func validateRSSMissingXmlUrl() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "Bad Feed", type: "rss")]
        )
        let report = OPMLValidator().validate(doc)
        #expect(!report.isValid)
        #expect(report.errors[0].message.contains("xmlUrl"))
    }

    @Test("Validate warning — empty text")
    func validateEmptyText() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.isValid)
        #expect(report.warnings.contains { $0.message.contains("empty text") })
    }

    @Test("Validate warning — duplicate feed URLs")
    func validateDuplicateURLs() {
        let url = makeURL("https://example.com/feed.xml")
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(text: "Feed 1", type: "rss", xmlUrl: url),
                OPMLOutline(text: "Feed 2", type: "rss", xmlUrl: url)
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.warnings.contains { $0.message.contains("Duplicate") })
    }

    @Test("Validate warning — missing type with xmlUrl")
    func validateMissingType() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.warnings.contains { $0.message.contains("type") })
    }

    @Test("Validate warning — unrecognized OPML version")
    func validateBadVersion() {
        let doc = OPMLDocument(
            version: "3.0",
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.warnings.contains { $0.message.contains("version") })
    }

    @Test("Validate warning — missing head, missing title, empty outlines")
    func validateMissingMetadata() {
        let noHead = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "F", type: "rss",
                    xmlUrl: makeURL("https://example.com/f.xml")
                )
            ]
        )
        #expect(OPMLValidator().validate(noHead).warnings.contains { $0.message.contains("head") })

        let noTitle = OPMLDocument(
            head: OPMLHead(),
            outlines: [
                OPMLOutline(
                    text: "F", type: "rss",
                    xmlUrl: makeURL("https://example.com/f.xml")
                )
            ]
        )
        #expect(OPMLValidator().validate(noTitle).warnings.contains { $0.message.contains("title") })

        let empty = OPMLDocument(head: OPMLHead(title: "Empty"))
        #expect(OPMLValidator().validate(empty).warnings.contains { $0.message.contains("no outlines") })
    }

    @Test("Validate warning — HTTP feed URL")
    func validateHTTPUrl() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed", type: "rss",
                    xmlUrl: makeURL("http://example.com/feed.xml")
                )
            ]
        )
        #expect(OPMLValidator().validate(doc).warnings.contains { $0.message.contains("HTTP") })
    }

    @Test("Validate — multiple issues collected")
    func validateMultipleIssues() {
        let doc = OPMLDocument(
            version: "9.9",
            outlines: [
                OPMLOutline(text: "Bad RSS", type: "rss"),
                OPMLOutline(text: "", xmlUrl: makeURL("http://example.com/f.xml"))
            ]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.issues.count >= 4)
    }

    @Test("OPMLValidationReport — isValid, sorting, accessors")
    func reportBehavior() {
        let warningOnly = OPMLValidationReport(
            issues: [OPMLValidationIssue(severity: .warning, message: "W", field: "f")]
        )
        #expect(warningOnly.isValid)

        let withError = OPMLValidationReport(
            issues: [OPMLValidationIssue(severity: .error, message: "E", field: "f")]
        )
        #expect(!withError.isValid)

        // Severity ordering: .error (0) < .warning (1) in enum
        #expect(OPMLValidationSeverity.error < OPMLValidationSeverity.warning)
    }

    @Test("Validate — nested errors reported with correct path")
    func validateNestedPaths() {
        let nested = OPMLOutline(text: "Bad", type: "rss")
        let category = OPMLOutline(text: "Cat", children: [nested])
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [category]
        )
        let report = OPMLValidator().validate(doc)
        #expect(report.errors.contains { $0.field.contains("children[0]") })
    }
}
