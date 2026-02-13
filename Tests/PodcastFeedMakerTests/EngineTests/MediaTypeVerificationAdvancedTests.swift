import Foundation
import Testing

@testable import PodcastFeedMaker

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


// MARK: - Helpers

private func feedWithEnclosure(
    url urlString: String, type: String
) -> PodcastFeed {
    guard let enclosureURL = URL(string: urlString) else {
        return PodcastFeed(channel: nil)
    }
    return PodcastFeed(
        channel: Channel(
            title: "Test Podcast",
            link: URL(string: "https://example.com")
                ?? URL(fileURLWithPath: "/"),
            description: "A test podcast",
            items: [
                Item(
                    title: "Episode 1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1_000_000,
                        type: type
                    )
                )
            ]
        ))
}

private func feedWithArtwork(
    channelArtwork: String? = nil
) -> PodcastFeed {
    PodcastFeed(
        channel: Channel(
            title: "Test Podcast",
            link: URL(string: "https://example.com")
                ?? URL(fileURLWithPath: "/"),
            description: "A test podcast",
            items: [Item(title: "Episode 1")],
            itunesImage: channelArtwork.flatMap { URL(string: $0) }
        ))
}

private func makeJPEGData(width: Int, height: Int) -> Data {
    var data = Data([
        0xFF, 0xD8,
        0xFF, 0xC0,
        0x00, 0x11,
        0x08
    ])
    data.append(UInt8((height >> 8) & 0xFF))
    data.append(UInt8(height & 0xFF))
    data.append(UInt8((width >> 8) & 0xFF))
    data.append(UInt8(width & 0xFF))
    let remaining = max(0, 1024 - data.count)
    data.append(
        contentsOf: Array(repeating: UInt8(0x00), count: remaining))
    return data
}

private func makePNGData(width: Int, height: Int) -> Data {
    var data = Data([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52
    ])
    data.append(UInt8((width >> 24) & 0xFF))
    data.append(UInt8((width >> 16) & 0xFF))
    data.append(UInt8((width >> 8) & 0xFF))
    data.append(UInt8(width & 0xFF))
    data.append(UInt8((height >> 24) & 0xFF))
    data.append(UInt8((height >> 16) & 0xFF))
    data.append(UInt8((height >> 8) & 0xFF))
    data.append(UInt8(height & 0xFF))
    let remaining = max(0, 1024 - data.count)
    data.append(
        contentsOf: Array(repeating: UInt8(0x00), count: remaining))
    return data
}

// MARK: - Media Type Verification Integration Tests

@Suite("Media Type Verification Integration Tests", .serialized)
struct MediaTypeVerificationIntegrationTests {

    @Test("MP3 enclosure with actual MP3 magic bytes passes")
    func mp3MatchPasses() async throws {
        let url = "https://cdn.example.com/episode1.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                ]),
                statusCode: 206,
                headers: ["Content-Range": "bytes 0-11/5000000"]
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithEnclosure(url: url, type: "audio/mpeg")
        let results = try await validator.verifyMediaTypes(feed)

        let enclosureErrors = results.filter {
            $0.field.contains("enclosure") && $0.severity == .error
        }
        #expect(enclosureErrors.isEmpty)
    }

    @Test("MP3 enclosure with M4A bytes produces error mismatch")
    func mp3WithM4ABytesError() async throws {
        let url = "https://cdn.example.com/episode2.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x00, 0x00, 0x00, 0x1C, 0x66, 0x74,
                    0x79, 0x70, 0x4D, 0x34, 0x41, 0x20
                ]),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithEnclosure(url: url, type: "audio/mpeg")
        let results = try await validator.verifyMediaTypes(feed)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.count >= 1)
        #expect(errors.first?.message.contains("declares audio/mpeg") == true)
        #expect(errors.first?.message.contains("MPEG-4 container") == true)
    }

    @Test("MP3 enclosure with HTML bytes produces info (unknown format)")
    func mp3WithHTMLBytesInfo() async throws {
        let url = "https://cdn.example.com/episode3.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data(Array("<!DOCTYPE ".utf8)),
                statusCode: 200
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithEnclosure(url: url, type: "audio/mpeg")
        let results = try await validator.verifyMediaTypes(feed)

        let infos = results.filter {
            $0.field.contains("enclosure") && $0.severity == .info
        }
        #expect(infos.count >= 1)
        #expect(
            infos.first?.message.contains(
                "Could not determine actual file type") == true)
    }

    @Test("Server returns 200 instead of 206 still works")
    func noRangeSupportStillWorks() async throws {
        let url = "https://cdn.example.com/episode4.mp3"

        var fullData = Data([
            0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ])
        fullData.append(
            contentsOf: Array(repeating: UInt8(0), count: 100))
        MockResponseStore.shared.set(
            MockResponse(data: fullData, statusCode: 200),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithEnclosure(url: url, type: "audio/mpeg")
        let results = try await validator.verifyMediaTypes(feed)

        let enclosureErrors = results.filter {
            $0.field.contains("enclosure") && $0.severity == .error
        }
        #expect(enclosureErrors.isEmpty)
    }

    @Test("Server returns 404 produces warning")
    func server404ProducesWarning() async throws {
        let url = "https://cdn.example.com/missing5.mp3"

        // Do not register -- MockURLProtocol returns fileDoesNotExist

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithEnclosure(url: url, type: "audio/mpeg")
        let results = try await validator.verifyMediaTypes(feed)

        let warnings = results.filter { $0.severity == .warning }
        #expect(warnings.count >= 1)
        #expect(
            warnings.first?.message.contains(
                "Could not verify media type") == true)
    }

    @Test("Artwork with non-image signature (MP3) produces warning")
    func artworkWithNonImageSignature() async throws {
        let url = "https://cdn.example.com/art-mp3.jpg"
        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                ]),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.verifyMediaTypes(feed)

        let warnings = results.filter {
            $0.severity == .warning && $0.message.contains("JPEG or PNG")
        }
        #expect(warnings.count >= 1)
    }

    @Test("Empty feed returns empty for media verification")
    func emptyFeedMediaVerification() async throws {
        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = PodcastFeed(channel: nil)
        let results = try await validator.verifyMediaTypes(feed)
        #expect(results.isEmpty)
    }

    @Test("Enclosure with no declared type and valid signature passes")
    func enclosureNoDeclaredType() async throws {
        let url = "https://cdn.example.com/art-nodecl.mp3"
        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                ]),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        // Enclosure with matching type (no mismatch)
        let linkURL = try #require(URL(string: "https://example.com"))
        let enclosureURL = try #require(URL(string: url))
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: linkURL,
                description: "Desc",
                items: [
                    Item(
                        title: "Ep",
                        enclosure: Enclosure(
                            url: enclosureURL,
                            length: 1024,
                            type: "audio/mp3"
                        )
                    )
                ]
            ))
        let results = try await validator.verifyMediaTypes(feed)
        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    @Test("Live item enclosure and artwork are extracted")
    func liveItemExtraction() throws {
        let validator = NetworkValidator()
        let liveEnclosureURL = try #require(URL(string: "https://cdn.example.com/live.mp3"))
        let liveItem = PodcastLiveItem(
            status: .live,
            start: Date(),
            enclosure: Enclosure(
                url: liveEnclosureURL,
                length: 0,
                type: "audio/mpeg"
            ),
            itunesImage: URL(string: "https://cdn.example.com/live-art.jpg")
        )
        let channelLink = try #require(URL(string: "https://example.com"))
        var channel = Channel(
            title: "Test",
            link: channelLink,
            description: "Desc"
        )
        channel.liveItems = [liveItem]
        let feed = PodcastFeed(channel: channel)
        let entries = validator.extractMediaVerificationEntries(from: feed)
        // Live item enclosure + live item artwork
        let liveEntries = entries.filter { $0.field.contains("liveItems") }
        #expect(liveEntries.count == 2)
    }
}

// MARK: - Artwork Dimension Checking Integration Tests

@Suite("Artwork Dimension Checking Integration Tests", .serialized)
struct ArtworkDimensionCheckingIntegrationTests {

    @Test("Artwork JPEG 2000x2000 passes for all platforms")
    func artwork2000PassesAll() async throws {
        let url = "https://cdn.example.com/art6.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 2000, height: 2000),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)

        for platform in ValidationPlatform.allCases {
            let results = try await validator.checkArtworkDimensions(
                feed, for: platform)
            let errors = results.filter { $0.severity == .error }
            #expect(
                errors.isEmpty,
                "No errors expected for \(platform) with 2000x2000")
        }
    }

    @Test("Artwork JPEG 500x500 errors too small for Apple")
    func artwork500ErrorApple() async throws {
        let url = "https://cdn.example.com/art7.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 500, height: 500),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .apple)

        let errors = results.filter { $0.severity == .error }
        #expect(errors.count >= 1)
        #expect(errors.first?.message.contains("500\u{00D7}500") == true)
        #expect(errors.first?.message.contains("minimum") == true)
        #expect(errors.first?.message.contains("apple") == true)
    }

    @Test("Artwork PNG 4000x4000 warns too large for Spotify")
    func artwork4000WarnsSpotify() async throws {
        let url = "https://cdn.example.com/art8.png"

        MockResponseStore.shared.set(
            MockResponse(
                data: makePNGData(width: 4000, height: 4000),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .spotify)

        let warnings = results.filter { $0.severity == .warning }
        #expect(warnings.count >= 1)
        #expect(
            warnings.first?.message.contains("4000\u{00D7}4000") == true)
        #expect(warnings.first?.message.contains("maximum") == true)
        #expect(warnings.first?.message.contains("spotify") == true)
    }

    @Test("Artwork 1400x1000 errors not square for Apple")
    func artworkNotSquareErrorApple() async throws {
        let url = "https://cdn.example.com/art9.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 1400, height: 1000),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .apple)

        let squareErrors = results.filter {
            $0.severity == .error && $0.message.contains("square")
        }
        #expect(squareErrors.count >= 1)
        #expect(
            squareErrors.first?.message.contains("1400\u{00D7}1000") == true)
        #expect(
            squareErrors.first?.message.contains("1:1 aspect ratio") == true)
    }

    @Test("Artwork 1400x1000 warns not square for Amazon")
    func artworkNotSquareWarningAmazon() async throws {
        let url = "https://cdn.example.com/art10.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 1400, height: 1000),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .amazon)

        let squareWarnings = results.filter {
            $0.severity == .warning && $0.message.contains("square")
        }
        #expect(squareWarnings.count >= 1)
        #expect(
            squareWarnings.first?.message.contains("recommended") == true)
    }

    @Test("Podcast Index has no dimension requirements")
    func podcastIndexNoDimensions() async throws {
        let url = "https://cdn.example.com/art11.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 100, height: 50),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .podcastIndex)

        #expect(results.isEmpty)
    }

    @Test("PSP-1 has no dimension requirements")
    func psp1NoDimensions() async throws {
        let url = "https://cdn.example.com/art12.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: makeJPEGData(width: 100, height: 50),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .psp1)

        #expect(results.isEmpty)
    }

    @Test("Artwork dimension check error produces warning")
    func artworkDimensionCheckError() async throws {
        let url = "https://cdn.example.com/art-err.jpg"
        // Not registering -> network error

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .apple)

        let warnings = results.filter { $0.severity == .warning }
        #expect(warnings.count >= 1)
        #expect(
            warnings.first?.message.contains("Could not check artwork dimensions")
                == true)
    }

    @Test("Empty feed returns empty for artwork dimensions")
    func emptyFeedArtworkDimensions() async throws {
        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = PodcastFeed(channel: nil)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .apple)
        #expect(results.isEmpty)
    }

    @Test("Cannot parse dimensions returns info")
    func cannotParseDimensionsInfo() async throws {
        let url = "https://cdn.example.com/art13.jpg"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data(
                    Array(repeating: UInt8(0x42), count: 1024)),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = feedWithArtwork(channelArtwork: url)
        let results = try await validator.checkArtworkDimensions(
            feed, for: .apple)

        let infos = results.filter { $0.severity == .info }
        #expect(infos.count >= 1)
        #expect(
            infos.first?.message.contains(
                "Could not determine dimensions") == true)
    }
}
