import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("ExpertiseLevel")
struct ExpertiseLevelTests {

    @Test("raw values are 0-3")
    func rawValues() {
        #expect(ExpertiseLevel.basic.rawValue == 0)
        #expect(ExpertiseLevel.standard.rawValue == 1)
        #expect(ExpertiseLevel.advanced.rawValue == 2)
        #expect(ExpertiseLevel.expert.rawValue == 3)
    }

    @Test("Comparable ordering")
    func comparableOrdering() {
        #expect(ExpertiseLevel.basic < .standard)
        #expect(ExpertiseLevel.standard < .advanced)
        #expect(ExpertiseLevel.advanced < .expert)
        #expect(!(ExpertiseLevel.expert < .basic))
    }

    @Test("CaseIterable has 4 cases")
    func caseIterable() {
        #expect(ExpertiseLevel.allCases.count == 4)
        #expect(ExpertiseLevel.allCases == [.basic, .standard, .advanced, .expert])
    }

    @Test("description matches case names")
    func descriptions() {
        #expect(ExpertiseLevel.basic.description == "basic")
        #expect(ExpertiseLevel.standard.description == "standard")
        #expect(ExpertiseLevel.advanced.description == "advanced")
        #expect(ExpertiseLevel.expert.description == "expert")
    }

    @Test("Hashable — distinct hash values")
    func hashable() {
        let set: Set<ExpertiseLevel> = [.basic, .standard, .advanced, .expert]
        #expect(set.count == 4)
    }

    @Test("Equatable — same and different values")
    func equatable() {
        #expect(ExpertiseLevel.basic == .basic)
        #expect(ExpertiseLevel.basic != .standard)
    }

    @Test("Codable round-trip preserves all levels")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for level in ExpertiseLevel.allCases {
            let data = try encoder.encode(level)
            let decoded = try decoder.decode(ExpertiseLevel.self, from: data)
            #expect(decoded == level)
        }
    }
}
