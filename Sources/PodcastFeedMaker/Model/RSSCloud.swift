// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
