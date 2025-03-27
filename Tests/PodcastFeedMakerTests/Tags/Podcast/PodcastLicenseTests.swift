import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastLicenseTests {

    @Test
    func test_init_setsPropertiesCorrectly() {
        let url = URL(string: "https://creativecommons.org/licenses/by-nc-sa/4.0/")
        let tag = Namespace.Podcast.License(url, form: "CC BY-NC-SA 4.0")

        #expect(tag.url == url)
        #expect(tag.form == "CC BY-NC-SA 4.0")
    }

    @Test
    func test_xmlRepresentation_withURL() throws {
        let url = URL(string: "https://creativecommons.org/licenses/by-nc-sa/4.0/")!
        let tag = Namespace.Podcast.License(url, form: "CC BY-NC-SA 4.0")

        let expected = """
        \t<podcast:license url="\(url.encodeURLQueryAllowed)">CC BY-NC-SA 4.0</podcast:license>
        """

        #expect(try tag.xmlRepresentation() == expected)
    }

    @Test
    func test_xmlRepresentation_withoutURL() throws {
        let tag = Namespace.Podcast.License(nil, form: "Public Domain")

        let expected = "\t<podcast:license>Public Domain</podcast:license>"

        #expect(try tag.xmlRepresentation() == expected)
    }

    @Test
    func test_equatableAndHashable() {
        let url = URL(string: "https://example.com/license")!
        let a = Namespace.Podcast.License(url, form: "License A")
        let b = Namespace.Podcast.License(url, form: "License A")
        let c = Namespace.Podcast.License(nil, form: "License B")

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
