import Foundation

package extension String {
    private var patternsAndReplacements: [(String, String)] {
        [
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("’", "&apos;"),
            ("“", "&quot;"),
            ("©", "&#xA9;"),
            ("&copy;", "&#xA9;"),
            ("℗", "&#x2117;"),
            ("™", "&#x2122;")
        ]
    }

    func cleanSpecialChars() -> String {
        var original = self

        for (pattern, replacement) in patternsAndReplacements {
            original = original.replacingOccurrences(
                of: pattern,
                with: replacement,
                options: .regularExpression
            )
        }

        return original
    }
}

