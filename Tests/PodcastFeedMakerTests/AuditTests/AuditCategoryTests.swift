import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - AuditCategory Tests

@Suite("AuditCategory Tests")
struct AuditCategoryTests {

    @Test("All 5 categories are available via CaseIterable")
    func allCategoriesExist() {
        let allCases = AuditCategory.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.metadata))
        #expect(allCases.contains(.episodes))
        #expect(allCases.contains(.compliance))
        #expect(allCases.contains(.accessibility))
        #expect(allCases.contains(.discoverability))
    }

    @Test("Category weights sum to 1.0")
    func weightsSumToOne() {
        let total = AuditCategory.allCases.reduce(0.0) { $0 + $1.weight }
        #expect(abs(total - 1.0) < 0.0001)
    }

    @Test("Metadata has weight 0.25")
    func metadataWeight() {
        #expect(AuditCategory.metadata.weight == 0.25)
    }

    @Test("Episodes has weight 0.25")
    func episodesWeight() {
        #expect(AuditCategory.episodes.weight == 0.25)
    }

    @Test("Compliance has weight 0.20")
    func complianceWeight() {
        #expect(AuditCategory.compliance.weight == 0.20)
    }

    @Test("Accessibility has weight 0.15")
    func accessibilityWeight() {
        #expect(AuditCategory.accessibility.weight == 0.15)
    }

    @Test("Discoverability has weight 0.15")
    func discoverabilityWeight() {
        #expect(AuditCategory.discoverability.weight == 0.15)
    }

    @Test("Metadata maxPoints is 25")
    func metadataMaxPoints() {
        #expect(AuditCategory.metadata.maxPoints == 25)
    }

    @Test("Episodes maxPoints is 25")
    func episodesMaxPoints() {
        #expect(AuditCategory.episodes.maxPoints == 25)
    }

    @Test("Compliance maxPoints is 20")
    func complianceMaxPoints() {
        #expect(AuditCategory.compliance.maxPoints == 20)
    }

    @Test("Accessibility maxPoints is 15")
    func accessibilityMaxPoints() {
        #expect(AuditCategory.accessibility.maxPoints == 15)
    }

    @Test("Discoverability maxPoints is 15")
    func discoverabilityMaxPoints() {
        #expect(AuditCategory.discoverability.maxPoints == 15)
    }

    @Test("Total maxPoints across all categories equals 100")
    func totalMaxPointsIs100() {
        let total = AuditCategory.allCases.reduce(0) { $0 + $1.maxPoints }
        #expect(total == 100)
    }

    @Test("Metadata displayName is Metadata")
    func metadataDisplayName() {
        #expect(AuditCategory.metadata.displayName == "Metadata")
    }

    @Test("Episodes displayName is Episodes")
    func episodesDisplayName() {
        #expect(AuditCategory.episodes.displayName == "Episodes")
    }

    @Test("Compliance displayName is Compliance")
    func complianceDisplayName() {
        #expect(AuditCategory.compliance.displayName == "Compliance")
    }

    @Test("Accessibility displayName is Accessibility")
    func accessibilityDisplayName() {
        #expect(AuditCategory.accessibility.displayName == "Accessibility")
    }

    @Test("Discoverability displayName is Discoverability")
    func discoverabilityDisplayName() {
        #expect(AuditCategory.discoverability.displayName == "Discoverability")
    }
}

// MARK: - AuditGrade Tests

@Suite("AuditGrade Tests")
struct AuditGradeTests {

    @Test("CaseIterable has all 8 grades")
    func allGradesExist() {
        let allCases = AuditGrade.allCases
        #expect(allCases.count == 8)
        #expect(allCases.contains(.aPlus))
        #expect(allCases.contains(.a))
        #expect(allCases.contains(.bPlus))
        #expect(allCases.contains(.b))
        #expect(allCases.contains(.cPlus))
        #expect(allCases.contains(.c))
        #expect(allCases.contains(.d))
        #expect(allCases.contains(.f))
    }

    @Test("Score 100 yields A+")
    func score100IsAPlus() {
        #expect(AuditGrade.from(score: 100) == .aPlus)
    }

    @Test("Score 95 yields A+")
    func score95IsAPlus() {
        #expect(AuditGrade.from(score: 95) == .aPlus)
    }

    @Test("Score 94 yields A")
    func score94IsA() {
        #expect(AuditGrade.from(score: 94) == .a)
    }

    @Test("Score 90 yields A")
    func score90IsA() {
        #expect(AuditGrade.from(score: 90) == .a)
    }

    @Test("Score 89 yields B+")
    func score89IsBPlus() {
        #expect(AuditGrade.from(score: 89) == .bPlus)
    }

    @Test("Score 85 yields B+")
    func score85IsBPlus() {
        #expect(AuditGrade.from(score: 85) == .bPlus)
    }

    @Test("Score 84 yields B")
    func score84IsB() {
        #expect(AuditGrade.from(score: 84) == .b)
    }

    @Test("Score 80 yields B")
    func score80IsB() {
        #expect(AuditGrade.from(score: 80) == .b)
    }

    @Test("Score 79 yields C+")
    func score79IsCPlus() {
        #expect(AuditGrade.from(score: 79) == .cPlus)
    }

    @Test("Score 75 yields C+")
    func score75IsCPlus() {
        #expect(AuditGrade.from(score: 75) == .cPlus)
    }

    @Test("Score 74 yields C")
    func score74IsC() {
        #expect(AuditGrade.from(score: 74) == .c)
    }

    @Test("Score 70 yields C")
    func score70IsC() {
        #expect(AuditGrade.from(score: 70) == .c)
    }

    @Test("Score 69 yields D")
    func score69IsD() {
        #expect(AuditGrade.from(score: 69) == .d)
    }

    @Test("Score 60 yields D")
    func score60IsD() {
        #expect(AuditGrade.from(score: 60) == .d)
    }

    @Test("Score 59 yields F")
    func score59IsF() {
        #expect(AuditGrade.from(score: 59) == .f)
    }

    @Test("Score 0 yields F")
    func score0IsF() {
        #expect(AuditGrade.from(score: 0) == .f)
    }

    @Test("A+ sorts before A (better grades are less-than)")
    func aPlusSortsBeforeA() {
        #expect(AuditGrade.aPlus < AuditGrade.a)
    }

    @Test("A sorts before B+")
    func aSortsBeforeBPlus() {
        #expect(AuditGrade.a < AuditGrade.bPlus)
    }

    @Test("B+ sorts before B")
    func bPlusSortsBeforeB() {
        #expect(AuditGrade.bPlus < AuditGrade.b)
    }

    @Test("B sorts before C+")
    func bSortsBeforeCPlus() {
        #expect(AuditGrade.b < AuditGrade.cPlus)
    }

    @Test("C+ sorts before C")
    func cPlusSortsBeforeC() {
        #expect(AuditGrade.cPlus < AuditGrade.c)
    }

    @Test("C sorts before D")
    func cSortsBeforeD() {
        #expect(AuditGrade.c < AuditGrade.d)
    }

    @Test("D sorts before F")
    func dSortsBeforeF() {
        #expect(AuditGrade.d < AuditGrade.f)
    }

    @Test("A+ is the best grade and sorts first")
    func aPlusSortsFirst() {
        for grade in AuditGrade.allCases where grade != .aPlus {
            #expect(AuditGrade.aPlus < grade)
        }
    }

    @Test("F is the worst grade and sorts last")
    func fSortsLast() {
        for grade in AuditGrade.allCases where grade != .f {
            #expect(grade < AuditGrade.f)
        }
    }

    @Test("Sorted grades are in best-to-worst order")
    func sortedGradesOrder() {
        let sorted = AuditGrade.allCases.sorted()
        let expected: [AuditGrade] = [.aPlus, .a, .bPlus, .b, .cPlus, .c, .d, .f]
        #expect(sorted == expected)
    }

    @Test("Grade raw values match expected strings")
    func rawValues() {
        #expect(AuditGrade.aPlus.rawValue == "A+")
        #expect(AuditGrade.a.rawValue == "A")
        #expect(AuditGrade.bPlus.rawValue == "B+")
        #expect(AuditGrade.b.rawValue == "B")
        #expect(AuditGrade.cPlus.rawValue == "C+")
        #expect(AuditGrade.c.rawValue == "C")
        #expect(AuditGrade.d.rawValue == "D")
        #expect(AuditGrade.f.rawValue == "F")
    }
}

// MARK: - AuditCriterion Tests

@Suite("AuditCriterion Tests")
struct AuditCriterionTests {

    @Test("Create criterion with all fields")
    func createCriterion() {
        let criterion = AuditCriterion(
            identifier: "metadata.artwork",
            name: "Artwork",
            category: .metadata,
            maxPoints: 5
        )
        #expect(criterion.identifier == "metadata.artwork")
        #expect(criterion.name == "Artwork")
        #expect(criterion.category == .metadata)
        #expect(criterion.maxPoints == 5)
    }

    @Test("Criterion is Equatable")
    func criterionEquatable() {
        let first = AuditCriterion(
            identifier: "test.id",
            name: "Test",
            category: .episodes,
            maxPoints: 10
        )
        let second = AuditCriterion(
            identifier: "test.id",
            name: "Test",
            category: .episodes,
            maxPoints: 10
        )
        #expect(first == second)
    }

    @Test("Criterion is Hashable")
    func criterionHashable() {
        let criterion = AuditCriterion(
            identifier: "compliance.locked",
            name: "Locked",
            category: .compliance,
            maxPoints: 4
        )
        let set: Set<AuditCriterion> = [criterion]
        #expect(set.contains(criterion))
    }

    @Test("Criterion with different identifiers are not equal")
    func differentCriteriaNotEqual() {
        let first = AuditCriterion(
            identifier: "metadata.artwork",
            name: "Artwork",
            category: .metadata,
            maxPoints: 5
        )
        let second = AuditCriterion(
            identifier: "metadata.description",
            name: "Description",
            category: .metadata,
            maxPoints: 4
        )
        #expect(first != second)
    }
}

// MARK: - AuditCriterionResult Tests

@Suite("AuditCriterionResult Tests")
struct AuditCriterionResultTests {

    private let sampleCriterion = AuditCriterion(
        identifier: "episodes.durations",
        name: "Durations",
        category: .episodes,
        maxPoints: 4
    )

    @Test("Create result with passed true")
    func passedResult() {
        let result = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 4,
            passed: true
        )
        #expect(result.criterion == sampleCriterion)
        #expect(result.pointsAwarded == 4)
        #expect(result.passed == true)
        #expect(result.detail == nil)
    }

    @Test("Create result with passed false")
    func failedResult() {
        let result = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 0,
            passed: false
        )
        #expect(result.pointsAwarded == 0)
        #expect(result.passed == false)
    }

    @Test("Result with detail message")
    func resultWithDetail() {
        let result = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 2,
            passed: false,
            detail: "3 of 10 episodes missing duration"
        )
        #expect(result.detail == "3 of 10 episodes missing duration")
        #expect(result.pointsAwarded == 2)
        #expect(result.passed == false)
    }

    @Test("Result with partial points")
    func partialPoints() {
        let result = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 3,
            passed: false,
            detail: "1 of 10 episodes missing duration"
        )
        #expect(result.pointsAwarded == 3)
        #expect(result.pointsAwarded < sampleCriterion.maxPoints)
    }

    @Test("Result is Equatable")
    func resultEquatable() {
        let first = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 4,
            passed: true
        )
        let second = AuditCriterionResult(
            criterion: sampleCriterion,
            pointsAwarded: 4,
            passed: true
        )
        #expect(first == second)
    }
}
