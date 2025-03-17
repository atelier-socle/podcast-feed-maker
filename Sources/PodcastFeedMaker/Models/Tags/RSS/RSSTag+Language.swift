import Foundation

public extension RSSTag {
    struct Language: Hashable, Equatable, Sendable {
        public let identifier: String

        package init(identifier: String) {
            let code = Locale.LanguageCode.isoLanguageCodes.first {
                $0.identifier == identifier
            }
            self.identifier = (code?.identifier ?? identifier)
                .lowercased(with: .current)
                .replacingOccurrences(of: "_", with: "-")
        }

        public init(value: Locale.LanguageCode) {
            let code = Locale.LanguageCode.isoLanguageCodes.first { $0 == value }
            self.init(identifier: code?.identifier ?? value.identifier)
        }
    }
}

public extension RSSTag.Language {
    var formattedLanguageCode: String? {
        Locale.autoupdatingCurrent.localizedString(forIdentifier: identifier)
    }
}

extension RSSTag.Language: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<language>\(identifier)</language>
        """
    }
}
