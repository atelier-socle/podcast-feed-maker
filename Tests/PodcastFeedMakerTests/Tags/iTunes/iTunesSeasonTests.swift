import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesSeasonTests {

    @Test
    func test_xmlRepresentation_shouldGenerateCorrectXML() throws {
        let tag = try Namespace.iTunes.Season(value: 2)
        let expected = "\t<itunes:season>2</itunes:season>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withSeasonOne() throws {
        let tag = try Namespace.iTunes.Season(value: 1)
        let expected = "\t<itunes:season>1</itunes:season>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_struct_conformsToProtocols() throws {
        let tag1 = try Namespace.iTunes.Season(value: 1)
        let tag2 = try Namespace.iTunes.Season(value: 1)
        let tag3 = try Namespace.iTunes.Season(value: 3)

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)

        let set: Set<Namespace.iTunes.Season> = [tag1, tag3]
        #expect(set.contains(tag2))
    }

    @Test
    func test_init_throwsIfValueIsLessThan1() {
        #expect(throws: Namespace.iTunes.Season.SeasonError.invalidValue) {
            _ = try Namespace.iTunes.Season(value: 0)
        }

        #expect(throws: Namespace.iTunes.Season.SeasonError.invalidValue) {
            _ = try Namespace.iTunes.Season(value: -5)
        }

        #expect(performing: {
            try Namespace.iTunes.Season(value: -5)
        }, throws: { error in
            (error as? Namespace.iTunes.Season.SeasonError)?.localizedDescription == Namespace.iTunes.Season.SeasonError.invalidValue.localizedDescription
        })
    }
}
