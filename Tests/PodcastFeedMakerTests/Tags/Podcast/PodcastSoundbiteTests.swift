import Foundation
@testable import PodcastFeedMaker
import Testing

struct SoundbiteTests {
    
    @Test
    func test_xmlRepresentation_withPlaceholder() throws {
        let tag = Namespace.Podcast.Soundbite(
            startTime: 30.5,
            duration: 45.0,
            placeholder: "A funny intro moment"
        )
        
        let expected = """
        \t<podcast:soundbite startTime="30.5" duration="45.0">A funny intro moment</podcast:soundbite>
        """
        
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withoutPlaceholder() throws {
        let tag = Namespace.Podcast.Soundbite(
            startTime: 60.0,
            duration: 15.0,
            placeholder: nil
        )
        
        let expected = """
        \t<podcast:soundbite startTime="60.0" duration="15.0" />
        """
        
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_equatable_conformance() {
        let tag1 = Namespace.Podcast.Soundbite(startTime: 10.0, duration: 5.0, placeholder: "Preview A")
        let tag2 = Namespace.Podcast.Soundbite(startTime: 10.0, duration: 5.0, placeholder: "Preview A")
        let tag3 = Namespace.Podcast.Soundbite(startTime: 15.0, duration: 10.0, placeholder: nil)

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func test_hashable_conformance() {
        let tag1 = Namespace.Podcast.Soundbite(startTime: 1.0, duration: 2.0, placeholder: "A")
        let tag2 = Namespace.Podcast.Soundbite(startTime: 1.0, duration: 2.0, placeholder: "A")
        let tag3 = Namespace.Podcast.Soundbite(startTime: 3.0, duration: 2.0, placeholder: nil)

        let set: Set = [tag1, tag2, tag3]
        #expect(set.count == 2)
    }
}
