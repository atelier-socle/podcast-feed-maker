import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastTextFieldTests {

    @Test
    func test_init_setsPropertiesCorrectly() {
        let tag = Namespace.Podcast.TextField("This is a test", verify: true)

        #expect(tag.text == "This is a test")
        #expect(tag.verify == true)
    }

    @Test
    func test_xmlRepresentation_withVerifyTrue() throws {
        let tag = Namespace.Podcast.TextField("1234567890", verify: true)
        let expected = "\t<podcast:txt purpose=\"verify\">1234567890</podcast:txt>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withVerifyFalse() throws {
        let tag = Namespace.Podcast.TextField("Some generic text", verify: false)
        let expected = "\t<podcast:txt>Some generic text</podcast:txt>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.Podcast.TextField("abc", verify: true)
        let b = Namespace.Podcast.TextField("abc", verify: true)
        let c = Namespace.Podcast.TextField("xyz", verify: false)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
