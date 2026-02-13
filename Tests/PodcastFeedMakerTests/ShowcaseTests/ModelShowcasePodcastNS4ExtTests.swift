import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Podcast NS 2.0 Phase 4+ (Block, Txt, Remote, Podroll, Update, Chat, Publisher, Images)

@Suite("Podcast NS 2.0 -- Phase 4 Extended")
struct PodcastNS20Phase4ExtendedShowcase {
    // MARK: - PodcastBlock

    @Test("PodcastBlock targeting a specific platform")
    func podcastBlockTargeted() {
        let block = PodcastBlock(isBlocked: true, id: "google")

        #expect(block.isBlocked == true)
        #expect(block.id == "google")
    }

    @Test("PodcastBlock targeting all platforms")
    func podcastBlockAll() {
        let block = PodcastBlock(isBlocked: true)

        #expect(block.isBlocked == true)
        #expect(block.id == nil)
    }

    @Test("PodcastBlock inactive (not blocked)")
    func podcastBlockInactive() {
        let block = PodcastBlock(isBlocked: false, id: "amazon")

        #expect(block.isBlocked == false)
    }

    // MARK: - PodcastTxt

    @Test("PodcastTxt verification string")
    func podcastTxtVerify() {
        let txt = PodcastTxt(value: "S6lpp-7ZCn8-VZNOk", purpose: "verify")

        #expect(txt.value == "S6lpp-7ZCn8-VZNOk")
        #expect(txt.purpose == "verify")
    }

    @Test("PodcastTxt without purpose")
    func podcastTxtNoPurpose() {
        let txt = PodcastTxt(value: "Any freeform text content here")

        #expect(txt.value == "Any freeform text content here")
        #expect(txt.purpose == nil)
    }

    // MARK: - RemoteItem

    @Test("RemoteItem with all properties")
    func remoteItemFull() {
        let feedURL = makeURL("https://example.com/feed.xml")

        let remote = RemoteItem(
            feedGuid: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1",
            feedUrl: feedURL,
            itemGuid: "episode-001",
            medium: "podcast"
        )

        #expect(remote.feedGuid == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(remote.feedUrl == feedURL)
        #expect(remote.itemGuid == "episode-001")
        #expect(remote.medium == "podcast")
    }

    @Test("RemoteItem with feedGuid only")
    func remoteItemMinimal() {
        let remote = RemoteItem(feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")

        #expect(remote.feedGuid == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(remote.feedUrl == nil)
        #expect(remote.itemGuid == nil)
        #expect(remote.medium == nil)
    }

    // MARK: - Podroll

    @Test("Podroll contains multiple recommended podcasts")
    func podrollMultipleRecommendations() {
        let url1 = makeURL("https://podcast1.example.com/feed.xml")
        let url2 = makeURL("https://podcast2.example.com/feed.xml")

        let podroll = Podroll(remoteItems: [
            RemoteItem(feedGuid: "guid-1111", feedUrl: url1, medium: "podcast"),
            RemoteItem(feedGuid: "guid-2222", feedUrl: url2, medium: "podcast"),
            RemoteItem(feedGuid: "guid-3333")
        ])

        #expect(podroll.remoteItems.count == 3)
        #expect(podroll.remoteItems[0].feedGuid == "guid-1111")
        #expect(podroll.remoteItems[2].feedUrl == nil)
    }

    @Test("Podroll defaults to empty list")
    func podrollEmpty() {
        let podroll = Podroll()
        #expect(podroll.remoteItems.isEmpty)
    }

    // MARK: - UpdateFrequency

    @Test("UpdateFrequency with all properties")
    func updateFrequencyFull() {
        let freq = UpdateFrequency(
            label: "Weekly on Fridays",
            rrule: "FREQ=WEEKLY;BYDAY=FR",
            dtstart: "2021-01-01T05:00:00.000-05:00",
            complete: false
        )

        #expect(freq.label == "Weekly on Fridays")
        #expect(freq.rrule == "FREQ=WEEKLY;BYDAY=FR")
        #expect(freq.dtstart == "2021-01-01T05:00:00.000-05:00")
        #expect(freq.complete == false)
    }

    @Test("UpdateFrequency all properties are optional")
    func updateFrequencyMinimal() {
        let freq = UpdateFrequency()

        #expect(freq.label == nil)
        #expect(freq.rrule == nil)
        #expect(freq.dtstart == nil)
        #expect(freq.complete == nil)
    }

    @Test("UpdateFrequency with complete flag for finished podcasts")
    func updateFrequencyComplete() {
        let freq = UpdateFrequency(label: "This podcast is complete", complete: true)

        #expect(freq.complete == true)
    }

    // MARK: - PodcastChat

    @Test("PodcastChat with all properties")
    func podcastChatFull() {
        let embedURL = makeURL("https://example.com/chat-embed")

        let chat = PodcastChat(
            server: "irc.zeronode.net",
            protocol: "irc",
            accountId: "podcasthost",
            space: "#podcast-room",
            embedUrl: embedURL
        )

        #expect(chat.server == "irc.zeronode.net")
        #expect(chat.protocol == "irc")
        #expect(chat.accountId == "podcasthost")
        #expect(chat.space == "#podcast-room")
        #expect(chat.embedUrl == embedURL)
    }

    @Test("PodcastChat with required properties only")
    func podcastChatMinimal() {
        let chat = PodcastChat(server: "matrix.example.com", protocol: "matrix")

        #expect(chat.server == "matrix.example.com")
        #expect(chat.protocol == "matrix")
        #expect(chat.accountId == nil)
        #expect(chat.space == nil)
        #expect(chat.embedUrl == nil)
    }

    @Test("PodcastChat supports various protocols")
    func podcastChatProtocols() {
        let nostr = PodcastChat(server: "relay.damus.io", protocol: "nostr")
        #expect(nostr.protocol == "nostr")

        let xmpp = PodcastChat(server: "xmpp.example.com", protocol: "xmpp", space: "podcast@conference.example.com")
        #expect(xmpp.protocol == "xmpp")
    }

    // MARK: - PodcastPublisher

    @Test("PodcastPublisher wraps a RemoteItem")
    func podcastPublisherProperties() {
        let url = makeURL("https://publisher.example.com/feed.xml")

        let publisher = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "003af0a0-1234-5678-90ab-cdef01234567",
                feedUrl: url,
                medium: "publisher"
            )
        )

        #expect(publisher.remoteItem.feedGuid == "003af0a0-1234-5678-90ab-cdef01234567")
        #expect(publisher.remoteItem.feedUrl == url)
        #expect(publisher.remoteItem.medium == "publisher")
    }

    // MARK: - PodcastImage

    @Test("PodcastImage with all seven attributes")
    func podcastImageFull() {
        let href = makeURL("https://example.com/artwork.png")

        let image = PodcastImage(
            href: href,
            alt: "Show artwork depicting a microphone and code",
            aspectRatio: "1/1",
            width: 3000,
            height: 3000,
            type: "image/png",
            purpose: "artwork"
        )

        #expect(image.href == href)
        #expect(image.alt == "Show artwork depicting a microphone and code")
        #expect(image.aspectRatio == "1/1")
        #expect(image.width == 3000)
        #expect(image.height == 3000)
        #expect(image.type == "image/png")
        #expect(image.purpose == "artwork")
    }

    @Test("PodcastImage with href only")
    func podcastImageMinimal() {
        let href = makeURL("https://example.com/social-card.jpg")
        let image = PodcastImage(href: href)

        #expect(image.href == href)
        #expect(image.alt == nil)
        #expect(image.aspectRatio == nil)
        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.type == nil)
        #expect(image.purpose == nil)
    }

    @Test("PodcastImage supports multiple purpose tokens")
    func podcastImageMultiplePurposes() {
        let href = makeURL("https://example.com/banner.jpg")
        let image = PodcastImage(href: href, aspectRatio: "16/9", purpose: "social canvas")

        #expect(image.purpose == "social canvas")
    }

    // MARK: - PodcastImages (Deprecated)

    @Test("PodcastImages holds srcset with width descriptors")
    func podcastImagesSrcset() {
        let images = PodcastImages(
            srcset: "https://example.com/art-1500.jpg 1500w, https://example.com/art-600.jpg 600w, https://example.com/art-300.jpg 300w"
        )

        #expect(images.srcset.contains("1500w"))
        #expect(images.srcset.contains("600w"))
        #expect(images.srcset.contains("300w"))
    }
}
