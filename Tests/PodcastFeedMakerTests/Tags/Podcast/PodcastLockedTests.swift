import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastLockedTests {

    // MARK: - Initialization

    @Test
    func initWithIsLockedOnly() {
        let locked = Locked(isLocked: true)

        #expect(locked.isLocked == true)
        #expect(locked.owner == nil)
    }

    @Test
    func initWithIsLockedAndOwner() {
        let locked = Locked(isLocked: true, owner: "john@example.com")

        #expect(locked.isLocked == true)
        #expect(locked.owner == "john@example.com")
    }

    @Test
    func initWithUnlockedState() {
        let locked = Locked(isLocked: false)

        #expect(locked.isLocked == false)
        #expect(locked.owner == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = Locked(isLocked: true, owner: "a@example.com")
        let b = Locked(isLocked: true, owner: "a@example.com")
        let c = Locked(isLocked: false)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let lockedTrue = Locked(isLocked: true)
        let lockedFalse = Locked(isLocked: false)

        let set: Set = [lockedTrue, lockedFalse]
        #expect(set.count == 2)
        #expect(set.contains(Locked(isLocked: true)))
        #expect(set.contains(Locked(isLocked: false)))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWhenLocked() throws {
        let locked = Locked(isLocked: true)

        let xml = try locked.xmlRepresentation()

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(">yes</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWhenUnlocked() throws {
        let locked = Locked(isLocked: false)

        let xml = try locked.xmlRepresentation()

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(">no</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWithOwner() throws {
        let locked = Locked(isLocked: true, owner: "john@example.com")

        let xml = try locked.xmlRepresentation()

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(#"owner="john@example.com""#))
        #expect(xml.contains(">yes</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWithoutOwner() throws {
        let locked = Locked(isLocked: true)

        let xml = try locked.xmlRepresentation()

        #expect(!xml.contains("owner="))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Locked.self)
    }
}
