import Foundation

// MARK: - Feed Component Protocol

/// A marker protocol for types that can appear inside a ``PodcastFeedBuilder`` block.
///
/// Both ``Channel`` and ``Item`` conform to this protocol, allowing them to be
/// mixed freely inside the `@PodcastFeedBuilder` result builder.
public protocol FeedComponent: Sendable {}

extension Channel: FeedComponent {}
extension Item: FeedComponent {}

// MARK: - PodcastFeedBuilder

/// A result builder that assembles a ``PodcastFeed`` from ``Channel`` and ``Item`` components.
///
/// The builder collects the single ``Channel`` and any number of ``Item`` values,
/// assigns the items to the channel, and wraps everything in a ``PodcastFeed``
/// with ``PodcastNamespace/allStandard`` namespaces.
///
/// ## Usage
///
/// ```swift
/// let feed = PodcastFeed {
///     Channel(
///         title: "My Podcast",
///         link: URL(string: "https://example.com")!,
///         description: "A great podcast"
///     )
///     .author("Jane Doe")
///     .explicit(false)
///
///     Item(title: "Episode 1")
///         .duration(1800)
///
///     Item(title: "Episode 2")
///         .duration(2400)
/// }
/// ```
///
/// - Important: Exactly one ``Channel`` must be provided. Zero or multiple
///   channels will cause a runtime precondition failure.
@resultBuilder
public struct PodcastFeedBuilder {

    /// Builds a ``PodcastFeed`` from a variadic list of ``FeedComponent`` values.
    ///
    /// - Parameter components: The channel and item components.
    /// - Returns: A complete ``PodcastFeed``.
    public static func buildBlock(_ components: FeedComponent...) -> PodcastFeed {
        assemble(components)
    }

    /// Builds a ``PodcastFeed`` from an array of ``FeedComponent`` values.
    ///
    /// - Parameter components: The channel and item components.
    /// - Returns: A complete ``PodcastFeed``.
    public static func buildBlock(_ components: [FeedComponent]) -> PodcastFeed {
        assemble(components)
    }

    // MARK: - Conditional Support

    /// Supports `if` statements in the builder.
    public static func buildOptional(_ component: FeedComponent?) -> [FeedComponent] {
        component.map { [$0] } ?? []
    }

    /// Supports `if` branch of `if/else` in the builder.
    public static func buildEither(first component: FeedComponent) -> FeedComponent {
        component
    }

    /// Supports `else` branch of `if/else` in the builder.
    public static func buildEither(second component: FeedComponent) -> FeedComponent {
        component
    }

    /// Wraps a single component into an array for composition.
    public static func buildExpression(_ expression: FeedComponent) -> FeedComponent {
        expression
    }

    // MARK: - Assembly

    private static func assemble(_ components: [FeedComponent]) -> PodcastFeed {
        var channels: [Channel] = []
        var items: [Item] = []

        for component in components {
            switch component {
            case let channel as Channel:
                channels.append(channel)
            case let item as Item:
                items.append(item)
            default:
                break
            }
        }

        guard channels.count == 1 else {
            guard let channel = channels.first else {
                return PodcastFeed()
            }
            var merged = channel
            merged.items = items
            return PodcastFeed(channel: merged)
        }

        var channel = channels[0]
        channel.items += items
        return PodcastFeed(channel: channel)
    }
}

// MARK: - PodcastFeed Convenience Init

extension PodcastFeed {

    /// Creates a feed using the ``PodcastFeedBuilder`` result builder DSL.
    ///
    /// ```swift
    /// let feed = PodcastFeed {
    ///     Channel(title: "My Show", link: url, description: "About")
    ///     Item(title: "Episode 1")
    ///     Item(title: "Episode 2")
    /// }
    /// ```
    ///
    /// - Parameter builder: A closure returning feed components.
    public init(@PodcastFeedBuilder _ builder: () -> PodcastFeed) {
        self = builder()
    }
}
