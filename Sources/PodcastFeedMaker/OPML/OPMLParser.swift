import Foundation

#if canImport(FoundationXML)
    import FoundationXML
#endif

/// Parses OPML XML into ``OPMLDocument`` models.
///
/// `OPMLParser` uses Foundation's `XMLParser` (SAX-style) to parse OPML
/// documents from strings or data. It supports OPML 1.0, 1.1, and 2.0.
///
/// ## Usage
///
/// ```swift
/// let parser = OPMLParser()
/// let document = try parser.parse(xmlString)
/// print(document.podcastFeeds.count)
/// ```
///
/// ## Best-Effort Parsing
///
/// The parser collects non-fatal warnings and continues parsing.
/// Use ``parseWithDiagnostics(_:)`` to access both the document and warnings.
///
/// - SeeAlso: ``OPMLDocument``, ``OPMLGenerator``
public struct OPMLParser: Sendable {

    /// Creates a new OPML parser.
    public init() {}

    // MARK: - Parse from String

    /// Parses an OPML XML string into an ``OPMLDocument``.
    ///
    /// - Parameter string: The OPML XML string.
    /// - Returns: The parsed document.
    /// - Throws: ``OPMLParserError`` if the XML is invalid or required
    ///   elements are missing.
    public func parse(_ string: String) throws -> OPMLDocument {
        guard let data = string.data(using: .utf8) else {
            throw OPMLParserError.encodingError(
                "Failed to encode string as UTF-8"
            )
        }
        return try parse(data: data)
    }

    /// Parses OPML XML data into an ``OPMLDocument``.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: The parsed document.
    /// - Throws: ``OPMLParserError`` if the XML is invalid or required
    ///   elements are missing.
    public func parse(data: Data) throws -> OPMLDocument {
        let result = try parseInternal(data: data)
        return result.document
    }

    // MARK: - Parse with Diagnostics

    /// The result of parsing with diagnostic information.
    public struct ParseResult: Sendable {
        /// The parsed OPML document.
        public let document: OPMLDocument
        /// Non-fatal warnings encountered during parsing.
        public let warnings: [OPMLParserError]
    }

    /// Parses an OPML XML string and returns both the document and warnings.
    ///
    /// - Parameter string: The OPML XML string.
    /// - Returns: A ``ParseResult`` with the document and warnings.
    /// - Throws: ``OPMLParserError`` for fatal parsing errors.
    public func parseWithDiagnostics(
        _ string: String
    ) throws -> ParseResult {
        guard let data = string.data(using: .utf8) else {
            throw OPMLParserError.encodingError(
                "Failed to encode string as UTF-8"
            )
        }
        return try parseWithDiagnostics(data: data)
    }

    /// Parses OPML XML data and returns both the document and warnings.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: A ``ParseResult`` with the document and warnings.
    /// - Throws: ``OPMLParserError`` for fatal parsing errors.
    public func parseWithDiagnostics(
        data: Data
    ) throws -> ParseResult {
        try parseInternal(data: data)
    }

    // MARK: - Internal

    private func parseInternal(
        data: Data
    ) throws -> ParseResult {
        let xmlParser = XMLParser(data: data)
        xmlParser.shouldProcessNamespaces = false
        xmlParser.shouldReportNamespacePrefixes = false

        let delegate = OPMLParserDelegate()
        xmlParser.delegate = delegate

        guard xmlParser.parse() || delegate.document.outlines.isEmpty == false else {
            if let error = xmlParser.parserError {
                throw OPMLParserError.invalidXML(
                    error.localizedDescription
                )
            }
            throw OPMLParserError.invalidXML("Unknown parsing error")
        }

        if !delegate.foundOPMLElement {
            throw OPMLParserError.missingOPMLElement
        }

        return ParseResult(
            document: delegate.document,
            warnings: delegate.warnings
        )
    }
}

// MARK: - OPMLParserError

/// Errors that can occur during OPML parsing.
public enum OPMLParserError: Error, LocalizedError, Equatable, Sendable {

    /// The XML is malformed or cannot be parsed.
    case invalidXML(String)

    /// The root `<opml>` element is missing.
    case missingOPMLElement

    /// The input could not be decoded as UTF-8.
    case encodingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidXML(let detail):
            "Invalid OPML XML: \(detail)"
        case .missingOPMLElement:
            "Missing <opml> root element"
        case .encodingError(let detail):
            "OPML encoding error: \(detail)"
        }
    }
}

// MARK: - OPMLParserDelegate

/// SAX-style delegate for parsing OPML XML.
final class OPMLParserDelegate: NSObject, XMLParserDelegate {

    var document = OPMLDocument()
    var warnings: [OPMLParserError] = []
    var foundOPMLElement = false

    // MARK: - Context

    private enum Context {
        case root
        case opml
        case head
        case body
        case outline
    }

    private var contextStack: [Context] = [.root]
    private var currentContext: Context { contextStack.last ?? .root }

    // MARK: - State

    private var currentText = ""
    private var currentHeadElement = ""
    private var outlineStack: [OPMLOutline] = []

    /// Standard OPML 2.0 outline attributes (case-insensitive lookup).
    private static let standardAttributes: Set<String> = [
        "text", "type", "xmlurl", "htmlurl", "description", "language",
        "title", "version", "created", "category", "iscomment",
        "isbreakpoint", "url"
    ]

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentText = ""

        switch elementName.lowercased() {
        case "opml":
            foundOPMLElement = true
            document.version = attributeDict["version"] ?? "2.0"
            contextStack.append(.opml)

        case "head" where currentContext == .opml:
            contextStack.append(.head)

        case "body" where currentContext == .opml:
            contextStack.append(.body)

        case "outline" where currentContext == .body || currentContext == .outline:
            let outline = parseOutlineAttributes(attributeDict)
            outlineStack.append(outline)
            contextStack.append(.outline)

        default:
            if currentContext == .head {
                currentHeadElement = elementName
            }
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?
    ) {
        switch elementName.lowercased() {
        case "opml":
            if currentContext == .opml {
                contextStack.removeLast()
            }

        case "head" where currentContext == .head:
            contextStack.removeLast()

        case "body" where currentContext == .body:
            contextStack.removeLast()

        case "outline" where currentContext == .outline:
            contextStack.removeLast()
            if let outline = outlineStack.popLast() {
                if outlineStack.isEmpty {
                    document.outlines.append(outline)
                } else {
                    outlineStack[outlineStack.count - 1].children.append(outline)
                }
            }

        default:
            if currentContext == .head {
                applyHeadElement(currentHeadElement, text: currentText.trimmingCharacters(in: .whitespacesAndNewlines))
                currentHeadElement = ""
            }
        }

        currentText = ""
    }

    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        currentText += string
    }

    // MARK: - Outline Parsing

    private func parseOutlineAttributes(
        _ attrs: [String: String]
    ) -> OPMLOutline {
        var outline = OPMLOutline(text: attrs["text"] ?? "")

        outline.type = attrs["type"]
        outline.description = attrs["description"]
        outline.language = attrs["language"]
        outline.title = attrs["title"]
        outline.version = attrs["version"]
        outline.category = attrs["category"]

        if let xmlUrlStr = attrs["xmlUrl"] {
            outline.xmlUrl = URL(string: xmlUrlStr)
        }
        if let htmlUrlStr = attrs["htmlUrl"] {
            outline.htmlUrl = URL(string: htmlUrlStr)
        }
        if let urlStr = attrs["url"] {
            outline.url = URL(string: urlStr)
        }

        if let createdStr = attrs["created"] {
            outline.created = DateParser.parse(createdStr)
        }

        if let isComment = attrs["isComment"] {
            outline.isComment = isComment.lowercased() == "true"
        }
        if let isBreakpoint = attrs["isBreakpoint"] {
            outline.isBreakpoint = isBreakpoint.lowercased() == "true"
        }

        // Collect custom attributes
        var custom: [String: String] = [:]
        for (key, value) in attrs where !Self.standardAttributes.contains(key.lowercased()) {
            custom[key] = value
        }
        outline.customAttributes = custom

        return outline
    }

    // MARK: - Head Parsing

    private func applyHeadElement(_ element: String, text: String) {
        guard !text.isEmpty else { return }

        if document.head == nil {
            document.head = OPMLHead()
        }

        switch element {
        case "title":
            document.head?.title = text
        case "dateCreated":
            document.head?.dateCreated = DateParser.parse(text)
        case "dateModified":
            document.head?.dateModified = DateParser.parse(text)
        case "ownerName":
            document.head?.ownerName = text
        case "ownerEmail":
            document.head?.ownerEmail = text
        case "ownerId":
            document.head?.ownerId = URL(string: text)
        case "docs":
            document.head?.docs = URL(string: text)
        default:
            applyHeadWindowState(element, text: text)
        }
    }

    private func applyHeadWindowState(_ element: String, text: String) {
        switch element {
        case "expansionState":
            document.head?.expansionState = text
        case "vertScrollState":
            document.head?.vertScrollState = Int(text)
        case "windowTop":
            document.head?.windowTop = Int(text)
        case "windowLeft":
            document.head?.windowLeft = Int(text)
        case "windowBottom":
            document.head?.windowBottom = Int(text)
        case "windowRight":
            document.head?.windowRight = Int(text)
        default:
            break
        }
    }
}
