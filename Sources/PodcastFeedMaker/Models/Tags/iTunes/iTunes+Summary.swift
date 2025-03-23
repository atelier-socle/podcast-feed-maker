import Foundation

public extension Namespace.iTunes {
    struct Summary: Hashable, Equatable, Sendable {
        public let content: String
        private let type: DescriptionType
        
        public init(content: String, type: DescriptionType = .text) {
            self.content = content
            self.type = type
        }

        public enum DescriptionType: String, Hashable, Equatable, Sendable {
            case text, html

            func representation(_ content: String) -> String {
                switch self {
                case .text:
                """
                \t<itunes:summary>\(content.cleanSpecialChars())</itunes:summary>
                """
                case .html:
                """
                \t<itunes:summary><![CDATA[\(content)]]></itunes:summary>
                """
                }
            }
        }
    }
}

extension Namespace.iTunes.Summary: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        type.representation(content)
    }
}
