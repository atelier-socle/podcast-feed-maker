public extension Namespace.iTunes {

    /// A tag grouping all iTunes `<itunes:category>` elements for a podcast feed.
    ///
    /// This structure represents the classification of a podcast using Apple's official category taxonomy.
    ///
    /// Categories help listeners discover podcasts based on content type or subject area.
    /// Each podcast may declare multiple categories, but **Apple Podcasts displays only one** main category and one subcategory.
    ///
    /// - Important: This tag is defined by [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12),
    /// and is strongly recommended to improve discoverability.
    ///
    /// - Example:
    /// ```xml
    /// <itunes:category text="Technology">
    ///     <itunes:category text="Podcasting" />
    /// </itunes:category>
    /// ```
    struct Category: Hashable, Equatable, Sendable {

        /// The set of main iTunes categories with optional subcategories.
        ///
        /// Each `iTunesMainCategory` maps to Apple’s official taxonomy, and may include
        /// one or more predefined subcategories (also defined by Apple).
        public let categories: Set<iTunesMainCategory>

        /// Initializes an iTunes category block.
        ///
        /// - Parameter categories: The set of declared categories and their subcategories.
        public init(categories: Set<iTunesMainCategory>) {
            self.categories = categories
        }
    }
}

extension Namespace.iTunes.Category: XmlRepresentable {

    /// Generates the XML representation of all iTunes categories.
    ///
    /// - Returns: One or more `<itunes:category>` elements, properly indented and nested.
    /// - Throws: If any of the main or subcategories fail to render valid XML.
    public func xmlRepresentation() throws -> String {
        try """
        \(formattedTags())
        """
    }

    /// Converts all categories into indented XML strings.
    ///
    /// - Returns: A string with all category elements indented line by line.
    /// - Throws: If any category fails to produce valid XML.
    private func formattedTags() throws -> String {
        let tags: [String] = try categories.map {
            try $0.xmlRepresentation()
        }.compactMap { $0 }

        return tags.indentedTagsRepresentation
    }
}

public extension Namespace.iTunes {

    /// An enumeration of all official iTunes main podcast categories.
    ///
    /// Each case represents a top-level podcast category, as defined by Apple. Some categories include associated subcategories.
    /// These categories help podcast platforms classify and expose your podcast to the right audience.
    ///
    /// - SeeAlso: [Apple Podcasts Category Specification](https://podcasters.apple.com/support/893-itunes-podcast-categories)
    enum iTunesMainCategory: CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// The “Arts” category, with optional subcategories such as books, food, visual arts, etc.
        case arts(Set<ArtsCategory>)

        /// The “Business” category, including subcategories such as investing, marketing, and entrepreneurship.
        case business(Set<BusinessCategory>)

        /// The “Comedy” category.
        case comedy(Set<ComedyCategory>)

        /// The “Education” category.
        case education(Set<EducationCategory>)

        /// The “Fiction” category, including genres like drama and science fiction.
        case fiction(Set<FictionCategory>)

        /// The “Government” category (no subcategories).
        case government

        /// The “History” category (no subcategories).
        case history

        /// The “Health & Fitness” category.
        case healthAndFitness(Set<HealthAndFitnessCategory>)

        /// The “Kids & Family” category.
        case kidsAndFamily(Set<KidsAndFamilyCategory>)

        /// The “Leisure” category.
        case leisure(Set<LeisureCategory>)

        /// The “Music” category.
        case music(Set<MusicCategory>)

        /// The “News” category.
        case news(Set<NewsCategory>)

        /// The “Religion & Spirituality” category.
        case religionAndSpirituality(Set<ReligionAndSpiritualityCategory>)

        /// The “Science” category.
        case science(Set<ScienceCategory>)

        /// The “Society & Culture” category.
        case societyAndCulture(Set<SocietyAndCultureCategory>)

        /// The “Sports” category.
        case sports(Set<SportsCategory>)

        /// The “Technology” category (no subcategories).
        case technology

        /// The “True Crime” category (no subcategories).
        case trueCrime

        /// The “TV & Film” category.
        case tvAndFilm(Set<TvAndFilmCategory>)

        /// The full list of all possible main categories with their subcategories.
        ///
        /// This is used to expose the complete category tree to the feed builder.
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

        /// The text representation of the main category used in the XML `text` attribute.
        ///
        /// - Returns: A properly escaped display string, such as `"Health &amp; Fitness"` or `"Society &amp; Culture"`.
        var text: String {
            switch self {
            case .arts: "Arts"
            case .business: "Business"
            case .comedy: "Comedy"
            case .education: "Education"
            case .fiction: "Fiction"
            case .government: "Government"
            case .history: "History"
            case .healthAndFitness: "Health &amp; Fitness"
            case .kidsAndFamily: "Kids &amp; Family"
            case .leisure: "Leisure"
            case .music: "Music"
            case .news: "News"
            case .religionAndSpirituality: "Religion &amp; Spirituality"
            case .science: "Science"
            case .societyAndCulture: "Society &amp; Culture"
            case .sports: "Sports"
            case .technology: "Technology"
            case .trueCrime: "True Crime"
            case .tvAndFilm: "TV &amp; Film"
            }
        }

        /// Generates the inner XML subcategories for this main category.
        ///
        /// - Returns: A joined string of `<itunes:category>` tags for each subcategory, if present.
        /// - Throws: If a subcategory fails to generate valid XML.
        private func mappedSubCategories() throws -> String {
            switch self {
            case let .arts(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .business(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .comedy(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .education(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .fiction(values): try values.map { try $0.xmlRepresentation() }.joined()
            case .government, .history, .technology, .trueCrime: ""
            case let .healthAndFitness(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .kidsAndFamily(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .leisure(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .music(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .news(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .religionAndSpirituality(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .science(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .societyAndCulture(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .sports(values): try values.map { try $0.xmlRepresentation() }.joined()
            case let .tvAndFilm(values): try values.map { try $0.xmlRepresentation() }.joined()
            }
        }

        /// Generates the full `<itunes:category>` XML element for the main category and its optional subcategories.
        ///
        /// - Returns: A string representing the `<itunes:category>` XML element.
        /// - Throws: If any subcategory fails to encode.
        public func xmlRepresentation() throws -> String {
            try """
            \t<itunes:category text="\(text)">\(mappedSubCategories())</itunes:category>
            """
        }
    }
}

// MARK: iTunes Sub Categories for main category

public extension Namespace.iTunes.iTunesMainCategory {

    /// Subcategories for the main iTunes category `"Arts"`.
    ///
    /// These values refine the classification of the podcast under the broader "Arts" theme.
    enum ArtsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Books and literature-related content.
        case books = "Books"

        /// Design and visual creation.
        case design = "Design"

        /// Fashion and beauty-related shows.
        case fashionAndBeauty = "Fashion &amp; Beauty"

        /// Food-related culture and media.
        case food = "Food"

        /// Live or recorded performance arts.
        case performingArts = "Performing Arts"

        /// Visual arts including photography, painting, and more.
        case visualArts = "Visual Arts"

        /// Returns the `<itunes:category>` tag with the given subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category `"Business"`.
    ///
    /// Covers a broad range of professional topics such as entrepreneurship, marketing, and management.
    enum BusinessCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Career advice, job trends, and professional growth.
        case careers = "Careers"

        /// Starting, growing, and managing new businesses.
        case entrepreneurship = "Entrepreneurship"

        /// Investment strategies, markets, and financial instruments.
        case investing = "Investing"

        /// Business operations, leadership, and team management.
        case management = "Management"

        /// Branding, advertising, and digital strategy.
        case marketing = "Marketing"

        /// Running or working with non-profit organizations.
        case nonProfit = "Non-Profit"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category `"Comedy"`.
    ///
    /// These represent different comedic formats such as interviews, improv, or stand-up.
    enum ComedyCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Shows centered around humorous conversations with guests.
        case comedyInterviews = "Comedy Interviews"

        /// Improvised comedy, often unscripted and spontaneous.
        case improv = "Improv"

        /// Stand-up performances or recordings from comedians.
        case standUp = "Stand-Up"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category `"Education"`.
    ///
    /// Includes instructional content, personal development, and formal or informal learning formats.
    enum EducationCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Structured learning courses (academic or informal).
        case courses = "Courses"

        /// Instructional content and how-to guides.
        case howTo = "How To"

        /// Language acquisition and learning programs.
        case languageLearning = "Language Learning"

        /// Self-help and personal development content.
        case selfImprovement = "Self-Improvement"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Fiction".
    ///
    /// Represents narrative-driven content such as drama, science fiction, or comedic storytelling.
    enum FictionCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Fictional shows focused on humor and satire.
        case comedyFiction = "Comedy Fiction"

        /// Audio dramas and theatrical storytelling.
        case drama = "Drama"

        /// Science fiction or speculative narratives.
        case scienceFiction = "Science Fiction"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Health & Fitness".
    ///
    /// Includes physical and mental health, medicine, nutrition, and wellness topics.
    enum HealthAndFitnessCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Alternative medicine and holistic healing.
        case alternativeHealth = "Alternative Health"

        /// Exercise, sports performance, and personal fitness.
        case fitness = "Fitness"

        /// Medical topics and professional healthcare.
        case medicine = "Medicine"

        /// Mental wellness and psychology.
        case mentalHealth = "Mental Health"

        /// Healthy eating and dietary guidance.
        case nutrition = "Nutrition"

        /// Discussions around sexual wellness and identity.
        case sexuality = "Sexuality"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Kids & Family".
    ///
    /// Educational, entertaining, or parental content related to children and family life.
    enum KidsAndFamilyCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Learning content designed for kids.
        case educationForKids = "Education for Kids"

        /// Parenting advice and experiences.
        case parenting = "Parenting"

        /// Shows about animals and pets, often family-friendly.
        case petsAndAnimals = "Pets &amp; Animals"

        /// Audio stories tailored for children.
        case storiesForKids = "Stories for Kids"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Leisure".
    ///
    /// Topics related to personal hobbies, entertainment, and recreational activities.
    enum LeisureCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Anime, manga, and related fan culture.
        case animationAndManga = "Animation &amp; Manga"

        /// Cars, driving, and the automotive industry.
        case automotive = "Automotive"

        /// Aircrafts, pilots, and aviation topics.
        case aviation = "Aviation"

        /// Crafts and DIY activities.
        case crafts = "Crafts"

        /// Board games, card games, and analog gaming.
        case games = "Games"

        /// Hobbies and niche interests.
        case hobbies = "Hobbies"

        /// Gardening, home design, and improvement.
        case homeAndGarden = "Home &amp; Garden"

        /// Console and PC video games.
        case videoGames = "Video Games"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Music".
    ///
    /// Covers various facets of the music industry, including commentary, history, and artist interviews.
    enum MusicCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Commentary on music trends, reviews, and cultural impact.
        case musicCommentary = "Music Commentary"

        /// Exploration of music history, genres, and influential artists.
        case musicHistory = "Music History"

        /// Interviews with musicians, producers, and music professionals.
        case musicInterviews = "Music Interviews"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "News".
    ///
    /// Includes commentary, business news, entertainment, and politics.
    enum NewsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Coverage of business markets, finance, and economic affairs.
        case businessNews = "Business News"

        /// Daily news briefings or rapid updates.
        case dailyNews = "Daily News"

        /// Entertainment industry updates and celebrity news.
        case entertainmentNews = "Entertainment News"

        /// Opinion pieces and political commentary.
        case newsCommentary = "News Commentary"

        /// Political news and government-related reporting.
        case politics = "Politics"

        /// Sports news and athlete updates.
        case sportsNews = "Sports News"

        /// Technology news and innovations.
        case techNews = "Tech News"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Religion & Spirituality".
    ///
    /// Includes content from major world religions, spiritual exploration, and interfaith dialogue.
    enum ReligionAndSpiritualityCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Topics specific to Buddhism.
        case buddhism = "Buddhism"

        /// Content from or about Christianity.
        case christianity = "Christianity"

        /// Hindu traditions and spiritual teachings.
        case hinduism = "Hinduism"

        /// Islam-related topics and interpretations.
        case islam = "Islam"

        /// Content related to Judaism.
        case judaism = "Judaism"

        /// General religious themes not tied to a single belief system.
        case religion = "Religion"

        /// Spirituality, mindfulness, and metaphysical topics.
        case spirituality = "Spirituality"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Science".
    ///
    /// Topics include academic research, natural sciences, and the study of human behavior.
    enum ScienceCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Astronomy and space science.
        case astronomy = "Astronomy"

        /// Chemistry topics and experiments.
        case chemistry = "Chemistry"

        /// Geology, meteorology, and environmental studies.
        case earthSciences = "Earth Sciences"

        /// Biology, genetics, and life systems.
        case lifeSciences = "Life Sciences"

        /// Mathematics education and applied math.
        case mathematics = "Mathematics"

        /// Broad range of natural science disciplines.
        case naturalSciences = "Natural Sciences"

        /// Ecology, animals, and nature-focused content.
        case nature = "Nature"

        /// Physics concepts, theory, and applications.
        case physics = "Physics"

        /// Psychology, sociology, and social behavior.
        case socialSciences = "Social Sciences"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Society & Culture".
    ///
    /// Explores human relationships, culture, travel, and philosophical perspectives.
    enum SocietyAndCultureCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Documentary-style narratives and investigations.
        case documentary = "Documentary"

        /// Personal stories, journals, and life experiences.
        case personalJournals = "Personal Journals"

        /// Exploration of philosophical ideas and ethics.
        case philosophy = "Philosophy"

        /// Cultural discovery, destinations, and travel.
        case placesAndTravel = "Places &amp; Travel"

        /// Topics related to love, friendships, and social dynamics.
        case relationships = "Relationships"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "Sports".
    ///
    /// Covers professional, amateur, and niche sports, as well as fan culture and commentary.
    enum SportsCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Baseball games, leagues, and analysis.
        case baseball = "Baseball"

        /// Basketball news and commentary.
        case basketball = "Basketball"

        /// Cricket matches, formats, and global updates.
        case cricket = "Cricket"

        /// Fantasy sports leagues and strategy.
        case fantasySports = "Fantasy Sports"

        /// American or international football content.
        case football = "Football"

        /// Golf tournaments, techniques, and players.
        case golf = "Golf"

        /// Ice hockey events and discussions.
        case hockey = "Hockey"

        /// Rugby news and gameplay.
        case rugby = "Rugby"

        /// Running techniques, marathons, and training.
        case running = "Running"

        /// Soccer leagues, highlights, and culture.
        case soccer = "Soccer"

        /// Competitive and recreational swimming.
        case swimming = "Swimming"

        /// Tennis matches, tournaments, and analysis.
        case tennis = "Tennis"

        /// Beach or indoor volleyball.
        case volleyball = "Volleyball"

        /// Outdoor adventure, survival, and hiking.
        case wilderness = "Wilderness"

        /// Wrestling entertainment or competitive coverage.
        case wrestling = "Wrestling"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }

    /// Subcategories under the main iTunes category "TV & Film".
    ///
    /// Focused on television, cinema, reviews, interviews, and fan discussion.
    enum TvAndFilmCategory: String, CaseIterable, Hashable, Equatable, Sendable, XmlRepresentable {

        /// Post-episode commentary or recaps.
        case afterShows = "After Shows"

        /// History and evolution of film as an art form.
        case filmHistory = "Film History"

        /// Interviews with actors, directors, and creators.
        case filmInterviews = "Film Interviews"

        /// Reviews and critiques of movies.
        case filmReviews = "Film Reviews"

        /// Analysis and commentary on television programs.
        case tvReviews = "TV Reviews"

        /// Generates the `<itunes:category>` tag for this subcategory.
        ///
        /// - Returns: An XML string representing the subcategory.
        public func xmlRepresentation() throws -> String {
            """
            <itunes:category text="\(rawValue)" />
            """
        }
    }
}
