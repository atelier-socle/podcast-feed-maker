import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastLicenseTests {

    // MARK: - Initialization

    @Test
    func initWithIdentifierAndUrl() {
        let url = URL(string: "https://creativecommons.org/licenses/by/4.0/")!
        let license = PodcastLicense(identifier: "cc-by-4.0", url: url)

        #expect(license.identifier == "cc-by-4.0")
        #expect(license.url == url)
    }

    @Test
    func initWithIdentifierOnly() {
        let license = PodcastLicense(identifier: "Public Domain")

        #expect(license.identifier == "Public Domain")
        #expect(license.url == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let url = URL(string: "https://example.com/license")!
        let a = PodcastLicense(identifier: "cc-by-4.0", url: url)
        let b = PodcastLicense(identifier: "cc-by-4.0", url: url)
        let c = PodcastLicense(identifier: "Public Domain")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let url = URL(string: "https://example.com/license")!
        let a = PodcastLicense(identifier: "cc-by-4.0", url: url)
        let b = PodcastLicense(identifier: "cc-by-4.0", url: url)
        let c = PodcastLicense(identifier: "Public Domain")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithUrl() throws {
        let url = URL(string: "https://creativecommons.org/licenses/by-nc-sa/4.0/")!
        let license = PodcastLicense(identifier: "cc-by-nc-sa-4.0", url: url)

        let xml = try license.xmlRepresentation()

        #expect(xml.contains("podcast:license"))
        #expect(xml.contains(#"url="#))
        #expect(xml.contains("creativecommons.org"))
        #expect(xml.contains(">cc-by-nc-sa-4.0</podcast:license>"))
    }

    @Test
    func xmlRepresentationWithoutUrl() throws {
        let license = PodcastLicense(identifier: "Public Domain")

        let xml = try license.xmlRepresentation()

        #expect(xml.contains("podcast:license"))
        #expect(xml.contains(">Public Domain</podcast:license>"))
        #expect(!xml.contains("url="))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastLicense.self)
    }
}
