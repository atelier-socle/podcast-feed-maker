import Foundation
import Testing

@testable import PodcastFeedMaker

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


// MARK: - Helpers

private func makeFeed(
    channelImage: URL? = nil,
    items: [Item] = [],
    atomLinks: [AtomLink] = [],
    funding: [Funding] = []
) throws -> PodcastFeed {
    PodcastFeed(
        channel: Channel(
            title: "Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A podcast",
            items: items,
            itunesImage: channelImage,
            atomLinks: atomLinks,
            funding: funding
        ))
}

// MARK: - NetworkValidator Async Tests

@Suite("NetworkValidator Async Tests", .serialized)
struct NetworkValidatorAsyncTests {

    // MARK: - checkArtwork

    @Test("checkArtwork returns empty for feed without artwork")
    func checkArtworkEmpty() async throws {
        let session = makeMockSession()

        let validator = NetworkValidator(session: session)
        let feed = try makeFeed()
        let results = try await validator.checkArtwork(feed)
        #expect(results.isEmpty)
    }

    @Test("checkArtwork returns OK for 200 response")
    func checkArtworkSuccess() async throws {
        let url = "https://cdn.example.com/async-art-1.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 200),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    @Test("checkArtwork detects 404")
    func checkArtwork404() async throws {
        let url = "https://cdn.example.com/async-art-2.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 404),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.count >= 1)
        #expect(errors.first?.message.contains("404") == true)
    }

    // MARK: - checkEnclosures

    @Test("checkEnclosures returns empty for feed without enclosures")
    func checkEnclosuresEmpty() async throws {
        let session = makeMockSession()

        let validator = NetworkValidator(session: session)
        let feed = try makeFeed()
        let results = try await validator.checkEnclosures(feed)
        #expect(results.isEmpty)
    }

    @Test("checkEnclosures validates content type match")
    func checkEnclosuresContentTypeMatch() async throws {
        let url = "https://cdn.example.com/async-ep-1.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data(),
                statusCode: 200,
                headers: ["Content-Type": "audio/mpeg"]
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let enclosureURL = try #require(URL(string: url))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL, length: 1024, type: "audio/mpeg"
            )
        )
        let feed = try makeFeed(items: [item])
        let results = try await validator.checkEnclosures(feed)

        let warnings = results.filter { $0.severity == .warning }
        #expect(warnings.isEmpty)
    }

    @Test("checkEnclosures detects content type mismatch")
    func checkEnclosuresContentTypeMismatch() async throws {
        let url = "https://cdn.example.com/async-ep-2.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data(),
                statusCode: 200,
                headers: ["Content-Type": "audio/mp4; charset=utf-8"]
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let enclosureURL = try #require(URL(string: url))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL, length: 1024, type: "audio/mpeg"
            )
        )
        let feed = try makeFeed(items: [item])
        let results = try await validator.checkEnclosures(feed)

        let warnings = results.filter {
            $0.severity == .warning && $0.message.contains("Content-Type mismatch")
        }
        #expect(warnings.count >= 1)
        #expect(warnings.first?.message.contains("audio/mpeg") == true)
        #expect(warnings.first?.message.contains("audio/mp4") == true)
    }

    // MARK: - checkAllURLs

    @Test("checkAllURLs combines artwork, enclosures, atom links, and funding")
    func checkAllURLsCombined() async throws {
        let artURL = "https://cdn.example.com/async-all-art.jpg"
        let encURL = "https://cdn.example.com/async-all-ep.mp3"
        let atomURL = "https://cdn.example.com/async-all-feed.xml"
        let fundURL = "https://cdn.example.com/async-all-fund"

        for url in [artURL, encURL, atomURL, fundURL] {
            MockResponseStore.shared.set(
                MockResponse(data: Data(), statusCode: 200),
                for: url
            )
        }

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let enclosureURL = try #require(URL(string: encURL))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL, length: 1024, type: "audio/mpeg"
            )
        )
        let atomLinkURL = try #require(URL(string: atomURL))
        let fundingURL = try #require(URL(string: fundURL))
        let feed = try makeFeed(
            channelImage: URL(string: artURL),
            items: [item],
            atomLinks: [AtomLink(href: atomLinkURL, rel: "self")],
            funding: [Funding(url: fundingURL, message: "Support")]
        )
        let results = try await validator.checkAllURLs(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    // MARK: - Status Code Paths

    @Test("HTTP 301 redirect produces info")
    func redirectProducesInfo() async throws {
        let url = "https://cdn.example.com/async-redirect.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 301),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let infos = results.filter { $0.severity == .info }
        #expect(infos.count >= 1)
        #expect(infos.first?.message.contains("redirects") == true)
        #expect(infos.first?.message.contains("301") == true)
    }

    @Test("HTTP 500 produces error")
    func serverErrorProducesError() async throws {
        let url = "https://cdn.example.com/async-500.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 500),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.count >= 1)
        #expect(errors.first?.message.contains("500") == true)
    }

    @Test("Unexpected HTTP status produces warning")
    func unexpectedStatusProducesWarning() async throws {
        let url = "https://cdn.example.com/async-199.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 199),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let warnings = results.filter { $0.severity == .warning }
        #expect(warnings.count >= 1)
        #expect(warnings.first?.message.contains("199") == true)
    }

    // MARK: - Network Error

    @Test("Network error produces error result")
    func networkErrorProducesError() async throws {
        let url = "https://cdn.example.com/async-missing-url.jpg"

        // Not registering URL -> MockURLProtocol returns fileDoesNotExist error

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.count >= 1)
        #expect(errors.first?.message.contains("Network error") == true)
    }
}

// MARK: - NetworkValidator Async Extended Tests

@Suite("NetworkValidator Async Extended Tests", .serialized)
struct NetworkValidatorAsyncExtendedTests {

    // MARK: - Content Type with no expectedType

    @Test("No expected content type skips content-type validation")
    func noExpectedContentTypeSkipsValidation() async throws {
        let url = "https://cdn.example.com/async-no-ct.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data(),
                statusCode: 200,
                headers: ["Content-Type": "text/html"]
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        // Artwork URLs have no expectedType, so content-type mismatch should not trigger
        let contentTypeWarnings = results.filter {
            $0.message.contains("Content-Type mismatch")
        }
        #expect(contentTypeWarnings.isEmpty)
    }

    // MARK: - Nil Channel

    @Test("Feed with nil channel returns empty")
    func nilChannelReturnsEmpty() async throws {
        let session = makeMockSession()

        let validator = NetworkValidator(session: session)
        let feed = PodcastFeed(channel: nil)

        let artResults = try await validator.checkArtwork(feed)
        let encResults = try await validator.checkEnclosures(feed)
        let allResults = try await validator.checkAllURLs(feed)

        #expect(artResults.isEmpty)
        #expect(encResults.isEmpty)
        #expect(allResults.isEmpty)
    }

    // MARK: - Concurrency Throttling

    @Test("Multiple URLs are checked with concurrency limit")
    func concurrencyThrottling() async throws {
        var items: [Item] = []
        for i in 0..<8 {
            let url = "https://cdn.example.com/async-conc-v2-\(i).mp3"
            MockResponseStore.shared.set(
                MockResponse(data: Data(), statusCode: 200),
                for: url
            )
            let enclosureURL = try #require(URL(string: url))
            items.append(
                Item(
                    title: "Episode \(i)",
                    enclosure: Enclosure(
                        url: enclosureURL, length: 1024, type: "audio/mpeg"
                    )
                )
            )
        }

        let session = makeMockSession()
        let validator = NetworkValidator(
            session: session, maxConcurrency: 3)
        let feed = try makeFeed(items: items)
        let results = try await validator.checkEnclosures(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    // MARK: - Custom Init

    @Test("Custom init uses provided values")
    func customInit() async throws {
        let url = "https://cdn.example.com/async-custom.jpg"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 200),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(
            session: session, timeout: 5, maxConcurrency: 2)
        let feed = try makeFeed(channelImage: URL(string: url))
        let results = try await validator.checkArtwork(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    // MARK: - Content-Type with no header

    @Test("No Content-Type header skips validation")
    func noContentTypeHeaderSkips() async throws {
        let url = "https://cdn.example.com/async-no-header.mp3"

        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 200, headers: [:]),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let enclosureURL = try #require(URL(string: url))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL, length: 1024, type: "audio/mpeg"
            )
        )
        let feed = try makeFeed(items: [item])
        let results = try await validator.checkEnclosures(feed)

        let mismatches = results.filter {
            $0.message.contains("Content-Type mismatch")
        }
        #expect(mismatches.isEmpty)
    }
}
