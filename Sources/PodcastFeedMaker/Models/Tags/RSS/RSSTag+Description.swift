import Foundation

public extension RSSTag {
    struct Description: Hashable, Equatable, Sendable {
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
                \t<description>\(content.cleanSpecialChars())</description>
                """
                case .html:
                """
                \t<description><![CDATA[\(content)]]></description>
                """
                }
            }
        }
    }
}

extension RSSTag.Description: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        type.representation(content)
    }
}
