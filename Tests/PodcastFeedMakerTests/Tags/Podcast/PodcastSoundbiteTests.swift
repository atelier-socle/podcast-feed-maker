import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastSoundbiteTests {

    // MARK: - Initialization

    @Test
    func initWithAllParameters() {
        let soundbite = Soundbite(startTime: 30.5, duration: 45.0, title: "Best moment")

        #expect(soundbite.startTime == 30.5)
        #expect(soundbite.duration == 45.0)
        #expect(soundbite.title == "Best moment")
    }

    @Test
    func initWithoutTitle() {
        let soundbite = Soundbite(startTime: 60.0, duration: 15.0)

        #expect(soundbite.startTime == 60.0)
        #expect(soundbite.duration == 15.0)
        #expect(soundbite.title == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = Soundbite(startTime: 10.0, duration: 5.0, title: "Preview A")
        let b = Soundbite(startTime: 10.0, duration: 5.0, title: "Preview A")
        let c = Soundbite(startTime: 15.0, duration: 10.0)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let a = Soundbite(startTime: 1.0, duration: 2.0, title: "A")
        let b = Soundbite(startTime: 1.0, duration: 2.0, title: "A")
        let c = Soundbite(startTime: 3.0, duration: 2.0)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithTitle() {
        let soundbite = Soundbite(startTime: 30.5, duration: 45.0, title: "A funny intro moment")

        let attrs: [(String, String)] = [("startTime", "\(soundbite.startTime)"), ("duration", "\(soundbite.duration)")]
        let xml: String
        if let title = soundbite.title {
            xml = XMLBuilder().element("podcast:soundbite", content: title, attributes: attrs)
        } else {
            xml = XMLBuilder().selfClosingElement("podcast:soundbite", attributes: attrs)
        }

        #expect(xml.contains("podcast:soundbite"))
        #expect(xml.contains(#"startTime="30.5""#))
        #expect(xml.contains(#"duration="45.0""#))
        #expect(xml.contains(">A funny intro moment</podcast:soundbite>"))
    }

    @Test
    func xmlRepresentationWithoutTitle() {
        let soundbite = Soundbite(startTime: 60.0, duration: 15.0)

        let attrs: [(String, String)] = [("startTime", "\(soundbite.startTime)"), ("duration", "\(soundbite.duration)")]
        let xml: String
        if let title = soundbite.title {
            xml = XMLBuilder().element("podcast:soundbite", content: title, attributes: attrs)
        } else {
            xml = XMLBuilder().selfClosingElement("podcast:soundbite", attributes: attrs)
        }

        #expect(xml.contains("podcast:soundbite"))
        #expect(xml.contains(#"startTime="60.0""#))
        #expect(xml.contains(#"duration="15.0""#))
        #expect(xml.contains("/>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Soundbite.self)
    }
}
