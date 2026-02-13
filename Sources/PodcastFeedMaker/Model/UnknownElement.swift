/// Represents an XML element that the parser does not natively model.
///
/// During parsing, elements that don't match any known namespace handler
/// are captured as `UnknownElement` values to prevent data loss on round-trip.
/// This covers simple (non-nested) elements at the channel or item level.
///
/// Example XML: `<custom:tag attr="val">text</custom:tag>`
///
/// - SeeAlso: ``Channel/unknownElements``, ``Item/unknownElements``
public struct UnknownElement: Sendable, Hashable, Equatable, Codable {

    /// The full element name including any namespace prefix (e.g., `"custom:tag"`).
    public var name: String

    /// The element's XML attributes as key-value pairs.
    public var attributes: [String: String]

    /// The text content of the element, or `nil` for self-closing elements.
    public var textContent: String?

    /// Creates a new unknown element.
    ///
    /// - Parameters:
    ///   - name: The full element name including namespace prefix.
    ///   - attributes: The element's attributes. Defaults to empty.
    ///   - textContent: The text content, or `nil` for self-closing.
    public init(
        name: String,
        attributes: [String: String] = [:],
        textContent: String? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.textContent = textContent
    }
}
