import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastLocationTests {

    @Test
    func test_init_setsPropertiesCorrectly() {
        let location = Namespace.Podcast.Location(
            place: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522
        )

        #expect(location.place == "Paris, France")
        #expect(location.latitude == 48.8566)
        #expect(location.longitude == 2.3522)
    }

    @Test
    func test_xmlRepresentation_returnsExpectedXML() throws {
        let tag = Namespace.Podcast.Location(
            place: "Paris, France",
            latitude: 48.8566,
            longitude: 2.3522
        )

        let expected = """
        \t<podcast:location geo="geo:48.8566,2.3522">Paris, France</podcast:location>
        """

        #expect(try tag.xmlRepresentation() == expected)
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.Podcast.Location(place: "NYC", latitude: 40.7128, longitude: -74.0060)
        let b = Namespace.Podcast.Location(place: "NYC", latitude: 40.7128, longitude: -74.0060)
        let c = Namespace.Podcast.Location(place: "Berlin", latitude: 52.52, longitude: 13.405)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
