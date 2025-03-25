/// Extension converting a `Bool` value to a string representation expected in podcast RSS tags.
///
/// Certain RSS tags, particularly in the iTunes and Podcast namespaces,
/// expect `yes` or `no` string values rather than `true` or `false`.
///
/// - Examples:
///     - `<itunes:explicit>yes</itunes:explicit>`
///     - `<itunes:block>no</itunes:block>`
package extension Bool {

    /// A `String` representation of the boolean, as `"yes"` or `"no"`.
    ///
    /// - Returns: `"yes"` if `true`, otherwise `"no"`.
    var stringValue: String {
        self ? "yes" : "no"
    }
}
