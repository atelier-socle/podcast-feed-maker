import Foundation

/// The `<itunes:owner>` element from the Apple Podcasts namespace.
///
/// Contains the contact information for the podcast owner. Apple uses this
/// to verify podcast ownership and send important communications.
///
/// - Important: Required by Apple Podcasts in the `<channel>` element.
///
/// Example:
/// ```xml
/// <itunes:owner>
///   <itunes:name>John Doe</itunes:name>
///   <itunes:email>john@example.com</itunes:email>
/// </itunes:owner>
/// ```
///
/// - SeeAlso: [Apple Podcasts — Owner Tag](https://podcasters.apple.com/support/823-podcast-requirements)
public struct ITunesOwner: Sendable, Hashable, Equatable, Codable {

    /// The full name of the podcast owner.
    public var name: String

    /// The contact email address.
    public var email: String

    /// Creates a new iTunes owner.
    ///
    /// - Parameters:
    ///   - name: The owner's full name.
    ///   - email: The owner's email address.
    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}
