import Foundation

public extension RSSTag {

    /// The `<language>` tag in an RSS feed.
    ///
    /// This tag indicates the language of the podcast content using [RFC 3066](https://tools.ietf.org/html/rfc3066) format.
    ///
    /// - Important: This tag is **required** by [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///   and **recommended** by [RSS 2.0](https://cyber.harvard.edu/rss/rss.html#language).
    ///
    /// - Tip: Use [ISO 639-1](https://www.loc.gov/standards/iso639-2/php/code_list.php) codes with optional region (e.g. `"en-US"`, `"fr-FR"`).
    struct Language: Hashable, Equatable, Sendable {

        /// The final formatted language code used in the XML output.
        ///
        /// Example: `"fr-fr"` or `"en-us"`.
        public let identifier: String

        /// Internal initializer used to normalize and validate a raw string identifier.
        ///
        /// - Parameter identifier: A raw ISO or RFC 3066 language code.
        package init(identifier: String) {
            let code = Locale.LanguageCode.isoLanguageCodes.first {
                $0.identifier == identifier
            }

            self.identifier = (code?.identifier ?? identifier)
                .lowercased(with: .current)
                .replacingOccurrences(of: "_", with: "-")
        }

        /// Initializes a language tag using a `Locale.LanguageCode`.
        ///
        /// - Parameter value: A standard `Locale.LanguageCode` (e.g. `.en`, `.fr`).
        public init(value: Locale.LanguageCode) {
            let code = Locale.LanguageCode.isoLanguageCodes.first { $0 == value }
            self.init(identifier: code?.identifier ?? value.identifier)
        }
    }
}


public extension RSSTag.Language {

    /// Returns a user-facing, localized version of the language identifier.
    ///
    /// This can be used in UIs to show the full language name (e.g. "French (France)").
    var formattedLanguageCode: String? {
        Locale.autoupdatingCurrent.localizedString(forIdentifier: identifier)
    }
}

extension RSSTag.Language: XmlRepresentable {

    /// Generates the XML representation of the `<language>` tag.
    ///
    /// Example:
    /// ```xml
    /// <language>fr-fr</language>
    /// ```
    ///
    /// - Returns: A valid RSS-compatible language tag.
    public func xmlRepresentation() throws -> String {
        """
        \t<language>\(identifier)</language>
        """
    }
}
