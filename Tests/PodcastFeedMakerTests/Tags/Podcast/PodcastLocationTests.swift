import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastLocationTests {

    // MARK: - Initialization

    @Test
    func initWithAllParameters() {
        let location = PodcastLocation(
            name: "Austin, TX",
            geo: "geo:30.2672,-97.7431",
            osm: "R113314"
        )

        #expect(location.name == "Austin, TX")
        #expect(location.geo == "geo:30.2672,-97.7431")
        #expect(location.osm == "R113314")
    }

    @Test
    func initWithNameOnly() {
        let location = PodcastLocation(name: "Paris, France")

        #expect(location.name == "Paris, France")
        #expect(location.geo == nil)
        #expect(location.osm == nil)
    }

    @Test
    func initWithNameAndGeo() {
        let location = PodcastLocation(name: "Berlin", geo: "geo:52.52,13.405")

        #expect(location.name == "Berlin")
        #expect(location.geo == "geo:52.52,13.405")
        #expect(location.osm == nil)
    }

    @Test
    func initWithNameAndOsm() {
        let location = PodcastLocation(name: "London", osm: "R65606")

        #expect(location.name == "London")
        #expect(location.geo == nil)
        #expect(location.osm == "R65606")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = PodcastLocation(name: "NYC", geo: "geo:40.7128,-74.0060")
        let b = PodcastLocation(name: "NYC", geo: "geo:40.7128,-74.0060")
        let c = PodcastLocation(name: "Berlin", geo: "geo:52.52,13.405")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let a = PodcastLocation(name: "NYC", geo: "geo:40.7128,-74.0060")
        let b = PodcastLocation(name: "NYC", geo: "geo:40.7128,-74.0060")
        let c = PodcastLocation(name: "Berlin", geo: "geo:52.52,13.405")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithGeoAndOsm() {
        let location = PodcastLocation(
            name: "Austin, TX",
            geo: "geo:30.2672,-97.7431",
            osm: "R113314"
        )

        var attrs: [(String, String)] = []
        if let geo = location.geo { attrs.append(("geo", geo)) }
        if let osm = location.osm { attrs.append(("osm", osm)) }
        let xml = XMLBuilder().element("podcast:location", content: location.name, attributes: attrs)

        #expect(xml.contains("podcast:location"))
        #expect(xml.contains(#"geo="geo:30.2672,-97.7431""#))
        #expect(xml.contains(#"osm="R113314""#))
        #expect(xml.contains(">Austin, TX</podcast:location>"))
    }

    @Test
    func xmlRepresentationWithNameOnly() {
        let location = PodcastLocation(name: "Paris, France")

        var attrs: [(String, String)] = []
        if let geo = location.geo { attrs.append(("geo", geo)) }
        if let osm = location.osm { attrs.append(("osm", osm)) }
        let xml = XMLBuilder().element("podcast:location", content: location.name, attributes: attrs)

        #expect(xml.contains("podcast:location"))
        #expect(xml.contains(">Paris, France</podcast:location>"))
        #expect(!xml.contains("geo="))
        #expect(!xml.contains("osm="))
    }

    @Test
    func xmlRepresentationWithGeoOnly() {
        let location = PodcastLocation(name: "Berlin", geo: "geo:52.52,13.405")

        var attrs: [(String, String)] = []
        if let geo = location.geo { attrs.append(("geo", geo)) }
        if let osm = location.osm { attrs.append(("osm", osm)) }
        let xml = XMLBuilder().element("podcast:location", content: location.name, attributes: attrs)

        #expect(xml.contains(#"geo="geo:52.52,13.405""#))
        #expect(!xml.contains("osm="))
        #expect(xml.contains(">Berlin</podcast:location>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastLocation.self)
    }
}
