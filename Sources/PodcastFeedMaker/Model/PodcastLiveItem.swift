import Foundation

/// The `<podcast:liveItem>` element from Podcast Namespace 2.0.
///
/// Represents a live streaming episode. Contains similar metadata to a
/// regular `<item>` plus live-specific attributes like status and start/end times.
///
/// - Important: Channel-level only. May contain ``ContentLink`` elements.
///
/// Example:
/// ```xml
/// <podcast:liveItem status="live" start="2021-09-26T07:30:00.000-0600"
///                   end="2021-09-26T09:30:00.000-0600">
///   <title>Live Stream Episode</title>
///   <enclosure url="https://example.com/live.mp3" type="audio/mpeg" length="0" />
///   <podcast:contentLink href="https://example.com/chat">Chat Room</podcast:contentLink>
/// </podcast:liveItem>
/// ```
///
/// - SeeAlso: [Podcast NS — liveItem](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#live-item)
public struct PodcastLiveItem: Sendable, Hashable, Equatable, Codable {

    /// The live stream status.
    public var status: LiveStatus

    /// The scheduled start time.
    public var start: Date

    /// The scheduled end time.
    public var end: Date?

    /// The title of the live item.
    public var title: String?

    /// The live stream description.
    public var description: String?

    /// The media enclosure for the live stream.
    public var enclosure: Enclosure?

    /// The unique identifier.
    public var guid: GUID?

    /// Links to related content (e.g., chat rooms, show notes).
    public var contentLinks: [ContentLink]

    /// Persons associated with this live item.
    public var persons: [PodcastPerson]

    /// Alternative enclosures for the live stream.
    public var alternateEnclosures: [AlternateEnclosure]

    /// iTunes-level image for the live item.
    public var itunesImage: URL?

    /// Value-for-Value configuration for the live item.
    public var value: PodcastValue?

    /// Social interaction references.
    public var socialInteractions: [SocialInteract]

    /// Creates a new podcast live item.
    ///
    /// - Parameters:
    ///   - status: The live stream status.
    ///   - start: The scheduled start time.
    ///   - end: Optional scheduled end time.
    ///   - title: Optional title.
    ///   - description: Optional description.
    ///   - enclosure: Optional media enclosure.
    ///   - guid: Optional unique identifier.
    ///   - contentLinks: Related content links.
    ///   - persons: Associated persons.
    ///   - alternateEnclosures: Alternative media enclosures.
    ///   - itunesImage: Optional artwork URL.
    ///   - value: Optional V4V configuration.
    ///   - socialInteractions: Social interaction references.
    public init(
        status: LiveStatus,
        start: Date,
        end: Date? = nil,
        title: String? = nil,
        description: String? = nil,
        enclosure: Enclosure? = nil,
        guid: GUID? = nil,
        contentLinks: [ContentLink] = [],
        persons: [PodcastPerson] = [],
        alternateEnclosures: [AlternateEnclosure] = [],
        itunesImage: URL? = nil,
        value: PodcastValue? = nil,
        socialInteractions: [SocialInteract] = []
    ) {
        self.status = status
        self.start = start
        self.end = end
        self.title = title
        self.description = description
        self.enclosure = enclosure
        self.guid = guid
        self.contentLinks = contentLinks
        self.persons = persons
        self.alternateEnclosures = alternateEnclosures
        self.itunesImage = itunesImage
        self.value = value
        self.socialInteractions = socialInteractions
    }
}

// MARK: - LiveStatus

extension PodcastLiveItem {

    /// The status of a live streaming item.
    public enum LiveStatus: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        /// The live stream is currently pending (not yet started).
        case pending
        /// The live stream is currently broadcasting.
        case live
        /// The live stream has ended and is available as a recording.
        case ended
    }
}

// MARK: - ContentLink

/// The `<podcast:contentLink>` element from Podcast Namespace 2.0.
///
/// Links to related content for a ``PodcastLiveItem``, such as a chat room
/// or show notes page.
///
/// Example:
/// ```xml
/// <podcast:contentLink href="https://example.com/chat">Live Chat</podcast:contentLink>
/// ```
///
/// - SeeAlso: [Podcast NS — contentLink](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#content-link)
public struct ContentLink: Sendable, Hashable, Equatable, Codable {

    /// The URL of the related content.
    public var href: URL

    /// A human-readable label for the content link.
    public var title: String

    /// Creates a new content link.
    ///
    /// - Parameters:
    ///   - href: The content URL.
    ///   - title: A descriptive label.
    public init(href: URL, title: String) {
        self.href = href
        self.title = title
    }
}
