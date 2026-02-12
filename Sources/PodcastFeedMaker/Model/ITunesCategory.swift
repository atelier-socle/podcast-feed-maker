import Foundation

/// An `<itunes:category>` element from the Apple Podcasts namespace.
///
/// Represents a podcast category with an optional set of nested subcategories.
/// Apple Podcasts displays one primary category and one subcategory.
///
/// Use the ``Category`` enum and per-category subcategory enums for type-safe
/// creation via the static factory methods. String-based initialization is also
/// available for parsing flexibility.
///
/// Example:
/// ```xml
/// <itunes:category text="Technology">
///   <itunes:category text="Podcasting" />
/// </itunes:category>
/// ```
///
/// - SeeAlso: [Apple Podcasts Categories](https://podcasters.apple.com/support/1691-apple-podcasts-categories)
public struct ITunesCategory: Sendable, Hashable, Equatable, Codable {

    /// The category name (e.g., `"Technology"`, `"Arts"`).
    public var text: String

    /// Nested subcategories (e.g., `"Podcasting"` under `"Technology"`).
    public var subcategories: [ITunesCategory]

    /// Creates a new iTunes category from raw strings.
    ///
    /// - Parameters:
    ///   - text: The category name.
    ///   - subcategories: Nested subcategories. Defaults to empty.
    public init(text: String, subcategories: [ITunesCategory] = []) {
        self.text = text
        self.subcategories = subcategories
    }

    /// Creates a new iTunes category from a known ``Category`` enum value.
    ///
    /// - Parameter category: A known Apple Podcasts category.
    public init(_ category: Category) {
        self.text = category.rawValue
        self.subcategories = []
    }
}

// MARK: - Category

extension ITunesCategory {

    /// All 19 official Apple Podcasts main categories.
    ///
    /// - SeeAlso: [Apple Podcasts Categories](https://podcasters.apple.com/support/1691-apple-podcasts-categories)
    public enum Category: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case arts = "Arts"
        case business = "Business"
        case comedy = "Comedy"
        case education = "Education"
        case fiction = "Fiction"
        case government = "Government"
        case healthAndFitness = "Health & Fitness"
        case history = "History"
        case kidsAndFamily = "Kids & Family"
        case leisure = "Leisure"
        case music = "Music"
        case news = "News"
        case religionAndSpirituality = "Religion & Spirituality"
        case science = "Science"
        case societyAndCulture = "Society & Culture"
        case sports = "Sports"
        case technology = "Technology"
        case trueCrime = "True Crime"
        case tvAndFilm = "TV & Film"
    }
}

// MARK: - Subcategory Enums

extension ITunesCategory {

    /// Subcategories for ``Category/arts``.
    public enum ArtsSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case books = "Books"
        case design = "Design"
        case fashionAndBeauty = "Fashion & Beauty"
        case food = "Food"
        case performingArts = "Performing Arts"
        case visualArts = "Visual Arts"
    }

    /// Subcategories for ``Category/business``.
    public enum BusinessSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case careers = "Careers"
        case entrepreneurship = "Entrepreneurship"
        case investing = "Investing"
        case management = "Management"
        case marketing = "Marketing"
        case nonProfit = "Non-Profit"
    }

    /// Subcategories for ``Category/comedy``.
    public enum ComedySubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case comedyInterviews = "Comedy Interviews"
        case improv = "Improv"
        case standUp = "Stand-Up"
    }

    /// Subcategories for ``Category/education``.
    public enum EducationSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case courses = "Courses"
        case howTo = "How To"
        case languageLearning = "Language Learning"
        case selfImprovement = "Self-Improvement"
    }

    /// Subcategories for ``Category/fiction``.
    public enum FictionSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case comedyFiction = "Comedy Fiction"
        case drama = "Drama"
        case scienceFiction = "Science Fiction"
    }

    /// Subcategories for ``Category/healthAndFitness``.
    public enum HealthAndFitnessSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case alternativeHealth = "Alternative Health"
        case fitness = "Fitness"
        case medicine = "Medicine"
        case mentalHealth = "Mental Health"
        case nutrition = "Nutrition"
        case sexuality = "Sexuality"
    }

    /// Subcategories for ``Category/kidsAndFamily``.
    public enum KidsAndFamilySubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case educationForKids = "Education for Kids"
        case parenting = "Parenting"
        case petsAndAnimals = "Pets & Animals"
        case storiesForKids = "Stories for Kids"
    }

    /// Subcategories for ``Category/leisure``.
    public enum LeisureSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case animationAndManga = "Animation & Manga"
        case automotive = "Automotive"
        case aviation = "Aviation"
        case crafts = "Crafts"
        case games = "Games"
        case hobbies = "Hobbies"
        case homeAndGarden = "Home & Garden"
        case videoGames = "Video Games"
    }

    /// Subcategories for ``Category/music``.
    public enum MusicSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case musicCommentary = "Music Commentary"
        case musicHistory = "Music History"
        case musicInterviews = "Music Interviews"
    }

    /// Subcategories for ``Category/news``.
    public enum NewsSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case businessNews = "Business News"
        case dailyNews = "Daily News"
        case entertainmentNews = "Entertainment News"
        case newsCommentary = "News Commentary"
        case politics = "Politics"
        case sportsNews = "Sports News"
        case techNews = "Tech News"
    }

    /// Subcategories for ``Category/religionAndSpirituality``.
    public enum ReligionAndSpiritualitySubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case buddhism = "Buddhism"
        case christianity = "Christianity"
        case hinduism = "Hinduism"
        case islam = "Islam"
        case judaism = "Judaism"
        case religion = "Religion"
        case spirituality = "Spirituality"
    }

    /// Subcategories for ``Category/science``.
    public enum ScienceSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case astronomy = "Astronomy"
        case chemistry = "Chemistry"
        case earthSciences = "Earth Sciences"
        case lifeSciences = "Life Sciences"
        case mathematics = "Mathematics"
        case naturalSciences = "Natural Sciences"
        case nature = "Nature"
        case physics = "Physics"
        case socialSciences = "Social Sciences"
    }

    /// Subcategories for ``Category/societyAndCulture``.
    public enum SocietyAndCultureSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case documentary = "Documentary"
        case personalJournals = "Personal Journals"
        case philosophy = "Philosophy"
        case placesAndTravel = "Places & Travel"
        case relationships = "Relationships"
    }

    /// Subcategories for ``Category/sports``.
    public enum SportsSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case baseball = "Baseball"
        case basketball = "Basketball"
        case cricket = "Cricket"
        case fantasySports = "Fantasy Sports"
        case football = "Football"
        case golf = "Golf"
        case hockey = "Hockey"
        case rugby = "Rugby"
        case running = "Running"
        case soccer = "Soccer"
        case swimming = "Swimming"
        case tennis = "Tennis"
        case volleyball = "Volleyball"
        case wilderness = "Wilderness"
        case wrestling = "Wrestling"
    }

    /// Subcategories for ``Category/tvAndFilm``.
    public enum TvAndFilmSubcategory: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case afterShows = "After Shows"
        case filmHistory = "Film History"
        case filmInterviews = "Film Interviews"
        case filmReviews = "Film Reviews"
        case tvReviews = "TV Reviews"
    }
}

// MARK: - Static Factory Methods

extension ITunesCategory {

    /// Creates an Arts category with an optional subcategory.
    public static func arts(_ subcategory: ArtsSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.arts.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Business category with an optional subcategory.
    public static func business(_ subcategory: BusinessSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.business.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Comedy category with an optional subcategory.
    public static func comedy(_ subcategory: ComedySubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.comedy.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates an Education category with an optional subcategory.
    public static func education(_ subcategory: EducationSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.education.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Fiction category with an optional subcategory.
    public static func fiction(_ subcategory: FictionSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.fiction.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Government category (no subcategories).
    public static var government: ITunesCategory {
        ITunesCategory(.government)
    }

    /// Creates a Health & Fitness category with an optional subcategory.
    public static func healthAndFitness(_ subcategory: HealthAndFitnessSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.healthAndFitness.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a History category (no subcategories).
    public static var history: ITunesCategory {
        ITunesCategory(.history)
    }

    /// Creates a Kids & Family category with an optional subcategory.
    public static func kidsAndFamily(_ subcategory: KidsAndFamilySubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.kidsAndFamily.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Leisure category with an optional subcategory.
    public static func leisure(_ subcategory: LeisureSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.leisure.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Music category with an optional subcategory.
    public static func music(_ subcategory: MusicSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.music.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a News category with an optional subcategory.
    public static func news(_ subcategory: NewsSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.news.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Religion & Spirituality category with an optional subcategory.
    public static func religionAndSpirituality(
        _ subcategory: ReligionAndSpiritualitySubcategory? = nil
    ) -> ITunesCategory {
        ITunesCategory(
            text: Category.religionAndSpirituality.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Science category with an optional subcategory.
    public static func science(_ subcategory: ScienceSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.science.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Society & Culture category with an optional subcategory.
    public static func societyAndCulture(
        _ subcategory: SocietyAndCultureSubcategory? = nil
    ) -> ITunesCategory {
        ITunesCategory(
            text: Category.societyAndCulture.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Sports category with an optional subcategory.
    public static func sports(_ subcategory: SportsSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.sports.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }

    /// Creates a Technology category (no subcategories).
    public static var technology: ITunesCategory {
        ITunesCategory(.technology)
    }

    /// Creates a True Crime category (no subcategories).
    public static var trueCrime: ITunesCategory {
        ITunesCategory(.trueCrime)
    }

    /// Creates a TV & Film category with an optional subcategory.
    public static func tvAndFilm(_ subcategory: TvAndFilmSubcategory? = nil) -> ITunesCategory {
        ITunesCategory(
            text: Category.tvAndFilm.rawValue,
            subcategories: subcategory.map { [ITunesCategory(text: $0.rawValue)] } ?? []
        )
    }
}

// MARK: - Validation Support

extension ITunesCategory {

    /// Returns the valid subcategory strings for a given main category.
    ///
    /// Categories with no subcategories return an empty array.
    ///
    /// - Parameter category: The main category to look up.
    /// - Returns: An array of valid subcategory name strings.
    public static func validSubcategories(for category: Category) -> [String] {  // swiftlint:disable:this cyclomatic_complexity
        switch category {
        case .arts: ArtsSubcategory.allCases.map(\.rawValue)
        case .business: BusinessSubcategory.allCases.map(\.rawValue)
        case .comedy: ComedySubcategory.allCases.map(\.rawValue)
        case .education: EducationSubcategory.allCases.map(\.rawValue)
        case .fiction: FictionSubcategory.allCases.map(\.rawValue)
        case .government: []
        case .healthAndFitness: HealthAndFitnessSubcategory.allCases.map(\.rawValue)
        case .history: []
        case .kidsAndFamily: KidsAndFamilySubcategory.allCases.map(\.rawValue)
        case .leisure: LeisureSubcategory.allCases.map(\.rawValue)
        case .music: MusicSubcategory.allCases.map(\.rawValue)
        case .news: NewsSubcategory.allCases.map(\.rawValue)
        case .religionAndSpirituality: ReligionAndSpiritualitySubcategory.allCases.map(\.rawValue)
        case .science: ScienceSubcategory.allCases.map(\.rawValue)
        case .societyAndCulture: SocietyAndCultureSubcategory.allCases.map(\.rawValue)
        case .sports: SportsSubcategory.allCases.map(\.rawValue)
        case .technology: []
        case .trueCrime: []
        case .tvAndFilm: TvAndFilmSubcategory.allCases.map(\.rawValue)
        }
    }
}
