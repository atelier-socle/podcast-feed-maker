import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - PSP-1 Compliance Helper Tests

@Suite("PSP-1 Compliance Helper")
struct PSP1HelperTests {

    private func makePSP1Feed() -> PodcastFeed {
        let config = PSP1Configuration(
            title: "PSP-1 Podcast",
            link: URL(string: "https://example.com")!,
            description: "A PSP-1 compliant podcast",
            feedURL: URL(string: "https://example.com/feed.xml")!,
            author: "Host Name",
            ownerName: "Owner Name",
            ownerEmail: "owner@example.com",
            category: .technology,
            explicit: false,
            imageURL: URL(string: "https://example.com/artwork.jpg")!,
            podcastGUID: "ead4c236-bf58-58c6-a2c6-a6b28d128cb6"
        )
        return PodcastFeed.psp1Compliant(config: config)
    }

    @Test("sets channel title")
    func setsTitle() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.title == "PSP-1 Podcast")
    }

    @Test("sets channel link")
    func setsLink() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.link.absoluteString == "https://example.com")
    }

    @Test("sets channel description")
    func setsDescription() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.description == "A PSP-1 compliant podcast")
    }

    @Test("sets itunesAuthor")
    func setsAuthor() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesAuthor == "Host Name")
    }

    @Test("sets itunesOwner with name and email")
    func setsOwner() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesOwner?.name == "Owner Name")
        #expect(feed.channel?.itunesOwner?.email == "owner@example.com")
    }

    @Test("sets itunesCategory")
    func setsCategory() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesCategories.count == 1)
        #expect(feed.channel?.itunesCategories[0].text == "Technology")
    }

    @Test("sets itunesExplicit")
    func setsExplicit() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesExplicit == false)
    }

    @Test("sets itunesImage")
    func setsImage() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesImage?.absoluteString == "https://example.com/artwork.jpg")
    }

    @Test("sets atom:link with rel=self")
    func setsAtomLink() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.atomLinks.count == 1)
        #expect(feed.channel?.atomLinks[0].rel == "self")
        #expect(feed.channel?.atomLinks[0].href.absoluteString == "https://example.com/feed.xml")
        #expect(feed.channel?.atomLinks[0].type == "application/rss+xml")
    }

    @Test("sets podcast:guid")
    func setsGuid() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.podcastGuid?.value == "ead4c236-bf58-58c6-a2c6-a6b28d128cb6")
    }

    @Test("sets podcast:locked with owner email")
    func setsLocked() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.locked?.isLocked == true)
        #expect(feed.channel?.locked?.owner == "owner@example.com")
    }

    @Test("uses allStandard namespaces")
    func usesAllStandardNamespaces() {
        let feed = makePSP1Feed()
        #expect(feed.namespaces == PodcastNamespace.allStandard)
    }

    @Test("passes PSP-1 validation with zero errors")
    func passesPSP1Validation() {
        let feed = makePSP1Feed()
        let report = FeedValidator().validate(feed, for: .psp1)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
    }

    @Test("generates valid XML")
    func generatesValidXML() throws {
        let feed = makePSP1Feed()
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("PSP-1 Podcast"))
        #expect(xml.contains("podcast:guid"))
        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains("atom:link"))
    }
}
