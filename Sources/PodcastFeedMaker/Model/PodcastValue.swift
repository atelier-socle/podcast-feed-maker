import Foundation

/// The `<podcast:value>` element from Podcast Namespace 2.0.
///
/// Enables Value-for-Value (V4V) payments for the podcast. Contains
/// one or more ``ValueRecipient`` entries that define how value is split.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:value type="lightning" method="keysend" suggested="0.00000005000">
///   <podcast:valueRecipient name="Host" type="node"
///     address="02d5c..." customKey="696969" customValue="podcaster"
///     split="90" />
///   <podcast:valueRecipient name="App" type="node"
///     address="03ae9..." split="10" fee="true" />
/// </podcast:value>
/// ```
///
/// - SeeAlso: [Podcast NS — value](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#value)
public struct PodcastValue: Sendable, Hashable, Equatable, Codable {

    /// The payment type (e.g., `"lightning"`, `"paypal"`, `"other"`).
    public var type: String

    /// The payment method (e.g., `"keysend"`, `"amp"`).
    public var method: String

    /// A suggested per-minute payment amount.
    public var suggested: String?

    /// The list of value recipients.
    public var recipients: [ValueRecipient]

    /// Optional time-based splits for different segments of the episode.
    public var timeSplits: [ValueTimeSplit]

    /// Creates a new podcast value element.
    ///
    /// - Parameters:
    ///   - type: The payment type.
    ///   - method: The payment method.
    ///   - suggested: Optional suggested payment amount.
    ///   - recipients: The value recipients.
    ///   - timeSplits: Optional time-based splits.
    public init(
        type: String,
        method: String,
        suggested: String? = nil,
        recipients: [ValueRecipient] = [],
        timeSplits: [ValueTimeSplit] = []
    ) {
        self.type = type
        self.method = method
        self.suggested = suggested
        self.recipients = recipients
        self.timeSplits = timeSplits
    }
}

// MARK: - ValueRecipient

/// The `<podcast:valueRecipient>` element from Podcast Namespace 2.0.
///
/// Defines a single recipient of value payments within a ``PodcastValue`` block.
///
/// - SeeAlso: [Podcast NS — valueRecipient](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#value)
public struct ValueRecipient: Sendable, Hashable, Equatable, Codable {

    /// A human-readable name for the recipient.
    public var name: String?

    /// The type of recipient (e.g., `"node"`, `"wallet"`).
    public var type: String

    /// The payment address (e.g., a Lightning node pubkey).
    public var address: String

    /// A custom key for identifying the recipient in the payment protocol.
    public var customKey: String?

    /// A custom value associated with the custom key.
    public var customValue: String?

    /// The percentage split for this recipient (0-100).
    public var split: Int

    /// Whether this is a fee recipient (e.g., the app developer).
    public var fee: Bool?

    /// Creates a new value recipient.
    ///
    /// - Parameters:
    ///   - name: Optional display name.
    ///   - type: The recipient type.
    ///   - address: The payment address.
    ///   - customKey: Optional custom key.
    ///   - customValue: Optional custom value.
    ///   - split: The percentage split.
    ///   - fee: Whether this is a fee recipient.
    public init(
        name: String? = nil,
        type: String,
        address: String,
        customKey: String? = nil,
        customValue: String? = nil,
        split: Int,
        fee: Bool? = nil
    ) {
        self.name = name
        self.type = type
        self.address = address
        self.customKey = customKey
        self.customValue = customValue
        self.split = split
        self.fee = fee
    }
}

// MARK: - ValueTimeSplit

/// The `<podcast:valueTimeSplit>` element from Podcast Namespace 2.0.
///
/// Defines a time-based split that overrides the default value recipients
/// for a specific segment of an episode.
///
/// - SeeAlso: [Podcast NS — valueTimeSplit](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#value-time-split)
public struct ValueTimeSplit: Sendable, Hashable, Equatable, Codable {

    /// The start time in seconds for this split segment.
    public var startTime: Double

    /// The duration in seconds for this split segment.
    public var duration: Double

    /// The value recipients for this time segment.
    public var recipients: [ValueRecipient]

    /// An optional remote item reference for this segment.
    public var remoteItem: RemoteItem?

    /// An optional percentage of the default split to retain.
    public var remotePercentage: Int?

    /// Creates a new value time split.
    ///
    /// - Parameters:
    ///   - startTime: Start time in seconds.
    ///   - duration: Duration in seconds.
    ///   - recipients: Recipients for this segment.
    ///   - remoteItem: Optional remote item reference.
    ///   - remotePercentage: Optional remote percentage.
    public init(
        startTime: Double,
        duration: Double,
        recipients: [ValueRecipient] = [],
        remoteItem: RemoteItem? = nil,
        remotePercentage: Int? = nil
    ) {
        self.startTime = startTime
        self.duration = duration
        self.recipients = recipients
        self.remoteItem = remoteItem
        self.remotePercentage = remotePercentage
    }
}
