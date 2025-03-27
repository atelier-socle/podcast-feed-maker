@testable import PodcastFeedMaker
import Testing

struct NamespaceTests {

    @Test
    func test_allCases_shouldContainExpectedNamespaces() {
        let expected: [Namespace] = [.itunes, .atom, .podcast, .rdf]
        #expect(Namespace.allCases == expected)
    }

    @Test
    func test_xmlns_shouldReturnCorrectStrings() {
        let cases: [(Namespace, String)] = [
            (.itunes, #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#),
            (.podcast, #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#),
            (.atom, #"xmlns:atom="http://www.w3.org/2005/Atom""#),
            (.rdf, #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#),
            (.psc, #"xmlns:psc="http://podlove.org/simple-chapters""#),
            (.custom("xmlns:my:custom"), "xmlns:my:custom")
        ]

        for (namespace, expectedXmlns) in cases {
            #expect(namespace.xmlns == expectedXmlns)
        }
    }

    @Test
    func test_namespaceEquatable() {
        #expect(Namespace.atom == .atom)
        #expect(Namespace.atom != .itunes)
        #expect(Namespace.custom("x") == .custom("x"))
        #expect(Namespace.custom("x") != .custom("y"))
    }

    @Test
    func test_namespaceHashable() {
        let set: Set<Namespace> = [.itunes, .atom, .podcast, .rdf, .psc, .custom("foo")]
        #expect(set.contains(.itunes))
        #expect(set.contains(.custom("foo")))
        #expect(!set.contains(.custom("bar")))
    }

    @Test
    func test_allNestedNamespaceTypesAreHashableEquatableSendable() {
        func assertConformance<T: Hashable & Equatable & Sendable>(_: T.Type) {}

        assertConformance(Namespace.Atom.self)
        assertConformance(Namespace.iTunes.self)
        assertConformance(Namespace.Podcast.self)
        assertConformance(Namespace.RDF.self)
        assertConformance(Namespace.PSC.self)
    }
}
