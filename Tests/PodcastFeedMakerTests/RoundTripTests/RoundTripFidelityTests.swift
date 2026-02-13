import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - Helpers

/// Minimal feed XML with a custom element injected into the channel.
private func channelXML(
    channelBody: String,
    namespaces: String = "xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""
) -> String {
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" \(namespaces)>
      <channel>
        <title>Test Podcast</title>
        <link>https://example.com</link>
        <description>A test podcast</description>
        \(channelBody)
      </channel>
    </rss>
    """
}

/// Minimal feed XML with a custom element injected into an item.
private func itemXML(
    itemBody: String,
    namespaces: String = "xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""
) -> String {
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" \(namespaces)>
      <channel>
        <title>Test Podcast</title>
        <link>https://example.com</link>
        <description>A test podcast</description>
        <item>
          <title>Episode 1</title>
          \(itemBody)
        </item>
      </channel>
    </rss>
    """
}

private func parse(_ xml: String) throws -> PodcastFeed {
    let parser = FeedParser()
    let data = Data(xml.utf8)
    return try parser.parse(data: data)
}

// MARK: - Unknown Element Preservation

@Suite("Unknown Element Preservation")
struct UnknownElementPreservationTests {

    @Test("Parser captures unknown channel element with text")
    func parserCapturesUnknownChannelText() throws {
        let xml = channelXML(channelBody: "<custom:rating>PG-13</custom:rating>")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.unknownElements.count == 1)
        #expect(channel.unknownElements[0].name == "custom:rating")
        #expect(channel.unknownElements[0].textContent == "PG-13")
    }

    @Test("Parser captures unknown channel element with attributes")
    func parserCapturesUnknownChannelAttrs() throws {
        let xml = channelXML(channelBody: "<custom:meta key=\"value\">content</custom:meta>")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.unknownElements.count == 1)
        #expect(channel.unknownElements[0].attributes["key"] == "value")
        #expect(channel.unknownElements[0].textContent == "content")
    }

    @Test("Parser captures unknown self-closing element")
    func parserCapturesSelfClosing() throws {
        let xml = channelXML(channelBody: "<custom:flag enabled=\"true\" />")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.unknownElements.count == 1)
        #expect(channel.unknownElements[0].name == "custom:flag")
        #expect(channel.unknownElements[0].attributes["enabled"] == "true")
        #expect(channel.unknownElements[0].textContent == nil)
    }

    @Test("Parser captures unknown item element")
    func parserCapturesUnknownItem() throws {
        let xml = itemXML(itemBody: "<custom:score>9.5</custom:score>")
        let feed = try parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.unknownElements.count == 1)
        #expect(item.unknownElements[0].name == "custom:score")
        #expect(item.unknownElements[0].textContent == "9.5")
    }

    @Test("Parser ignores known elements (not captured as unknown)")
    func parserIgnoresKnownElements() throws {
        let xml = channelXML(channelBody: "<itunes:author>Known Author</itunes:author>")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.unknownElements.isEmpty)
        #expect(channel.itunesAuthor == "Known Author")
    }

    @Test("Generator emits unknown channel elements")
    func generatorEmitsChannelUnknowns() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc",
            unknownElements: [
                UnknownElement(name: "custom:tag", textContent: "value")
            ]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<custom:tag>value</custom:tag>"))
    }

    @Test("Generator emits unknown item elements")
    func generatorEmitsItemUnknowns() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [
                Item(title: "Ep", unknownElements: [
                    UnknownElement(name: "custom:score", textContent: "10")
                ])
            ]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<custom:score>10</custom:score>"))
    }

    @Test("Generator emits attributes on unknown elements")
    func generatorEmitsAttrs() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc",
            unknownElements: [
                UnknownElement(name: "custom:meta", attributes: ["key": "val"], textContent: "text")
            ]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("key=\"val\""))
        #expect(xml.contains(">text</custom:meta>"))
    }

    @Test("Round-trip preserves unknown channel element")
    func roundTripChannel() throws {
        let xml = channelXML(channelBody: "<custom:rating>PG-13</custom:rating>")
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<custom:rating>PG-13</custom:rating>"))
    }

    @Test("Round-trip preserves unknown item element")
    func roundTripItem() throws {
        let xml = itemXML(itemBody: "<custom:score>9.5</custom:score>")
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<custom:score>9.5</custom:score>"))
    }
}

// MARK: - XML Comment Preservation

@Suite("XML Comment Preservation")
struct XMLCommentPreservationTests {

    @Test("Parser captures channel-level comment")
    func parserCapturesChannelComment() throws {
        let xml = channelXML(channelBody: "<!-- This is a channel comment -->")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.xmlComments.count == 1)
        #expect(channel.xmlComments[0] == "This is a channel comment")
    }

    @Test("Parser captures item-level comment")
    func parserCapturesItemComment() throws {
        let xml = itemXML(itemBody: "<!-- Episode note -->")
        let feed = try parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.xmlComments.count == 1)
        #expect(item.xmlComments[0] == "Episode note")
    }

    @Test("Parser ignores empty/whitespace comments")
    func parserIgnoresEmptyComments() throws {
        let xml = channelXML(channelBody: "<!--   -->")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.xmlComments.isEmpty)
    }

    @Test("Generator emits channel comments")
    func generatorEmitsChannelComments() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc",
            xmlComments: ["Channel note"]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<!-- Channel note -->"))
    }

    @Test("Generator emits item comments")
    func generatorEmitsItemComments() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [
                Item(title: "Ep", xmlComments: ["Item note"])
            ]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<!-- Item note -->"))
    }

    @Test("Round-trip preserves channel comment")
    func roundTripChannelComment() throws {
        let xml = channelXML(channelBody: "<!-- Important note -->")
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<!-- Important note -->"))
    }

    @Test("Round-trip preserves item comment")
    func roundTripItemComment() throws {
        let xml = itemXML(itemBody: "<!-- Episode remark -->")
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<!-- Episode remark -->"))
    }
}

// MARK: - CDATA Tracking

@Suite("CDATA Tracking")
struct CDATATrackingTests {

    @Test("Parser tracks CDATA field in channel (description)")
    func parserTracksCDATAChannelDescription() throws {
        let xml = channelXML(channelBody: "").replacingOccurrences(
            of: "<description>A test podcast</description>",
            with: "<description><![CDATA[A test podcast]]></description>"
        )
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.cdataFields.contains("description"))
    }

    @Test("Parser tracks CDATA field in item (description)")
    func parserTracksCDATAItemDescription() throws {
        let xml = itemXML(
            itemBody: "<description><![CDATA[Episode description with <b>HTML</b>]]></description>"
        )
        let feed = try parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.cdataFields.contains("description"))
    }

    @Test("Parser does not mark non-CDATA fields")
    func parserDoesNotMarkNonCDATA() throws {
        let xml = channelXML(channelBody: "")
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.cdataFields.isEmpty)
    }

    @Test("Parser tracks multiple CDATA fields")
    func parserTracksMultipleCDATA() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description><![CDATA[Description]]></description>
            <itunes:summary><![CDATA[Summary text]]></itunes:summary>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.cdataFields.contains("description"))
        #expect(channel.cdataFields.contains("itunes:summary"))
    }

    @Test("Generator uses CDATA for tracked fields")
    func generatorUsesCDATA() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Plain text description",
            cdataFields: ["description"]
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<description><![CDATA[Plain text description]]></description>"))
    }

    @Test("Generator does not use CDATA for non-tracked fields")
    func generatorDoesNotUseCDATAForNonTracked() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Plain text"
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("<description>Plain text</description>"))
        #expect(!xml.contains("CDATA"))
    }

    @Test("Round-trip preserves CDATA wrapping on description")
    func roundTripCDATADescription() throws {
        let xml = channelXML(channelBody: "").replacingOccurrences(
            of: "<description>A test podcast</description>",
            with: "<description><![CDATA[A test podcast]]></description>"
        )
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<description><![CDATA[A test podcast]]></description>"))
    }

    @Test("Round-trip preserves CDATA wrapping on itunes:summary")
    func roundTripCDATASummary() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description>Desc</description>
            <itunes:summary><![CDATA[Summary with no HTML]]></itunes:summary>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let output = try generator.generate(feed)
        #expect(output.contains("<itunes:summary><![CDATA[Summary with no HTML]]></itunes:summary>"))
    }

    @Test("Default behavior unchanged (no cdataFields uses smartElement logic)")
    func defaultBehaviorUnchanged() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Contains <b>HTML</b> content"
        )
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        // smartElement wraps HTML in CDATA automatically
        #expect(xml.contains("<![CDATA[Contains <b>HTML</b> content]]>"))
    }
}

// MARK: - Namespace Prefix Preservation

@Suite("Namespace Prefix Preservation")
struct NamespacePrefixPreservationTests {

    @Test("Parser records prefix-to-URI mappings")
    func parserRecordsPrefixMappings() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:atom="http://www.w3.org/2005/Atom">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description>Desc</description>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        #expect(feed.namespacePrefixes["itunes"] == "http://www.itunes.com/dtds/podcast-1.0.dtd")
        #expect(feed.namespacePrefixes["atom"] == "http://www.w3.org/2005/Atom")
    }

    @Test("Parser records custom prefix for iTunes URI")
    func parserRecordsCustomPrefix() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:apple="http://www.itunes.com/dtds/podcast-1.0.dtd">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description>Desc</description>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        #expect(feed.namespacePrefixes["apple"] == "http://www.itunes.com/dtds/podcast-1.0.dtd")
    }

    @Test("Parser records standard prefixes correctly")
    func parserRecordsStandardPrefixes() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description>Desc</description>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        #expect(feed.namespacePrefixes["podcast"] == "https://podcastindex.org/namespace/1.0")
        #expect(feed.namespacePrefixes["dc"] == "http://purl.org/dc/elements/1.1/")
    }

    @Test("Generator .parsed mode uses stored prefixes")
    func generatorParsedModeUsesPrefixes() throws {
        var feed = PodcastFeed(
            namespaces: [.itunes],
            namespacePrefixes: ["apple": "http://www.itunes.com/dtds/podcast-1.0.dtd"]
        )
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        let generator = FeedGenerator(namespaceMode: .parsed)
        let xml = try generator.generate(feed)
        #expect(xml.contains("xmlns:apple=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""))
    }

    @Test("Generator .parsed mode with empty prefixes falls back to standard")
    func generatorParsedFallback() throws {
        var feed = PodcastFeed(namespaces: [.itunes])
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        let generator = FeedGenerator(namespaceMode: .parsed)
        let xml = try generator.generate(feed)
        #expect(xml.contains("xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""))
    }

    @Test("Generator .feedDefined mode ignores stored prefixes (no regression)")
    func generatorFeedDefinedIgnoresPrefixes() throws {
        var feed = PodcastFeed(
            namespaces: [.itunes],
            namespacePrefixes: ["apple": "http://www.itunes.com/dtds/podcast-1.0.dtd"]
        )
        feed.channel = Channel(
            title: "Test", link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let xml = try generator.generate(feed)
        // feedDefined uses standard prefix, not stored
        #expect(xml.contains("xmlns:itunes="))
        #expect(!xml.contains("xmlns:apple="))
    }

    @Test("Round-trip preserves original prefix declarations")
    func roundTripPrefixes() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:apple="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:podcast="https://podcastindex.org/namespace/1.0">
          <channel>
            <title>Test</title>
            <link>https://example.com</link>
            <description>Desc</description>
          </channel>
        </rss>
        """
        let feed = try parse(xml)
        let generator = FeedGenerator(namespaceMode: .parsed)
        let output = try generator.generate(feed)
        #expect(output.contains("xmlns:apple=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""))
        #expect(output.contains("xmlns:podcast=\"https://podcastindex.org/namespace/1.0\""))
    }

    @Test("namespacePrefixes defaults to empty dict")
    func defaultsToEmpty() {
        let feed = PodcastFeed()
        #expect(feed.namespacePrefixes.isEmpty)
    }
}
