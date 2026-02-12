import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesEpisodeTests {

    // MARK: - Item

    @Test
    func test_item_itunesEpisode_withPositiveValue() {
        let item = Item(itunesEpisode: 3)
        #expect(item.itunesEpisode == 3)
    }

    @Test
    func test_item_itunesEpisode_withZero() {
        let item = Item(itunesEpisode: 0)
        #expect(item.itunesEpisode == 0)
    }

    @Test
    func test_item_itunesEpisode_withLargeValue() {
        let item = Item(itunesEpisode: 999_999)
        #expect(item.itunesEpisode == 999_999)
    }

    @Test
    func test_item_itunesEpisode_defaultsToNil() {
        let item = Item()
        #expect(item.itunesEpisode == nil)
    }

    // MARK: - Equatable

    @Test
    func test_item_equatable_sameEpisode() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 1)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentEpisode() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 2)
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_item_hashable() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 1)
        let itemC = Item(itunesEpisode: 2)
        let set: Set = [itemA, itemB, itemC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Item.self)
    }
}
