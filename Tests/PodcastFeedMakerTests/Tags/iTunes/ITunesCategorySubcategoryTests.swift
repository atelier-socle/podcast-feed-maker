import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Factory Methods

@Suite("iTunes Category — Factories")
struct ITunesCategoryFactoryTests {

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
}

// MARK: - Subcategory Validation

@Suite("iTunes Category — Subcategory Validation")
struct ITunesCategorySubcategoryValidationTests {

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
    func test_channel_itunesCategories_storesCategories() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
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
    func test_channel_itunesCategories_defaultsToEmpty() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesCategories.isEmpty)
    }

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
