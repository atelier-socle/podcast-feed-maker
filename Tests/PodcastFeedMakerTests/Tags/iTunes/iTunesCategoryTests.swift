import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesCategoryTests {

    // MARK: - Category Enum

    @Test
    func test_category_allCases_contains19Categories() {
        #expect(ITunesCategory.Category.allCases.count == 19)
    }

    @Test
    func test_category_rawValues() {
        #expect(ITunesCategory.Category.arts.rawValue == "Arts")
        #expect(ITunesCategory.Category.business.rawValue == "Business")
        #expect(ITunesCategory.Category.comedy.rawValue == "Comedy")
        #expect(ITunesCategory.Category.education.rawValue == "Education")
        #expect(ITunesCategory.Category.fiction.rawValue == "Fiction")
        #expect(ITunesCategory.Category.government.rawValue == "Government")
        #expect(ITunesCategory.Category.healthAndFitness.rawValue == "Health & Fitness")
        #expect(ITunesCategory.Category.history.rawValue == "History")
        #expect(ITunesCategory.Category.kidsAndFamily.rawValue == "Kids & Family")
        #expect(ITunesCategory.Category.leisure.rawValue == "Leisure")
        #expect(ITunesCategory.Category.music.rawValue == "Music")
        #expect(ITunesCategory.Category.news.rawValue == "News")
        #expect(ITunesCategory.Category.religionAndSpirituality.rawValue == "Religion & Spirituality")
        #expect(ITunesCategory.Category.science.rawValue == "Science")
        #expect(ITunesCategory.Category.societyAndCulture.rawValue == "Society & Culture")
        #expect(ITunesCategory.Category.sports.rawValue == "Sports")
        #expect(ITunesCategory.Category.technology.rawValue == "Technology")
        #expect(ITunesCategory.Category.trueCrime.rawValue == "True Crime")
        #expect(ITunesCategory.Category.tvAndFilm.rawValue == "TV & Film")
    }

    // MARK: - Subcategory Enum Cases

    @Test
    func test_artsSubcategory_allCases() {
        #expect(ITunesCategory.ArtsSubcategory.allCases.count == 6)
        #expect(ITunesCategory.ArtsSubcategory.books.rawValue == "Books")
        #expect(ITunesCategory.ArtsSubcategory.design.rawValue == "Design")
        #expect(ITunesCategory.ArtsSubcategory.fashionAndBeauty.rawValue == "Fashion & Beauty")
        #expect(ITunesCategory.ArtsSubcategory.food.rawValue == "Food")
        #expect(ITunesCategory.ArtsSubcategory.performingArts.rawValue == "Performing Arts")
        #expect(ITunesCategory.ArtsSubcategory.visualArts.rawValue == "Visual Arts")
    }

    @Test
    func test_businessSubcategory_allCases() {
        #expect(ITunesCategory.BusinessSubcategory.allCases.count == 6)
        #expect(ITunesCategory.BusinessSubcategory.careers.rawValue == "Careers")
        #expect(ITunesCategory.BusinessSubcategory.entrepreneurship.rawValue == "Entrepreneurship")
        #expect(ITunesCategory.BusinessSubcategory.investing.rawValue == "Investing")
        #expect(ITunesCategory.BusinessSubcategory.management.rawValue == "Management")
        #expect(ITunesCategory.BusinessSubcategory.marketing.rawValue == "Marketing")
        #expect(ITunesCategory.BusinessSubcategory.nonProfit.rawValue == "Non-Profit")
    }

    @Test
    func test_comedySubcategory_allCases() {
        #expect(ITunesCategory.ComedySubcategory.allCases.count == 3)
        #expect(ITunesCategory.ComedySubcategory.comedyInterviews.rawValue == "Comedy Interviews")
        #expect(ITunesCategory.ComedySubcategory.improv.rawValue == "Improv")
        #expect(ITunesCategory.ComedySubcategory.standUp.rawValue == "Stand-Up")
    }

    @Test
    func test_educationSubcategory_allCases() {
        #expect(ITunesCategory.EducationSubcategory.allCases.count == 4)
        #expect(ITunesCategory.EducationSubcategory.courses.rawValue == "Courses")
        #expect(ITunesCategory.EducationSubcategory.howTo.rawValue == "How To")
        #expect(ITunesCategory.EducationSubcategory.languageLearning.rawValue == "Language Learning")
        #expect(ITunesCategory.EducationSubcategory.selfImprovement.rawValue == "Self-Improvement")
    }

    @Test
    func test_fictionSubcategory_allCases() {
        #expect(ITunesCategory.FictionSubcategory.allCases.count == 3)
        #expect(ITunesCategory.FictionSubcategory.comedyFiction.rawValue == "Comedy Fiction")
        #expect(ITunesCategory.FictionSubcategory.drama.rawValue == "Drama")
        #expect(ITunesCategory.FictionSubcategory.scienceFiction.rawValue == "Science Fiction")
    }

    @Test
    func test_healthAndFitnessSubcategory_allCases() {
        #expect(ITunesCategory.HealthAndFitnessSubcategory.allCases.count == 6)
        #expect(ITunesCategory.HealthAndFitnessSubcategory.alternativeHealth.rawValue == "Alternative Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.fitness.rawValue == "Fitness")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.medicine.rawValue == "Medicine")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.mentalHealth.rawValue == "Mental Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.nutrition.rawValue == "Nutrition")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.sexuality.rawValue == "Sexuality")
    }

    @Test
    func test_kidsAndFamilySubcategory_allCases() {
        #expect(ITunesCategory.KidsAndFamilySubcategory.allCases.count == 4)
        #expect(ITunesCategory.KidsAndFamilySubcategory.educationForKids.rawValue == "Education for Kids")
        #expect(ITunesCategory.KidsAndFamilySubcategory.parenting.rawValue == "Parenting")
        #expect(ITunesCategory.KidsAndFamilySubcategory.petsAndAnimals.rawValue == "Pets & Animals")
        #expect(ITunesCategory.KidsAndFamilySubcategory.storiesForKids.rawValue == "Stories for Kids")
    }

    @Test
    func test_leisureSubcategory_allCases() {
        #expect(ITunesCategory.LeisureSubcategory.allCases.count == 8)
        #expect(ITunesCategory.LeisureSubcategory.animationAndManga.rawValue == "Animation & Manga")
        #expect(ITunesCategory.LeisureSubcategory.automotive.rawValue == "Automotive")
        #expect(ITunesCategory.LeisureSubcategory.aviation.rawValue == "Aviation")
        #expect(ITunesCategory.LeisureSubcategory.crafts.rawValue == "Crafts")
        #expect(ITunesCategory.LeisureSubcategory.games.rawValue == "Games")
        #expect(ITunesCategory.LeisureSubcategory.hobbies.rawValue == "Hobbies")
        #expect(ITunesCategory.LeisureSubcategory.homeAndGarden.rawValue == "Home & Garden")
        #expect(ITunesCategory.LeisureSubcategory.videoGames.rawValue == "Video Games")
    }

    @Test
    func test_musicSubcategory_allCases() {
        #expect(ITunesCategory.MusicSubcategory.allCases.count == 3)
        #expect(ITunesCategory.MusicSubcategory.musicCommentary.rawValue == "Music Commentary")
        #expect(ITunesCategory.MusicSubcategory.musicHistory.rawValue == "Music History")
        #expect(ITunesCategory.MusicSubcategory.musicInterviews.rawValue == "Music Interviews")
    }

    @Test
    func test_newsSubcategory_allCases() {
        #expect(ITunesCategory.NewsSubcategory.allCases.count == 7)
        #expect(ITunesCategory.NewsSubcategory.businessNews.rawValue == "Business News")
        #expect(ITunesCategory.NewsSubcategory.dailyNews.rawValue == "Daily News")
        #expect(ITunesCategory.NewsSubcategory.entertainmentNews.rawValue == "Entertainment News")
        #expect(ITunesCategory.NewsSubcategory.newsCommentary.rawValue == "News Commentary")
        #expect(ITunesCategory.NewsSubcategory.politics.rawValue == "Politics")
        #expect(ITunesCategory.NewsSubcategory.sportsNews.rawValue == "Sports News")
        #expect(ITunesCategory.NewsSubcategory.techNews.rawValue == "Tech News")
    }

    @Test
    func test_religionAndSpiritualitySubcategory_allCases() {
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.allCases.count == 7)
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.buddhism.rawValue == "Buddhism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.christianity.rawValue == "Christianity")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.hinduism.rawValue == "Hinduism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.islam.rawValue == "Islam")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.judaism.rawValue == "Judaism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.religion.rawValue == "Religion")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.spirituality.rawValue == "Spirituality")
    }

    @Test
    func test_scienceSubcategory_allCases() {
        #expect(ITunesCategory.ScienceSubcategory.allCases.count == 9)
        #expect(ITunesCategory.ScienceSubcategory.astronomy.rawValue == "Astronomy")
        #expect(ITunesCategory.ScienceSubcategory.chemistry.rawValue == "Chemistry")
        #expect(ITunesCategory.ScienceSubcategory.earthSciences.rawValue == "Earth Sciences")
        #expect(ITunesCategory.ScienceSubcategory.lifeSciences.rawValue == "Life Sciences")
        #expect(ITunesCategory.ScienceSubcategory.mathematics.rawValue == "Mathematics")
        #expect(ITunesCategory.ScienceSubcategory.naturalSciences.rawValue == "Natural Sciences")
        #expect(ITunesCategory.ScienceSubcategory.nature.rawValue == "Nature")
        #expect(ITunesCategory.ScienceSubcategory.physics.rawValue == "Physics")
        #expect(ITunesCategory.ScienceSubcategory.socialSciences.rawValue == "Social Sciences")
    }

    @Test
    func test_societyAndCultureSubcategory_allCases() {
        #expect(ITunesCategory.SocietyAndCultureSubcategory.allCases.count == 5)
        #expect(ITunesCategory.SocietyAndCultureSubcategory.documentary.rawValue == "Documentary")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.personalJournals.rawValue == "Personal Journals")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.philosophy.rawValue == "Philosophy")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.placesAndTravel.rawValue == "Places & Travel")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.relationships.rawValue == "Relationships")
    }

    @Test
    func test_sportsSubcategory_allCases() {
        #expect(ITunesCategory.SportsSubcategory.allCases.count == 15)
        #expect(ITunesCategory.SportsSubcategory.baseball.rawValue == "Baseball")
        #expect(ITunesCategory.SportsSubcategory.basketball.rawValue == "Basketball")
        #expect(ITunesCategory.SportsSubcategory.cricket.rawValue == "Cricket")
        #expect(ITunesCategory.SportsSubcategory.fantasySports.rawValue == "Fantasy Sports")
        #expect(ITunesCategory.SportsSubcategory.football.rawValue == "Football")
        #expect(ITunesCategory.SportsSubcategory.golf.rawValue == "Golf")
        #expect(ITunesCategory.SportsSubcategory.hockey.rawValue == "Hockey")
        #expect(ITunesCategory.SportsSubcategory.rugby.rawValue == "Rugby")
        #expect(ITunesCategory.SportsSubcategory.running.rawValue == "Running")
        #expect(ITunesCategory.SportsSubcategory.soccer.rawValue == "Soccer")
        #expect(ITunesCategory.SportsSubcategory.swimming.rawValue == "Swimming")
        #expect(ITunesCategory.SportsSubcategory.tennis.rawValue == "Tennis")
        #expect(ITunesCategory.SportsSubcategory.volleyball.rawValue == "Volleyball")
        #expect(ITunesCategory.SportsSubcategory.wilderness.rawValue == "Wilderness")
        #expect(ITunesCategory.SportsSubcategory.wrestling.rawValue == "Wrestling")
    }

    @Test
    func test_tvAndFilmSubcategory_allCases() {
        #expect(ITunesCategory.TvAndFilmSubcategory.allCases.count == 5)
        #expect(ITunesCategory.TvAndFilmSubcategory.afterShows.rawValue == "After Shows")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmHistory.rawValue == "Film History")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmInterviews.rawValue == "Film Interviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmReviews.rawValue == "Film Reviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.tvReviews.rawValue == "TV Reviews")
    }

    // MARK: - String-Based Init

    @Test
    func test_init_withRawString() {
        let category = ITunesCategory(text: "Technology")
        #expect(category.text == "Technology")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_init_withRawStringAndSubcategories() {
        let sub = ITunesCategory(text: "Podcasting")
        let category = ITunesCategory(text: "Technology", subcategories: [sub])
        #expect(category.text == "Technology")
        #expect(category.subcategories.count == 1)
        #expect(category.subcategories.first?.text == "Podcasting")
    }

    @Test
    func test_init_withCategoryEnum() {
        let category = ITunesCategory(.technology)
        #expect(category.text == "Technology")
        #expect(category.subcategories.isEmpty)
    }

    // MARK: - Static Factory Methods

    @Test
    func test_factory_artsWithSubcategory() {
        let category = ITunesCategory.arts(.books)
        #expect(category.text == "Arts")
        #expect(category.subcategories.count == 1)
        #expect(category.subcategories.first?.text == "Books")
    }

    @Test
    func test_factory_artsWithoutSubcategory() {
        let category = ITunesCategory.arts()
        #expect(category.text == "Arts")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_factory_businessWithSubcategory() {
        let category = ITunesCategory.business(.marketing)
        #expect(category.text == "Business")
        #expect(category.subcategories.first?.text == "Marketing")
    }

    @Test
    func test_factory_comedyWithSubcategory() {
        let category = ITunesCategory.comedy(.improv)
        #expect(category.text == "Comedy")
        #expect(category.subcategories.first?.text == "Improv")
    }

    @Test
    func test_factory_educationWithSubcategory() {
        let category = ITunesCategory.education(.courses)
        #expect(category.text == "Education")
        #expect(category.subcategories.first?.text == "Courses")
    }

    @Test
    func test_factory_fictionWithSubcategory() {
        let category = ITunesCategory.fiction(.drama)
        #expect(category.text == "Fiction")
        #expect(category.subcategories.first?.text == "Drama")
    }

    @Test
    func test_factory_government() {
        let category = ITunesCategory.government
        #expect(category.text == "Government")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_factory_healthAndFitnessWithSubcategory() {
        let category = ITunesCategory.healthAndFitness(.fitness)
        #expect(category.text == "Health & Fitness")
        #expect(category.subcategories.first?.text == "Fitness")
    }

    @Test
    func test_factory_history() {
        let category = ITunesCategory.history
        #expect(category.text == "History")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_factory_kidsAndFamilyWithSubcategory() {
        let category = ITunesCategory.kidsAndFamily(.parenting)
        #expect(category.text == "Kids & Family")
        #expect(category.subcategories.first?.text == "Parenting")
    }

    @Test
    func test_factory_leisureWithSubcategory() {
        let category = ITunesCategory.leisure(.games)
        #expect(category.text == "Leisure")
        #expect(category.subcategories.first?.text == "Games")
    }

    @Test
    func test_factory_musicWithSubcategory() {
        let category = ITunesCategory.music(.musicCommentary)
        #expect(category.text == "Music")
        #expect(category.subcategories.first?.text == "Music Commentary")
    }

    @Test
    func test_factory_newsWithSubcategory() {
        let category = ITunesCategory.news(.techNews)
        #expect(category.text == "News")
        #expect(category.subcategories.first?.text == "Tech News")
    }

    @Test
    func test_factory_religionAndSpiritualityWithSubcategory() {
        let category = ITunesCategory.religionAndSpirituality(.christianity)
        #expect(category.text == "Religion & Spirituality")
        #expect(category.subcategories.first?.text == "Christianity")
    }

    @Test
    func test_factory_scienceWithSubcategory() {
        let category = ITunesCategory.science(.physics)
        #expect(category.text == "Science")
        #expect(category.subcategories.first?.text == "Physics")
    }

    @Test
    func test_factory_societyAndCultureWithSubcategory() {
        let category = ITunesCategory.societyAndCulture(.documentary)
        #expect(category.text == "Society & Culture")
        #expect(category.subcategories.first?.text == "Documentary")
    }

    @Test
    func test_factory_sportsWithSubcategory() {
        let category = ITunesCategory.sports(.soccer)
        #expect(category.text == "Sports")
        #expect(category.subcategories.first?.text == "Soccer")
    }

    @Test
    func test_factory_technology() {
        let category = ITunesCategory.technology
        #expect(category.text == "Technology")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_factory_trueCrime() {
        let category = ITunesCategory.trueCrime
        #expect(category.text == "True Crime")
        #expect(category.subcategories.isEmpty)
    }

    @Test
    func test_factory_tvAndFilmWithSubcategory() {
        let category = ITunesCategory.tvAndFilm(.tvReviews)
        #expect(category.text == "TV & Film")
        #expect(category.subcategories.first?.text == "TV Reviews")
    }

    // MARK: - Valid Subcategories

    @Test
    func test_validSubcategories_forArts() {
        let subs = ITunesCategory.validSubcategories(for: .arts)
        #expect(subs.count == 6)
        #expect(subs.contains("Books"))
        #expect(subs.contains("Visual Arts"))
    }

    @Test
    func test_validSubcategories_forTechnology() {
        let subs = ITunesCategory.validSubcategories(for: .technology)
        #expect(subs.isEmpty)
    }

    @Test
    func test_validSubcategories_forGovernment() {
        let subs = ITunesCategory.validSubcategories(for: .government)
        #expect(subs.isEmpty)
    }

    @Test
    func test_validSubcategories_forHistory() {
        let subs = ITunesCategory.validSubcategories(for: .history)
        #expect(subs.isEmpty)
    }

    @Test
    func test_validSubcategories_forTrueCrime() {
        let subs = ITunesCategory.validSubcategories(for: .trueCrime)
        #expect(subs.isEmpty)
    }

    @Test
    func test_validSubcategories_forNews() {
        let subs = ITunesCategory.validSubcategories(for: .news)
        #expect(subs.count == 7)
        #expect(subs.contains("Tech News"))
        #expect(subs.contains("Politics"))
    }

    @Test
    func test_validSubcategories_forSports() {
        let subs = ITunesCategory.validSubcategories(for: .sports)
        #expect(subs.count == 15)
        #expect(subs.contains("Soccer"))
        #expect(subs.contains("Wrestling"))
    }

    @Test
    func test_validSubcategories_forScience() {
        let subs = ITunesCategory.validSubcategories(for: .science)
        #expect(subs.count == 9)
        #expect(subs.contains("Astronomy"))
        #expect(subs.contains("Physics"))
    }

    // MARK: - Channel Integration

    @Test
    func test_channel_itunesCategories_storesCategories() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesCategories: [
                .arts(.books),
                .technology
            ]
        )
        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesCategories[0].text == "Arts")
        #expect(channel.itunesCategories[0].subcategories.first?.text == "Books")
        #expect(channel.itunesCategories[1].text == "Technology")
        #expect(channel.itunesCategories[1].subcategories.isEmpty)
    }

    @Test
    func test_channel_itunesCategories_defaultsToEmpty() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        #expect(channel.itunesCategories.isEmpty)
    }

    // MARK: - Equatable and Hashable

    @Test
    func test_equatable_sameCategory() {
        let catA = ITunesCategory.arts(.books)
        let catB = ITunesCategory.arts(.books)
        #expect(catA == catB)
    }

    @Test
    func test_equatable_differentCategory() {
        let catA = ITunesCategory.arts(.books)
        let catB = ITunesCategory.arts(.design)
        #expect(catA != catB)
    }

    @Test
    func test_equatable_differentMainCategory() {
        let catA = ITunesCategory.arts()
        let catB = ITunesCategory.technology
        #expect(catA != catB)
    }

    @Test
    func test_hashable() {
        let catA = ITunesCategory.arts(.books)
        let catB = ITunesCategory.arts(.books)
        let catC = ITunesCategory.technology
        let set: Set = [catA, catB, catC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable and Codable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(ITunesCategory.self)
        assertSendable(ITunesCategory.Category.self)
        assertSendable(ITunesCategory.ArtsSubcategory.self)
        assertSendable(ITunesCategory.BusinessSubcategory.self)
        assertSendable(ITunesCategory.SportsSubcategory.self)
    }

    @Test
    func test_codableConformance() throws {
        let category = ITunesCategory.arts(.books)
        let encoder = JSONEncoder()
        let data = try encoder.encode(category)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ITunesCategory.self, from: data)
        #expect(decoded == category)
    }

    // MARK: - Factory Methods Without Subcategories

    @Test("Factory methods without subcategory return empty subcategories")
    func factoryMethodsWithoutSubcategories() {
        let business = ITunesCategory.business()
        #expect(business.text == "Business")
        #expect(business.subcategories.isEmpty)

        let comedy = ITunesCategory.comedy()
        #expect(comedy.text == "Comedy")
        #expect(comedy.subcategories.isEmpty)

        let education = ITunesCategory.education()
        #expect(education.text == "Education")
        #expect(education.subcategories.isEmpty)

        let fiction = ITunesCategory.fiction()
        #expect(fiction.text == "Fiction")
        #expect(fiction.subcategories.isEmpty)

        let healthAndFitness = ITunesCategory.healthAndFitness()
        #expect(healthAndFitness.text == "Health & Fitness")
        #expect(healthAndFitness.subcategories.isEmpty)

        let kidsAndFamily = ITunesCategory.kidsAndFamily()
        #expect(kidsAndFamily.text == "Kids & Family")
        #expect(kidsAndFamily.subcategories.isEmpty)

        let leisure = ITunesCategory.leisure()
        #expect(leisure.text == "Leisure")
        #expect(leisure.subcategories.isEmpty)

        let music = ITunesCategory.music()
        #expect(music.text == "Music")
        #expect(music.subcategories.isEmpty)

        let news = ITunesCategory.news()
        #expect(news.text == "News")
        #expect(news.subcategories.isEmpty)

        let religion = ITunesCategory.religionAndSpirituality()
        #expect(religion.text == "Religion & Spirituality")
        #expect(religion.subcategories.isEmpty)

        let science = ITunesCategory.science()
        #expect(science.text == "Science")
        #expect(science.subcategories.isEmpty)

        let society = ITunesCategory.societyAndCulture()
        #expect(society.text == "Society & Culture")
        #expect(society.subcategories.isEmpty)

        let sports = ITunesCategory.sports()
        #expect(sports.text == "Sports")
        #expect(sports.subcategories.isEmpty)

        let tvAndFilm = ITunesCategory.tvAndFilm()
        #expect(tvAndFilm.text == "TV & Film")
        #expect(tvAndFilm.subcategories.isEmpty)
    }

    // MARK: - validSubcategories All Categories

    @Test("validSubcategories returns correct subcategories for all categories")
    func validSubcategoriesAllCategories() {
        #expect(!ITunesCategory.validSubcategories(for: .arts).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .business).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .comedy).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .education).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .fiction).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .government).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .healthAndFitness).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .history).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .kidsAndFamily).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .leisure).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .music).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .news).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .religionAndSpirituality).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .science).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .societyAndCulture).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .sports).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .technology).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .trueCrime).isEmpty)
        #expect(!ITunesCategory.validSubcategories(for: .tvAndFilm).isEmpty)
    }

    @Test("validSubcategories for business returns 6 subcategories")
    func validSubcategoriesForBusiness() {
        let subs = ITunesCategory.validSubcategories(for: .business)
        #expect(subs.count == 6)
        #expect(subs.contains("Careers"))
        #expect(subs.contains("Non-Profit"))
    }

    @Test("validSubcategories for comedy returns 3 subcategories")
    func validSubcategoriesForComedy() {
        let subs = ITunesCategory.validSubcategories(for: .comedy)
        #expect(subs.count == 3)
        #expect(subs.contains("Improv"))
        #expect(subs.contains("Stand-Up"))
    }

    @Test("validSubcategories for education returns 4 subcategories")
    func validSubcategoriesForEducation() {
        let subs = ITunesCategory.validSubcategories(for: .education)
        #expect(subs.count == 4)
        #expect(subs.contains("Courses"))
        #expect(subs.contains("Self-Improvement"))
    }

    @Test("validSubcategories for fiction returns 3 subcategories")
    func validSubcategoriesForFiction() {
        let subs = ITunesCategory.validSubcategories(for: .fiction)
        #expect(subs.count == 3)
        #expect(subs.contains("Drama"))
        #expect(subs.contains("Science Fiction"))
    }

    @Test("validSubcategories for healthAndFitness returns 6 subcategories")
    func validSubcategoriesForHealthAndFitness() {
        let subs = ITunesCategory.validSubcategories(for: .healthAndFitness)
        #expect(subs.count == 6)
        #expect(subs.contains("Fitness"))
        #expect(subs.contains("Sexuality"))
    }

    @Test("validSubcategories for kidsAndFamily returns 4 subcategories")
    func validSubcategoriesForKidsAndFamily() {
        let subs = ITunesCategory.validSubcategories(for: .kidsAndFamily)
        #expect(subs.count == 4)
        #expect(subs.contains("Parenting"))
        #expect(subs.contains("Stories for Kids"))
    }

    @Test("validSubcategories for leisure returns 8 subcategories")
    func validSubcategoriesForLeisure() {
        let subs = ITunesCategory.validSubcategories(for: .leisure)
        #expect(subs.count == 8)
        #expect(subs.contains("Games"))
        #expect(subs.contains("Video Games"))
    }

    @Test("validSubcategories for music returns 3 subcategories")
    func validSubcategoriesForMusic() {
        let subs = ITunesCategory.validSubcategories(for: .music)
        #expect(subs.count == 3)
        #expect(subs.contains("Music Commentary"))
        #expect(subs.contains("Music Interviews"))
    }

    @Test("validSubcategories for religionAndSpirituality returns 7 subcategories")
    func validSubcategoriesForReligionAndSpirituality() {
        let subs = ITunesCategory.validSubcategories(for: .religionAndSpirituality)
        #expect(subs.count == 7)
        #expect(subs.contains("Buddhism"))
        #expect(subs.contains("Spirituality"))
    }

    @Test("validSubcategories for societyAndCulture returns 5 subcategories")
    func validSubcategoriesForSocietyAndCulture() {
        let subs = ITunesCategory.validSubcategories(for: .societyAndCulture)
        #expect(subs.count == 5)
        #expect(subs.contains("Documentary"))
        #expect(subs.contains("Relationships"))
    }

    @Test("validSubcategories for tvAndFilm returns 5 subcategories")
    func validSubcategoriesForTvAndFilm() {
        let subs = ITunesCategory.validSubcategories(for: .tvAndFilm)
        #expect(subs.count == 5)
        #expect(subs.contains("After Shows"))
        #expect(subs.contains("TV Reviews"))
    }
}
