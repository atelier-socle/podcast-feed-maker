import Foundation

// MARK: - Template Feed Factory

extension PodcastFeed {

    /// Creates a feed from a template with the required fields.
    ///
    /// The returned feed has namespaces pre-configured for the template
    /// and a channel with the given title, link, and description.
    /// Use the `configure` closure to add additional fields using
    /// ``Channel`` fluent modifiers.
    ///
    /// ```swift
    /// let feed = PodcastFeed.template(.standard,
    ///     title: "My Show",
    ///     link: URL(string: "https://example.com")!,
    ///     description: "About my show"
    /// ) { channel in
    ///     channel.author("Host Name")
    ///           .explicit(false)
    ///           .category(.technology)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - template: The template to use.
    ///   - title: The channel title.
    ///   - link: The channel link URL.
    ///   - description: The channel description.
    ///   - configure: An optional closure to further configure the channel.
    /// - Returns: A configured ``PodcastFeed``.
    public static func template<T: FeedTemplate>(
        _ template: T,
        title: String,
        link: URL,
        description: String,
        configure: (Channel) -> Channel = { $0 }
    ) -> PodcastFeed {
        let channel = Channel(title: title, link: link, description: description)
        let configured = configure(channel)
        return PodcastFeed(
            namespaces: Array(template.namespaces).sorted(),
            channel: configured
        )
    }

    /// Creates a basic feed with minimal iTunes requirements.
    ///
    /// - Parameters:
    ///   - title: The channel title.
    ///   - link: The channel link URL.
    ///   - description: The channel description.
    ///   - configure: An optional closure to further configure the channel.
    /// - Returns: A configured ``PodcastFeed`` using ``BasicTemplate``.
    public static func basic(
        title: String,
        link: URL,
        description: String,
        configure: (Channel) -> Channel = { $0 }
    ) -> PodcastFeed {
        template(.basic, title: title, link: link, description: description, configure: configure)
    }

    /// Creates a standard PSP-1 compliant feed.
    ///
    /// - Parameters:
    ///   - title: The channel title.
    ///   - link: The channel link URL.
    ///   - description: The channel description.
    ///   - configure: An optional closure to further configure the channel.
    /// - Returns: A configured ``PodcastFeed`` using ``StandardTemplate``.
    public static func standard(
        title: String,
        link: URL,
        description: String,
        configure: (Channel) -> Channel = { $0 }
    ) -> PodcastFeed {
        template(
            .standard, title: title, link: link, description: description, configure: configure)
    }

    /// Creates an advanced feed with Podcast NS 2.0 phases 1-3.
    ///
    /// - Parameters:
    ///   - title: The channel title.
    ///   - link: The channel link URL.
    ///   - description: The channel description.
    ///   - configure: An optional closure to further configure the channel.
    /// - Returns: A configured ``PodcastFeed`` using ``AdvancedTemplate``.
    public static func advanced(
        title: String,
        link: URL,
        description: String,
        configure: (Channel) -> Channel = { $0 }
    ) -> PodcastFeed {
        template(
            .advanced, title: title, link: link, description: description, configure: configure)
    }

    /// Creates an expert feed with full 7-namespace coverage.
    ///
    /// - Parameters:
    ///   - title: The channel title.
    ///   - link: The channel link URL.
    ///   - description: The channel description.
    ///   - configure: An optional closure to further configure the channel.
    /// - Returns: A configured ``PodcastFeed`` using ``ExpertTemplate``.
    public static func expert(
        title: String,
        link: URL,
        description: String,
        configure: (Channel) -> Channel = { $0 }
    ) -> PodcastFeed {
        template(
            .expert, title: title, link: link, description: description, configure: configure)
    }
}
