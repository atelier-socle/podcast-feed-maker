import Foundation

package extension [String] {
    var indentedTagsRepresentation: String {
        map { "\t\($0)" }.joined(separator: "\n")
    }

    var doubleIndentedTagsRepresentation: String {
        map { "\t\t\($0)" }.joined(separator: "\n")
    }
}
