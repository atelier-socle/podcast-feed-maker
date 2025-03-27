import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesCategoryTests {

    @Test
    func test_categoryInitializationAndXmlRepresentation() throws {
        let category = Namespace.iTunes.Category(
            categories: [.music([.musicCommentary])]
        )

        let xml = try category.xmlRepresentation()
        #expect(xml.contains(#"<itunes:category text="Music"><itunes:category text="Music Commentary" /></itunes:category>"#))
    }

    @Test
    func test_category_withoutSubcategories() throws {
        let category = Namespace.iTunes.Category(categories: [.technology])
        let xml = try category.xmlRepresentation()

        #expect(xml.contains(#"<itunes:category text="Technology">"#))
    }

    @Test func testCategories() async throws {
        let categories: [Namespace.iTunes.iTunesMainCategory] = [.arts([.books]), .business([.nonProfit])]
        let xml = try categories.map {
            try $0.xmlRepresentation()
        }
        let result = xml.indentedTagsRepresentation
        let expected = "\t\t<itunes:category text=\"Arts\"><itunes:category text=\"Books\" /></itunes:category>\n\t\t<itunes:category text=\"Business\"><itunes:category text=\"Non-Profit\" /></itunes:category>"
        #expect(result.count == expected.count)
        #expect(result == expected)
    }

    @Test func testAllCategories() async throws {
        let categories = Namespace.iTunes.iTunesMainCategory.allCases
        let xml = try categories.map {
            try $0.xmlRepresentation()
        }

        let result = xml.indentedTagsRepresentation
        let expected = 4508

        #expect(result.count == expected)

        for category in categories {
            try #expect(result.contains(category.xmlRepresentation()))
        }
    }

    @Test
    func test_iTunesMainCategory_allCases_containsExpectedNumber() {
        #expect(Namespace.iTunes.iTunesMainCategory.allCases.count == 19) // Ensure spec parity
    }

    @Test
    func test_mainCategory_textEncoding() {
        let mapping: [(Namespace.iTunes.iTunesMainCategory, String)] = [
            (.arts([]), "Arts"),
            (.music([]), "Music"),
            (.healthAndFitness([]), "Health &amp; Fitness"),
            (.kidsAndFamily([]), "Kids &amp; Family"),
            (.societyAndCulture([]), "Society &amp; Culture"),
            (.technology, "Technology"),
            (.trueCrime, "True Crime"),
        ]

        for (category, expectedText) in mapping {
            #expect(category.text == expectedText)
        }
    }

    @Test
    func test_mainCategory_subcategoriesXml() throws {
        let category = Namespace.iTunes.iTunesMainCategory.news([.techNews])
        let xml = try category.xmlRepresentation()

        #expect(xml.contains(#"<itunes:category text="Tech News" />"#))
    }

    @Test
    func test_subcategory_xmlRepresentation() throws {
        let subcategories: [any XmlRepresentable] = [
            Namespace.iTunes.iTunesMainCategory.MusicCategory.musicCommentary,
            Namespace.iTunes.iTunesMainCategory.ArtsCategory.books,
            Namespace.iTunes.iTunesMainCategory.BusinessCategory.marketing,
            Namespace.iTunes.iTunesMainCategory.ComedyCategory.improv,
            Namespace.iTunes.iTunesMainCategory.ReligionAndSpiritualityCategory.christianity,
            Namespace.iTunes.iTunesMainCategory.ScienceCategory.physics,
            Namespace.iTunes.iTunesMainCategory.TvAndFilmCategory.tvReviews
        ]

        for tag in subcategories {
            let xml = try tag.xmlRepresentation()
            #expect(xml.contains("<itunes:category text="))
        }
    }

    @Test
    func test_hashableAndEquatableForCategory() {
        let cat1 = Namespace.iTunes.Category(categories: [.music([.musicHistory])])
        let cat2 = Namespace.iTunes.Category(categories: [.music([.musicHistory])])
        let cat3 = Namespace.iTunes.Category(categories: [.music([.musicCommentary])])

        #expect(cat1 == cat2)
        #expect(cat1 != cat3)

        let set: Set = [cat1, cat2, cat3]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Category.self)
        assertSendable(Namespace.iTunes.iTunesMainCategory.self)
    }
}
