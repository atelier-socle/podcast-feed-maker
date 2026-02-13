import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - MediaSignature Tests

@Suite("MediaSignature Detection Tests")
struct MediaSignatureTests {

    // MARK: - Audio Formats

    @Test("Detects MP3 with ID3 header")
    func detectMP3ID3() {
        let data = Data([
            0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MP3 (ID3)")
        #expect(signature?.mimeTypes.contains("audio/mpeg") == true)
    }

    @Test("Detects MP3 with sync word FF FB")
    func detectMP3SyncFB() {
        let data = Data([
            0xFF, 0xFB, 0x90, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MP3")
        #expect(signature?.mimeTypes.contains("audio/mpeg") == true)
    }

    @Test("Detects MP3 with sync word FF F3")
    func detectMP3SyncF3() {
        let data = Data([0xFF, 0xF3, 0x90, 0x00])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MP3")
    }

    @Test("Detects MP3 with sync word FF F2")
    func detectMP3SyncF2() {
        let data = Data([0xFF, 0xF2, 0x90, 0x00])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MP3")
    }

    @Test("Detects M4A/M4B with ftyp")
    func detectM4A() {
        let data = Data([
            0x00, 0x00, 0x00, 0x1C, 0x66, 0x74,
            0x79, 0x70, 0x4D, 0x34, 0x41, 0x20,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MPEG-4 container")
        #expect(signature?.mimeTypes.contains("audio/x-m4a") == true)
        #expect(signature?.mimeTypes.contains("audio/mp4") == true)
        #expect(signature?.mimeTypes.contains("audio/x-m4b") == true)
    }

    @Test("Detects OGG Vorbis")
    func detectOGG() {
        let data = Data([
            0x4F, 0x67, 0x67, 0x53, 0x00, 0x02,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "OGG Vorbis")
        #expect(signature?.mimeTypes.contains("audio/ogg") == true)
    }

    @Test("Detects FLAC")
    func detectFLAC() {
        let data = Data([
            0x66, 0x4C, 0x61, 0x43, 0x00, 0x00,
            0x00, 0x22, 0x00, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "FLAC")
        #expect(signature?.mimeTypes.contains("audio/flac") == true)
    }

    @Test("Detects WAV with RIFF+WAVE")
    func detectWAV() {
        let data = Data([
            0x52, 0x49, 0x46, 0x46,
            0x00, 0x00, 0x00, 0x00,
            0x57, 0x41, 0x56, 0x45,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "WAV")
        #expect(signature?.mimeTypes.contains("audio/wav") == true)
    }

    @Test("Detects WMA with ASF header")
    func detectWMA() {
        let data = Data([
            0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11,
            0xA6, 0xD9, 0x00, 0xAA,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "WMA")
        #expect(signature?.mimeTypes.contains("audio/x-ms-wma") == true)
    }

    // MARK: - Video Formats

    @Test("Detects AVI with RIFF+AVI")
    func detectAVI() {
        let data = Data([
            0x52, 0x49, 0x46, 0x46,
            0x00, 0x00, 0x00, 0x00,
            0x41, 0x56, 0x49, 0x20,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "AVI")
        #expect(signature?.mimeTypes.contains("video/x-msvideo") == true)
    }

    @Test("Detects MOV with ftypqt")
    func detectMOV() {
        let data = Data([
            0x00, 0x00, 0x00, 0x14,
            0x66, 0x74, 0x79, 0x70,
            0x71, 0x74, 0x20, 0x20,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MOV")
        #expect(signature?.mimeTypes.contains("video/quicktime") == true)
    }

    @Test("Detects MOV with moov atom")
    func detectMOVMoov() {
        let data = Data([
            0x6D, 0x6F, 0x6F, 0x76,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MOV")
    }

    @Test("Detects MP4 with ftyp isom")
    func detectMP4() {
        let data = Data([
            0x00, 0x00, 0x00, 0x1C,
            0x66, 0x74, 0x79, 0x70,
            0x69, 0x73, 0x6F, 0x6D,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "MPEG-4 container")
        #expect(signature?.mimeTypes.contains("video/mp4") == true)
    }

    // MARK: - Document Formats

    @Test("Detects PDF")
    func detectPDF() {
        let data = Data([
            0x25, 0x50, 0x44, 0x46, 0x2D, 0x31,
            0x2E, 0x34, 0x0A, 0x00, 0x00, 0x00,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "PDF")
        #expect(signature?.mimeTypes.contains("application/pdf") == true)
    }

    // MARK: - Image Formats

    @Test("Detects JPEG")
    func detectJPEG() {
        let data = Data([
            0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10,
            0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "JPEG")
        #expect(signature?.mimeTypes.contains("image/jpeg") == true)
    }

    @Test("Detects PNG")
    func detectPNG() {
        let data = Data([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A,
            0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        ])
        let signature = MediaSignature.detect(from: data)
        #expect(signature != nil)
        #expect(signature?.name == "PNG")
        #expect(signature?.mimeTypes.contains("image/png") == true)
    }

    // MARK: - Edge Cases

    @Test("Unknown bytes returns nil")
    func unknownBytes() {
        let data = Data([
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
            0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,
        ])
        #expect(MediaSignature.detect(from: data) == nil)
    }

    @Test("Empty data returns nil")
    func emptyData() {
        #expect(MediaSignature.detect(from: Data()) == nil)
    }

    @Test("Too short data (1 byte) returns nil")
    func tooShortData() {
        #expect(MediaSignature.detect(from: Data([0xFF])) == nil)
    }
}

// MARK: - ImageDimensionParser Tests

@Suite("ImageDimensionParser Tests")
struct ImageDimensionParserTests {

    // MARK: - PNG

    @Test("Parses PNG dimensions from valid IHDR chunk")
    func parsePNGDimensions() {
        let data = makePNGHeaderData(width: 1400, height: 1400)
        let dims = ImageDimensionParser.parsePNG(data)
        #expect(dims != nil)
        #expect(dims?.width == 1400)
        #expect(dims?.height == 1400)
    }

    @Test("Parses PNG with non-square dimensions")
    func parsePNGNonSquare() {
        let data = makePNGHeaderData(width: 2000, height: 1000)
        let dims = ImageDimensionParser.parsePNG(data)
        #expect(dims != nil)
        #expect(dims?.width == 2000)
        #expect(dims?.height == 1000)
    }

    @Test("PNG too short (< 24 bytes) returns nil")
    func pngTooShort() {
        let data = Data([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
            0x00, 0x00, 0x00, 0x0D,
            0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x05, 0x78,
        ])
        #expect(ImageDimensionParser.parsePNG(data) == nil)
    }

    @Test("PNG with invalid signature returns nil")
    func pngInvalidSignature() {
        var data = Data([
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x0D,
            0x49, 0x48, 0x44, 0x52,
        ])
        data.append(contentsOf: [0x00, 0x00, 0x05, 0x78])
        data.append(contentsOf: [0x00, 0x00, 0x05, 0x78])
        #expect(ImageDimensionParser.parsePNG(data) == nil)
    }

    // MARK: - JPEG

    @Test("Parses JPEG dimensions from SOF0 marker")
    func parseJPEGSOF0() {
        let data = makeJPEGHeaderData(width: 2000, height: 2000)
        let dims = ImageDimensionParser.parseJPEG(data)
        #expect(dims != nil)
        #expect(dims?.width == 2000)
        #expect(dims?.height == 2000)
    }

    @Test("Parses JPEG dimensions from SOF2 marker (progressive)")
    func parseJPEGSOF2() {
        var data = Data([
            0xFF, 0xD8,
            0xFF, 0xC2,
            0x00, 0x11,
            0x08,
        ])
        data.append(contentsOf: [0x05, 0x78])  // Height: 1400
        data.append(contentsOf: [0x05, 0x78])  // Width: 1400
        let dims = ImageDimensionParser.parseJPEG(data)
        #expect(dims != nil)
        #expect(dims?.width == 1400)
        #expect(dims?.height == 1400)
    }

    @Test("JPEG with EXIF before SOF still finds dimensions")
    func jpegWithEXIF() {
        var data = Data([
            0xFF, 0xD8,
            0xFF, 0xE1,  // APP1 (EXIF)
            0x00, 0x20,  // Length (32)
        ])
        data.append(contentsOf: Array(repeating: UInt8(0x00), count: 30))
        data.append(contentsOf: [
            0xFF, 0xC0,  // SOF0
            0x00, 0x11,
            0x08,
        ])
        data.append(contentsOf: [0x0B, 0xB8])  // Height: 3000
        data.append(contentsOf: [0x0B, 0xB8])  // Width: 3000
        let dims = ImageDimensionParser.parseJPEG(data)
        #expect(dims != nil)
        #expect(dims?.width == 3000)
        #expect(dims?.height == 3000)
    }

    @Test("JPEG without SOF in first bytes returns nil")
    func jpegNoSOF() {
        var data = Data([
            0xFF, 0xD8,
            0xFF, 0xE0,
            0x00, 0x10,
        ])
        data.append(contentsOf: Array(repeating: UInt8(0x00), count: 14))
        #expect(ImageDimensionParser.parseJPEG(data) == nil)
    }

    @Test("JPEG with invalid SOI returns nil")
    func jpegInvalidSOI() {
        let data = Data([
            0x00, 0x00, 0xFF, 0xC0, 0x00, 0x11,
            0x08, 0x05, 0x78, 0x05, 0x78,
        ])
        #expect(ImageDimensionParser.parseJPEG(data) == nil)
    }

    // MARK: - Auto-detect

    @Test("Auto-detect parses PNG")
    func autoDetectPNG() {
        let data = makePNGHeaderData(width: 500, height: 500)
        let dims = ImageDimensionParser.parse(data)
        #expect(dims != nil)
        #expect(dims?.width == 500)
        #expect(dims?.height == 500)
    }

    @Test("Auto-detect parses JPEG")
    func autoDetectJPEG() {
        let data = makeJPEGHeaderData(width: 600, height: 800)
        let dims = ImageDimensionParser.parse(data)
        #expect(dims != nil)
        #expect(dims?.width == 600)
        #expect(dims?.height == 800)
    }

    // MARK: - Dimensions Properties

    @Test("isSquare returns true for equal dimensions")
    func isSquare() {
        let dims = ImageDimensionParser.Dimensions(
            width: 1400, height: 1400)
        #expect(dims.isSquare == true)
    }

    @Test("isSquare returns false for non-equal dimensions")
    func isNotSquare() {
        let dims = ImageDimensionParser.Dimensions(
            width: 1400, height: 1000)
        #expect(dims.isSquare == false)
    }

    @Test("aspectRatio calculation")
    func aspectRatio() {
        let dims = ImageDimensionParser.Dimensions(
            width: 1600, height: 800)
        #expect(dims.aspectRatio == 2.0)
    }

    // MARK: - JPEG Edge Cases

    @Test("JPEG with non-0xFF byte before marker skips correctly")
    func jpegNonFFByte() {
        // SOI (FF D8), then garbage byte (42), then SOF0 marker with dimensions
        var data = Data([0xFF, 0xD8])  // SOI
        data.append(contentsOf: [0x42])  // Non-0xFF byte -> triggers offset += 1; continue
        data.append(contentsOf: [0xFF, 0xC0])  // SOF0 marker
        // SOF0 segment: length(2) + precision(1) + height(2) + width(2)
        data.append(contentsOf: [0x00, 0x0B])  // segment length = 11
        data.append(contentsOf: [0x08])  // precision
        data.append(contentsOf: [0x00, 0x64])  // height = 100
        data.append(contentsOf: [0x00, 0xC8])  // width = 200
        // Pad to ensure enough data
        data.append(contentsOf: [0x00, 0x00, 0x00])

        let dims = ImageDimensionParser.parseJPEG(data)
        #expect(dims?.width == 200)
        #expect(dims?.height == 100)
    }

    @Test("JPEG with fill bytes (0xFF 0x00) skips correctly")
    func jpegFillBytes() {
        // SOI (FF D8), then fill byte sequence (FF 00), then SOF0 with dimensions
        var data = Data([0xFF, 0xD8])  // SOI
        data.append(contentsOf: [0xFF, 0x00])  // FF followed by 0x00 fill -> triggers offset += 1; continue
        data.append(contentsOf: [0xFF, 0xC0])  // SOF0 marker
        data.append(contentsOf: [0x00, 0x0B])  // segment length
        data.append(contentsOf: [0x08])  // precision
        data.append(contentsOf: [0x01, 0x00])  // height = 256
        data.append(contentsOf: [0x02, 0x00])  // width = 512
        data.append(contentsOf: [0x00, 0x00, 0x00])

        let dims = ImageDimensionParser.parseJPEG(data)
        #expect(dims?.width == 512)
        #expect(dims?.height == 256)
    }

    // MARK: - Helpers

    private func makePNGHeaderData(width: Int, height: Int) -> Data {
        var data = Data([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
            0x00, 0x00, 0x00, 0x0D,
            0x49, 0x48, 0x44, 0x52,
        ])
        data.append(UInt8((width >> 24) & 0xFF))
        data.append(UInt8((width >> 16) & 0xFF))
        data.append(UInt8((width >> 8) & 0xFF))
        data.append(UInt8(width & 0xFF))
        data.append(UInt8((height >> 24) & 0xFF))
        data.append(UInt8((height >> 16) & 0xFF))
        data.append(UInt8((height >> 8) & 0xFF))
        data.append(UInt8(height & 0xFF))
        return data
    }

    private func makeJPEGHeaderData(
        width: Int, height: Int
    ) -> Data {
        var data = Data([
            0xFF, 0xD8,
            0xFF, 0xC0,
            0x00, 0x11,
            0x08,
        ])
        data.append(UInt8((height >> 8) & 0xFF))
        data.append(UInt8(height & 0xFF))
        data.append(UInt8((width >> 8) & 0xFF))
        data.append(UInt8(width & 0xFF))
        return data
    }
}

// MARK: - Integration Tests (with MockURLProtocol)

@Suite("Media Type Verification Integration Tests", .serialized)
struct MediaTypeVerificationIntegrationTests {

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
            0x08,
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
            0x49, 0x48, 0x44, 0x52,
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

    // MARK: - Media Type Verification

    @Test("MP3 enclosure with actual MP3 magic bytes passes")
    func mp3MatchPasses() async throws {
        let url = "https://cdn.example.com/episode1.mp3"

        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
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
                    0x79, 0x70, 0x4D, 0x34, 0x41, 0x20,
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
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
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

        // Do not register — MockURLProtocol returns fileDoesNotExist

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

    // MARK: - Artwork Dimension Checking

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

    @Test("Artwork with non-image signature (MP3) produces warning")
    func artworkWithNonImageSignature() async throws {
        let url = "https://cdn.example.com/art-mp3.jpg"
        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
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

    @Test("Artwork dimension check error produces warning")
    func artworkDimensionCheckError() async throws {
        let url = "https://cdn.example.com/art-err.jpg"
        // Not registering → network error

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

    @Test("Empty feed returns empty for media verification")
    func emptyFeedMediaVerification() async throws {
        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        let feed = PodcastFeed(channel: nil)
        let results = try await validator.verifyMediaTypes(feed)
        #expect(results.isEmpty)
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

    @Test("Enclosure with no declared type and valid signature passes")
    func enclosureNoDeclaredType() async throws {
        let url = "https://cdn.example.com/art-nodecl.mp3"
        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                ]),
                statusCode: 206
            ),
            for: url
        )

        let session = makeMockSession()
        let validator = NetworkValidator(session: session)
        // Enclosure with matching type (no mismatch)
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "Desc",
                items: [
                    Item(
                        title: "Ep",
                        enclosure: Enclosure(
                            url: URL(string: url)!,
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
    func liveItemExtraction() {
        let validator = NetworkValidator()
        let liveItem = PodcastLiveItem(
            status: .live,
            start: Date(),
            enclosure: Enclosure(
                url: URL(string: "https://cdn.example.com/live.mp3")!,
                length: 0,
                type: "audio/mpeg"
            ),
            itunesImage: URL(string: "https://cdn.example.com/live-art.jpg")
        )
        var channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        channel.liveItems = [liveItem]
        let feed = PodcastFeed(channel: channel)
        let entries = validator.extractMediaVerificationEntries(from: feed)
        // Live item enclosure + live item artwork
        let liveEntries = entries.filter { $0.field.contains("liveItems") }
        #expect(liveEntries.count == 2)
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
