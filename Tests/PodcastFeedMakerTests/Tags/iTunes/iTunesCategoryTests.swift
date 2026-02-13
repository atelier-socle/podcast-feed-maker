import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Core Category Tests

@Suite("iTunes Category — Core")
struct ITunesCategoryCoreTests {

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
}
