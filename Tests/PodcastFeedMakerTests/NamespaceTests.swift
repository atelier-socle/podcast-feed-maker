import Testing

@testable import PodcastFeedMaker

struct NamespaceTests {

    @Test
    func test_allStandard_containsExpectedNamespaces() {
        let standard = PodcastNamespace.allStandard
        #expect(standard.count == 6)
        #expect(standard.contains(.itunes))
        #expect(standard.contains(.podcast))
        #expect(standard.contains(.atom))
        #expect(standard.contains(.dublinCore))
        #expect(standard.contains(.content))
        #expect(standard.contains(.podloveSimpleChapters))
    }

    @Test
    func test_xmlnsDeclaration_returnsCorrectStrings() {
        let cases: [(PodcastNamespace, String)] = [
            (.itunes, #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#),
            (.podcast, #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#),
            (.atom, #"xmlns:atom="http://www.w3.org/2005/Atom""#),
            (.dublinCore, #"xmlns:dc="http://purl.org/dc/elements/1.1/""#),
            (.content, #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#),
            (.podloveSimpleChapters, #"xmlns:psc="http://podlove.org/simple-chapters""#)
        ]

        for (namespace, expected) in cases {
            #expect(namespace.xmlnsDeclaration == expected)
        }
    }

    @Test
    func test_prefix_returnsCorrectValues() {
        #expect(PodcastNamespace.itunes.prefix == "itunes")
        #expect(PodcastNamespace.podcast.prefix == "podcast")
        #expect(PodcastNamespace.atom.prefix == "atom")
        #expect(PodcastNamespace.dublinCore.prefix == "dc")
        #expect(PodcastNamespace.content.prefix == "content")
        #expect(PodcastNamespace.podloveSimpleChapters.prefix == "psc")
    }

    @Test
    func test_equatable() {
        #expect(PodcastNamespace.atom == .atom)
        #expect(PodcastNamespace.atom != .itunes)
        #expect(PodcastNamespace.custom("xmlns:x=\"http://example.com\"") == .custom("xmlns:x=\"http://example.com\""))
        #expect(PodcastNamespace.custom("a") != .custom("b"))
    }

    @Test
    func test_hashable() {
        let set: Set<PodcastNamespace> = [.itunes, .atom, .podcast, .dublinCore]
        #expect(set.contains(.itunes))
        #expect(set.contains(.atom))
        #expect(!set.contains(.content))
    }

    @Test
    func test_customNamespace() {
        let custom = PodcastNamespace.custom(#"xmlns:my="http://example.com/ns""#)
        #expect(custom.prefix == "")
        #expect(custom.uri == #"xmlns:my="http://example.com/ns""#)
        #expect(custom.xmlnsDeclaration == #"xmlns:my="http://example.com/ns""#)
    }
}
