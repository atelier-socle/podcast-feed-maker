import Foundation

package extension Date {
    var rcfPubDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss ZZZ"
        formatter.locale = Locale(identifier: "en_US")
        // formatter.timeZone = .gmt
        return formatter.string(from: self)
    }
}
