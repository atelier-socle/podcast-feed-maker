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

/// Generates OPML XML from ``OPMLDocument`` models.
///
/// `OPMLGenerator` converts an in-memory `OPMLDocument` into a well-formed
/// OPML 2.0 XML string. It reuses ``XMLBuilder`` for indentation, escaping,
/// and date formatting.
///
/// ## Usage
///
/// ```swift
/// let generator = OPMLGenerator()
/// let xml = generator.generate(document)
/// print(xml)
/// ```
///
/// ## Pretty Printing
///
/// By default, output is pretty-printed with tab indentation. Set
/// `prettyPrint: false` for compact output.
///
/// - SeeAlso: ``OPMLDocument``, ``OPMLParser``
public struct OPMLGenerator: Sendable {

    /// Whether to format output with indentation and newlines.
    public let prettyPrint: Bool

    /// Whether to include the XML declaration (`<?xml ...?>`).
    public let includeXMLDeclaration: Bool

    /// Creates a new OPML generator.
    ///
    /// - Parameters:
    ///   - prettyPrint: Whether to pretty-print. Defaults to `true`.
    ///   - includeXMLDeclaration: Whether to include the XML declaration. Defaults to `true`.
    public init(
        prettyPrint: Bool = true,
        includeXMLDeclaration: Bool = true
    ) {
        self.prettyPrint = prettyPrint
        self.includeXMLDeclaration = includeXMLDeclaration
    }

    /// Generates an OPML XML string from a document.
    ///
    /// - Parameter document: The OPML document to generate.
    /// - Returns: A well-formed OPML XML string.
    public func generate(_ document: OPMLDocument) -> String {
        var lines: [String] = []

        if includeXMLDeclaration {
            lines.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        }

        let b = XMLBuilder(indentString: prettyPrint ? "\t" : "")

        lines.append(b.openTag("opml", attributes: [("version", document.version)]))

        if let head = document.head {
            lines += generateHead(head, builder: b.indented())
        }

        lines += generateBody(document.outlines, builder: b.indented())

        lines.append(b.closeTag("opml"))

        return lines.joined(separator: prettyPrint ? "\n" : "")
    }

    // MARK: - Head Generation

    private func generateHead(
        _ head: OPMLHead, builder b: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("head"))

        let inner = b.indented()
        lines += generateHeadMetadata(head, builder: inner)
        lines += generateHeadWindowState(head, builder: inner)

        lines.append(b.closeTag("head"))
        return lines
    }

    private func generateHeadMetadata(
        _ head: OPMLHead, builder inner: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        if let title = head.title {
            lines.append(inner.element("title", content: title))
        }
        if let dateCreated = head.dateCreated {
            lines.append(inner.element("dateCreated", content: XMLBuilder.rfc2822Date(dateCreated)))
        }
        if let dateModified = head.dateModified {
            lines.append(inner.element("dateModified", content: XMLBuilder.rfc2822Date(dateModified)))
        }
        if let ownerName = head.ownerName {
            lines.append(inner.element("ownerName", content: ownerName))
        }
        if let ownerEmail = head.ownerEmail {
            lines.append(inner.element("ownerEmail", content: ownerEmail))
        }
        if let ownerId = head.ownerId {
            lines.append(inner.element("ownerId", content: ownerId.absoluteString))
        }
        if let docs = head.docs {
            lines.append(inner.element("docs", content: docs.absoluteString))
        }
        return lines
    }

    private func generateHeadWindowState(
        _ head: OPMLHead, builder inner: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        if let expansionState = head.expansionState {
            lines.append(inner.element("expansionState", content: expansionState))
        }
        if let vertScrollState = head.vertScrollState {
            lines.append(inner.element("vertScrollState", content: "\(vertScrollState)"))
        }
        if let windowTop = head.windowTop {
            lines.append(inner.element("windowTop", content: "\(windowTop)"))
        }
        if let windowLeft = head.windowLeft {
            lines.append(inner.element("windowLeft", content: "\(windowLeft)"))
        }
        if let windowBottom = head.windowBottom {
            lines.append(inner.element("windowBottom", content: "\(windowBottom)"))
        }
        if let windowRight = head.windowRight {
            lines.append(inner.element("windowRight", content: "\(windowRight)"))
        }
        return lines
    }

    // MARK: - Body Generation

    private func generateBody(
        _ outlines: [OPMLOutline], builder b: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("body"))

        for outline in outlines {
            lines += generateOutline(outline, builder: b.indented())
        }

        lines.append(b.closeTag("body"))
        return lines
    }

    // MARK: - Outline Generation

    private func generateOutline(
        _ outline: OPMLOutline, builder b: XMLBuilder
    ) -> [String] {
        let attrs = outlineAttributes(outline)

        if outline.isLeaf {
            return [b.selfClosingElement("outline", attributes: attrs)]
        }

        var lines: [String] = []
        lines.append(b.openTag("outline", attributes: attrs))
        for child in outline.children {
            lines += generateOutline(child, builder: b.indented())
        }
        lines.append(b.closeTag("outline"))
        return lines
    }

    private func outlineAttributes(
        _ outline: OPMLOutline
    ) -> [(String, String)] {
        var attrs: [(String, String)] = []
        attrs.append(("text", escapeAttr(outline.text)))
        attrs += outlineFeedAttributes(outline)
        attrs += outlineMetadataAttributes(outline)

        // Custom attributes sorted for deterministic output
        for (key, value) in outline.customAttributes.sorted(by: { $0.key < $1.key }) {
            attrs.append((key, escapeAttr(value)))
        }

        return attrs
    }

    private func outlineFeedAttributes(
        _ outline: OPMLOutline
    ) -> [(String, String)] {
        var attrs: [(String, String)] = []
        if let type = outline.type {
            attrs.append(("type", escapeAttr(type)))
        }
        if let xmlUrl = outline.xmlUrl {
            attrs.append(("xmlUrl", escapeAttr(xmlUrl.absoluteString)))
        }
        if let htmlUrl = outline.htmlUrl {
            attrs.append(("htmlUrl", escapeAttr(htmlUrl.absoluteString)))
        }
        if let description = outline.description {
            attrs.append(("description", escapeAttr(description)))
        }
        if let language = outline.language {
            attrs.append(("language", escapeAttr(language)))
        }
        if let title = outline.title {
            attrs.append(("title", escapeAttr(title)))
        }
        if let version = outline.version {
            attrs.append(("version", escapeAttr(version)))
        }
        return attrs
    }

    private func outlineMetadataAttributes(
        _ outline: OPMLOutline
    ) -> [(String, String)] {
        var attrs: [(String, String)] = []
        if let created = outline.created {
            attrs.append(("created", escapeAttr(XMLBuilder.rfc2822Date(created))))
        }
        if let category = outline.category {
            attrs.append(("category", escapeAttr(category)))
        }
        if let isComment = outline.isComment {
            attrs.append(("isComment", isComment ? "true" : "false"))
        }
        if let isBreakpoint = outline.isBreakpoint {
            attrs.append(("isBreakpoint", isBreakpoint ? "true" : "false"))
        }
        if let url = outline.url {
            attrs.append(("url", escapeAttr(url.absoluteString)))
        }
        return attrs
    }

    /// Escapes a value for safe inclusion in an XML attribute.
    private func escapeAttr(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
