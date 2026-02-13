import Foundation

// MARK: - PSP-1 Configuration

/// Configuration for building a PSP-1 compliant podcast feed.
///
/// PSP-1 (Podcast Standard Project v1) requires specific fields to be present.
/// This struct groups all required values for ``PodcastFeed/psp1Compliant(config:)``.
///
/// - SeeAlso: ``PodcastFeed/psp1Compliant(config:)``
public struct PSP1Configuration: Sendable {

    /// The podcast title.
    public let title: String

    /// The podcast website URL.
    public let link: URL

    /// The podcast description.
    public let description: String

    /// The feed's self-referencing URL (for `atom:link`).
    public let feedURL: URL

    /// The podcast author name (`itunes:author`).
    public let author: String

    /// The owner's display name (`itunes:owner > itunes:name`).
    public let ownerName: String

    /// The owner's email (`itunes:owner > itunes:email`).
    public let ownerEmail: String

    /// The primary iTunes category.
    public let category: ITunesCategory

    /// Whether the podcast contains explicit content.
    public let explicit: Bool

    /// The podcast artwork URL (`itunes:image`).
    public let imageURL: URL

    /// The globally unique identifier (`podcast:guid`).
    public let podcastGUID: String

    /// The feed language (BCP 47). Required by PSP-1.
    public let language: String

    /// Creates a new PSP-1 configuration.
    ///
    /// - Parameters:
    ///   - title: The podcast title.
    ///   - link: The podcast website URL.
    ///   - description: The podcast description.
    ///   - feedURL: The feed's self-referencing URL.
    ///   - author: The podcast author name.
    ///   - ownerName: The owner's display name.
    ///   - ownerEmail: The owner's email.
    ///   - category: The primary iTunes category.
    ///   - explicit: Whether the podcast contains explicit content.
    ///   - imageURL: The podcast artwork URL.
    ///   - podcastGUID: The globally unique identifier.
    ///   - language: The feed language (BCP 47). Defaults to `"en"`.
    public init(
        title: String,
        link: URL,
        description: String,
        feedURL: URL,
        author: String,
        ownerName: String,
        ownerEmail: String,
        category: ITunesCategory,
        explicit: Bool,
        imageURL: URL,
        podcastGUID: String,
        language: String = "en"
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.feedURL = feedURL
        self.author = author
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.category = category
        self.explicit = explicit
        self.imageURL = imageURL
        self.podcastGUID = podcastGUID
        self.language = language
    }
}

// MARK: - PSP-1 Compliance Helper

extension PodcastFeed {

    /// Creates a feed pre-configured with all PSP-1 required fields.
    ///
    /// PSP-1 (Podcast Standard Project v1) requires:
    /// - `atom:link` with `rel="self"` pointing to the feed URL
    /// - `podcast:locked` set (with owner)
    /// - `podcast:guid` set
    /// - iTunes metadata: author, owner, category, explicit, image
    ///
    /// The returned feed is ready for PSP-1 validation with zero errors.
    ///
    /// - Parameter config: The PSP-1 configuration containing all required fields.
    /// - Returns: A fully configured ``PodcastFeed`` ready for PSP-1 compliance.
    public static func psp1Compliant(config: PSP1Configuration) -> PodcastFeed {
        let channel = Channel(
            title: config.title,
            link: config.link,
            description: config.description,
            language: config.language,
            itunesAuthor: config.author,
            itunesCategories: [config.category],
            itunesExplicit: config.explicit,
            itunesImage: config.imageURL,
            itunesOwner: ITunesOwner(name: config.ownerName, email: config.ownerEmail),
            atomLinks: [.selfLink(href: config.feedURL)],
            podcastGuid: PodcastGuid(value: config.podcastGUID),
            locked: Locked(isLocked: true, owner: config.ownerEmail)
        )
        return PodcastFeed(
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )
    }
}
