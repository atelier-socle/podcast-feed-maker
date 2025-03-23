public extension Namespace.iTunes {
    struct Category: Hashable, Equatable, Sendable {
        public let categories: Set<iTunesMainCategory>

        public init(categories: Set<iTunesMainCategory>) {
            self.categories = categories
        }
    }
}

extension Namespace.iTunes.Category: XmlRepresentable {
    private func formattedTags() throws -> String {
        let tags: [String] = try categories.map {
            try $0.xmlRepresentation()
        }.compactMap { $0 }

        return tags.indentedTagsRepresentation
    }

    public func xmlRepresentation() throws -> String {
        try """
        \(formattedTags())
        """
    }
}

extension Namespace.iTunes {
    public enum iTunesMainCategory: CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        public static let allCases: [iTunesMainCategory] = [
            .arts(.init(ArtsCategory.allCases)),
            .business(.init(BusinessCategory.allCases)),
            .comedy(.init(ComedyCategory.allCases)),
            .education(.init(EducationCategory.allCases)),
            .fiction(.init(FictionCategory.allCases)),
            .government,
            .history,
            .healthAndFitness(.init(HealthAndFitnessCategory.allCases)),
            .kidsAndFamily(.init(KidsAndFamilyCategory.allCases)),
            .leisure(.init(LeisureCategory.allCases)),
            .music(.init(MusicCategory.allCases)),
            .news(.init(NewsCategory.allCases)),
            .religionAndSpirituality(.init(ReligionAndSpiritualityCategory.allCases)),
            .science(.init(ScienceCategory.allCases)),
            .societyAndCulture(.init(SocietyAndCultureCategory.allCases)),
            .sports(.init(SportsCategory.allCases)),
            .technology,
            .trueCrime,
            .tvAndFilm(.init(TvAndFilmCategory.allCases))
        ]
        
        case arts(Set<ArtsCategory>)
        case business(Set<BusinessCategory>)
        case comedy(Set<ComedyCategory>)
        case education(Set<EducationCategory>)
        case fiction(Set<FictionCategory>)
        case government
        case history
        case healthAndFitness(Set<HealthAndFitnessCategory>)
        case kidsAndFamily(Set<KidsAndFamilyCategory>)
        case leisure(Set<LeisureCategory>)
        case music(Set<MusicCategory>)
        case news(Set<NewsCategory>)
        case religionAndSpirituality(Set<ReligionAndSpiritualityCategory>)
        case science(Set<ScienceCategory>)
        case societyAndCulture(Set<SocietyAndCultureCategory>)
        case sports(Set<SportsCategory>)
        case technology
        case trueCrime
        case tvAndFilm(Set<TvAndFilmCategory>)
        
        var text: String {
            switch self {
            case .arts:
                "Arts"
            case .business:
                "Business"
            case .comedy:
                "Comedy"
            case .education:
                "Education"
            case .fiction:
                "Fiction"
            case .government:
                "Government"
            case .history:
                "History"
            case .healthAndFitness:
                "Health &amp; Fitness"
            case .kidsAndFamily:
                "Kids &amp; Family"
            case .leisure:
                "Leisure"
            case .music:
                "Music"
            case .news:
                "News"
            case .religionAndSpirituality:
                "Religion &amp; Spirituality"
            case .science:
                "Science"
            case .societyAndCulture:
                "Society &amp; Culture"
            case .sports:
                "Sports"
            case .technology:
                "Technology"
            case .trueCrime:
                "True Crime"
            case .tvAndFilm:
                "TV &amp; Film"
            }
        }
        
        private func mappedSubCategories() throws -> String {
            switch self {
            case let .arts(artsCategories):
                try artsCategories.map { try $0.xmlRepresentation() }.joined()
            case let .business(businessCategories):
                try businessCategories.map { try $0.xmlRepresentation() }.joined()
            case let .comedy(comedyCategories):
                try comedyCategories.map { try $0.xmlRepresentation() }.joined()
            case let .education(educationCategories):
                try educationCategories.map { try $0.xmlRepresentation() }.joined()
            case let .fiction(fictionCategories):
                try fictionCategories.map { try $0.xmlRepresentation() }.joined()
            case .government, .history:
                ""
            case let .healthAndFitness(healthAndFitnessCategories):
                try healthAndFitnessCategories.map { try $0.xmlRepresentation() }.joined()
            case let .kidsAndFamily(kidsAndFamilyCategories):
                try kidsAndFamilyCategories.map { try $0.xmlRepresentation() }.joined()
            case let .leisure(leisureCategories):
                try leisureCategories.map { try $0.xmlRepresentation() }.joined()
            case let .music(musicCategories):
                try musicCategories.map { try $0.xmlRepresentation() }.joined()
            case let .news(newsCategories):
                try newsCategories.map { try $0.xmlRepresentation() }.joined()
            case let .religionAndSpirituality(religionAndSpiritualityCategories):
                try religionAndSpiritualityCategories.map { try $0.xmlRepresentation() }.joined()
            case let .science(scienceCategories):
                try scienceCategories.map { try $0.xmlRepresentation() }.joined()
            case let .societyAndCulture(societyAndCultureCategories):
                try societyAndCultureCategories.map { try $0.xmlRepresentation() }.joined()
            case let .sports(sportsCategories):
                try sportsCategories.map { try $0.xmlRepresentation() }.joined()
            case .technology, .trueCrime:
                ""
            case let .tvAndFilm(tvAndFilmCategories):
                try tvAndFilmCategories.map { try $0.xmlRepresentation() }.joined()
            }
        }
        
        public func xmlRepresentation() throws -> String {
            try """
        \t<itunes:category text="\(text)">\(mappedSubCategories())</itunes:category>
        """
        }
    }
}

// MARK: iTunes Sub Categories for main category

public extension Namespace.iTunes.iTunesMainCategory {
    enum ArtsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case books = "Books"
        case design = "Design"
        case fashionAndBeauty = "Fashion &amp; Beauty"
        case food = "Food"
        case performingArts = "Performing Arts"
        case visualArts = "Visual Arts"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum BusinessCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case careers = "Careers"
        case entrepreneurship = "Entrepreneurship"
        case investing = "Investing"
        case management = "Management"
        case marketing = "Marketing"
        case nonProfit = "Non-Profit"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum ComedyCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case comedyInterviews = "Comedy Interviews"
        case improv = "Improv"
        case standUp = "Stand-Up"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum EducationCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case courses = "Courses"
        case howTo = "How To"
        case languageLearning = "Language Learning"
        case selfImprovement = "Self-Improvement"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum FictionCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case comedyFiction = "Comedy Fiction"
        case drama = "Drama"
        case scienceFiction = "Science Fiction"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum HealthAndFitnessCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case alternativeHealth = "Alternative Health"
        case fitness = "Fitness"
        case medicine = "Medicine"
        case mentalHealth = "Mental Health"
        case nutrition = "Nutrition"
        case sexuality = "Sexuality"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum KidsAndFamilyCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case educationForKids = "Education for Kids"
        case parenting = "Parenting"
        case petsAndAnimals = "Pets &amp; Animals"
        case storiesForKids = "Stories for Kids"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum LeisureCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case animationAndManga = "Animation &amp; Manga"
        case automotive = "Automotive"
        case aviation = "Aviation"
        case crafts = "Crafts"
        case games = "Games"
        case hobbies = "Hobbies"
        case homeAndGarden = "Home &amp; Garden"
        case videoGames = "Video Games"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum MusicCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case musicCommentary = "Music Commentary"
        case musicHistory = "Music History"
        case musicInterviews = "Music Interviews"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum NewsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case businessNews = "Business News"
        case dailyNews = "Daily News"
        case entertainmentNews = "Entertainment News"
        case newsCommentary = "News Commentary"
        case politics = "Politics"
        case sportsNews = "Sports News"
        case techNews = "Tech News"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum ReligionAndSpiritualityCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case buddhism = "Buddhism"
        case christianity = "Christianity"
        case hinduism = "Hinduism"
        case islam = "Islam"
        case judaism = "Judaism"
        case religion = "Religion"
        case spirituality = "Spirituality"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum ScienceCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case astronomy = "Astronomy"
        case chemistry = "Chemistry"
        case earthSciences = "Earth Sciences"
        case lifeSciences = "Life Sciences"
        case mathematics = "Mathematics"
        case naturalSciences = "Natural Sciences"
        case nature = "Nature"
        case physics = "Physics"
        case socialSciences = "Social Sciences"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum SocietyAndCultureCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case documentary = "Documentary"
        case personalJournals = "Personal Journals"
        case philosophy = "Philosophy"
        case placesAndTravel = "Places &amp; Travel"
        case relationships = "Relationships"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum SportsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
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

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    enum TvAndFilmCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {
        case afterShows = "After Shows"
        case filmHistory = "Film History"
        case filmInterviews = "Film Interviews"
        case filmReviews = "Film Reviews"
        case tvReviews = "TV Reviews"

        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }
}
