import Foundation

/// The `<cloud>` element from the RSS 2.0 specification.
///
/// Allows processes to register with a cloud to be notified of updates to the feed,
/// implementing a lightweight publish-subscribe protocol for RSS feeds.
///
/// Example:
/// ```xml
/// <cloud domain="rpc.example.com" port="80" path="/RPC2"
///        registerProcedure="pingMe" protocol="soap" />
/// ```
///
/// - SeeAlso: [RSS 2.0 — cloud](https://www.rssboard.org/rss-specification#ltcloudgtSubelementOfLtchannelgt)
public struct RSSCloud: Sendable, Hashable, Equatable, Codable {

    /// The domain name or IP address of the cloud server.
    public var domain: String

    /// The TCP port number.
    public var port: Int

    /// The path to the RPC handler on the cloud server.
    public var path: String

    /// The name of the procedure to call when notifying.
    public var registerProcedure: String

    /// The protocol used for communication (e.g., `"xml-rpc"`, `"soap"`, `"http-post"`).
    public var protocolType: String

    /// Creates a new RSS cloud registration element.
    ///
    /// - Parameters:
    ///   - domain: The cloud server domain.
    ///   - port: The TCP port number.
    ///   - path: The RPC handler path.
    ///   - registerProcedure: The notification procedure name.
    ///   - protocolType: The communication protocol.
    public init(
        domain: String,
        port: Int,
        path: String,
        registerProcedure: String,
        protocolType: String
    ) {
        self.domain = domain
        self.port = port
        self.path = path
        self.registerProcedure = registerProcedure
        self.protocolType = protocolType
    }
}
