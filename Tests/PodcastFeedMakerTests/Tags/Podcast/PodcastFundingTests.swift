import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFundingTests {

    @Test
    func test_init_setsPropertiesCorrectly() {
        let url = URL(string: "https://patreon.com/myshow")!
        let form = "Support us on Patreon"
        let funding = Namespace.Podcast.Funding(url, form: form)

        #expect(funding.url == url)
        #expect(funding.form == form)
    }

    @Test
    func test_xmlRepresentation_outputsCorrectXML() throws {
        let funding = Namespace.Podcast.Funding(
            URL(string: "https://patreon.com/myshow")!,
            form: "Support us on Patreon"
        )

        let expected = "\t<podcast:funding url=\"https://patreon.com/myshow\">Support us on Patreon</podcast:funding>"
        let xml = try funding.xmlRepresentation()

        #expect(xml == expected)
    }

    @Test
    func test_equatable_and_hashable() {
        let a = Namespace.Podcast.Funding(URL(string: "https://a.com")!, form: "A")
        let b = Namespace.Podcast.Funding(URL(string: "https://a.com")!, form: "A")
        let c = Namespace.Podcast.Funding(URL(string: "https://b.com")!, form: "B")

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
