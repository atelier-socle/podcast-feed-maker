import Foundation

/// The `<podcast:chat>` element from Podcast Namespace 2.0.
///
/// Provides chat/discussion room information for the podcast, typically
/// used during live streams or as a community hub.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:chat server="irc.zeronode.net" protocol="irc"
///              accountId="podcasthost" space="#podcast-room" />
/// ```
///
/// - SeeAlso: [Podcast NS — chat](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#chat)
public struct PodcastChat: Sendable, Hashable, Equatable, Codable {

    /// The server hostname.
    public var server: String

    /// The chat protocol (e.g., `"irc"`, `"xmpp"`, `"matrix"`, `"nostr"`).
    public var `protocol`: String

    /// The account ID or username on the chat server.
    public var accountId: String?

    /// The chat room or space identifier.
    public var space: String?

    /// An embed URL for web-based chat widgets.
    public var embedUrl: URL?

    /// Creates a new podcast chat element.
    ///
    /// - Parameters:
    ///   - server: The chat server hostname.
    ///   - protocol: The chat protocol.
    ///   - accountId: Optional account identifier.
    ///   - space: Optional chat room/space.
    ///   - embedUrl: Optional web embed URL.
    public init(
        server: String,
        protocol: String,
        accountId: String? = nil,
        space: String? = nil,
        embedUrl: URL? = nil
    ) {
        self.server = server
        self.protocol = `protocol`
        self.accountId = accountId
        self.space = space
        self.embedUrl = embedUrl
    }
}
