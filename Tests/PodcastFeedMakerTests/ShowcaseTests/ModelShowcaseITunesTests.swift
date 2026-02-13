import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - iTunes Model Showcase

@Suite("iTunes Model Showcase")
struct ITunesModelShowcase {

    // MARK: - ITunesCategory

    @Test("ITunesCategory initializes from raw strings")
    func categoryFromStrings() {
        let category = ITunesCategory(
            text: "Technology",
            subcategories: [ITunesCategory(text: "Podcasting")]
        )

        #expect(category.text == "Technology")
        #expect(category.subcategories.count == 1)
        #expect(category.subcategories[0].text == "Podcasting")
    }

    @Test("ITunesCategory initializes from Category enum")
    func categoryFromEnum() {
        let category = ITunesCategory(.arts)
        #expect(category.text == "Arts")
        #expect(category.subcategories.isEmpty)
    }

    @Test("ITunesCategory.Category enum has all 19 main categories")
    func allMainCategories() {
        let allCases = ITunesCategory.Category.allCases
        #expect(allCases.count == 19)
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

    @Test("ITunesCategory factory methods with subcategories")
    func categoryFactoryMethods() {
        let arts = ITunesCategory.arts(.books)
        #expect(arts.text == "Arts")
        #expect(arts.subcategories[0].text == "Books")

        let business = ITunesCategory.business(.entrepreneurship)
        #expect(business.subcategories[0].text == "Entrepreneurship")

        let comedy = ITunesCategory.comedy(.standUp)
        #expect(comedy.subcategories[0].text == "Stand-Up")

        let education = ITunesCategory.education(.courses)
        #expect(education.subcategories[0].text == "Courses")

        let fiction = ITunesCategory.fiction(.scienceFiction)
        #expect(fiction.subcategories[0].text == "Science Fiction")

        let health = ITunesCategory.healthAndFitness(.mentalHealth)
        #expect(health.subcategories[0].text == "Mental Health")

        let kids = ITunesCategory.kidsAndFamily(.parenting)
        #expect(kids.subcategories[0].text == "Parenting")

        let leisure = ITunesCategory.leisure(.videoGames)
        #expect(leisure.subcategories[0].text == "Video Games")

        let music = ITunesCategory.music(.musicHistory)
        #expect(music.subcategories[0].text == "Music History")

        let news = ITunesCategory.news(.techNews)
        #expect(news.subcategories[0].text == "Tech News")

        let religion = ITunesCategory.religionAndSpirituality(.buddhism)
        #expect(religion.subcategories[0].text == "Buddhism")

        let science = ITunesCategory.science(.astronomy)
        #expect(science.subcategories[0].text == "Astronomy")

        let society = ITunesCategory.societyAndCulture(.philosophy)
        #expect(society.subcategories[0].text == "Philosophy")

        let sports = ITunesCategory.sports(.soccer)
        #expect(sports.subcategories[0].text == "Soccer")

        let tv = ITunesCategory.tvAndFilm(.filmReviews)
        #expect(tv.subcategories[0].text == "Film Reviews")
    }

    @Test("ITunesCategory factory methods without subcategories")
    func categoryFactoryNoSubcategory() {
        let government: ITunesCategory = .government
        #expect(government.text == "Government")
        #expect(government.subcategories.isEmpty)

        let history: ITunesCategory = .history
        #expect(history.text == "History")
        #expect(history.subcategories.isEmpty)

        let technology: ITunesCategory = .technology
        #expect(technology.text == "Technology")
        #expect(technology.subcategories.isEmpty)

        let trueCrime: ITunesCategory = .trueCrime
        #expect(trueCrime.text == "True Crime")
        #expect(trueCrime.subcategories.isEmpty)
    }

    @Test("ITunesCategory.validSubcategories returns correct subcategories per main category")
    func validSubcategories() {
        let artsSubs = ITunesCategory.validSubcategories(for: .arts)
        #expect(artsSubs.count == 6)
        #expect(artsSubs.contains("Books"))
        #expect(artsSubs.contains("Visual Arts"))

        let businessSubs = ITunesCategory.validSubcategories(for: .business)
        #expect(businessSubs.count == 6)
        #expect(businessSubs.contains("Careers"))

        let comedySubs = ITunesCategory.validSubcategories(for: .comedy)
        #expect(comedySubs.count == 3)

        let educationSubs = ITunesCategory.validSubcategories(for: .education)
        #expect(educationSubs.count == 4)

        let fictionSubs = ITunesCategory.validSubcategories(for: .fiction)
        #expect(fictionSubs.count == 3)

        let healthSubs = ITunesCategory.validSubcategories(for: .healthAndFitness)
        #expect(healthSubs.count == 6)

        let kidsSubs = ITunesCategory.validSubcategories(for: .kidsAndFamily)
        #expect(kidsSubs.count == 4)

        let leisureSubs = ITunesCategory.validSubcategories(for: .leisure)
        #expect(leisureSubs.count == 8)

        let musicSubs = ITunesCategory.validSubcategories(for: .music)
        #expect(musicSubs.count == 3)

        let newsSubs = ITunesCategory.validSubcategories(for: .news)
        #expect(newsSubs.count == 7)

        let religionSubs = ITunesCategory.validSubcategories(for: .religionAndSpirituality)
        #expect(religionSubs.count == 7)

        let scienceSubs = ITunesCategory.validSubcategories(for: .science)
        #expect(scienceSubs.count == 9)

        let societySubs = ITunesCategory.validSubcategories(for: .societyAndCulture)
        #expect(societySubs.count == 5)

        let sportsSubs = ITunesCategory.validSubcategories(for: .sports)
        #expect(sportsSubs.count == 15)

        let tvSubs = ITunesCategory.validSubcategories(for: .tvAndFilm)
        #expect(tvSubs.count == 5)

        // Categories with no subcategories
        #expect(ITunesCategory.validSubcategories(for: .government).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .history).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .technology).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .trueCrime).isEmpty)
    }

    @Test("Arts, Business, Comedy, Education, Fiction subcategory raw values")
    func subcategoryRawValuesGroup1() {
        // Arts
        #expect(ITunesCategory.ArtsSubcategory.books.rawValue == "Books")
        #expect(ITunesCategory.ArtsSubcategory.design.rawValue == "Design")
        #expect(ITunesCategory.ArtsSubcategory.fashionAndBeauty.rawValue == "Fashion & Beauty")
        #expect(ITunesCategory.ArtsSubcategory.food.rawValue == "Food")
        #expect(ITunesCategory.ArtsSubcategory.performingArts.rawValue == "Performing Arts")
        #expect(ITunesCategory.ArtsSubcategory.visualArts.rawValue == "Visual Arts")

        // Business
        #expect(ITunesCategory.BusinessSubcategory.careers.rawValue == "Careers")
        #expect(ITunesCategory.BusinessSubcategory.entrepreneurship.rawValue == "Entrepreneurship")
        #expect(ITunesCategory.BusinessSubcategory.investing.rawValue == "Investing")
        #expect(ITunesCategory.BusinessSubcategory.management.rawValue == "Management")
        #expect(ITunesCategory.BusinessSubcategory.marketing.rawValue == "Marketing")
        #expect(ITunesCategory.BusinessSubcategory.nonProfit.rawValue == "Non-Profit")

        // Comedy
        #expect(ITunesCategory.ComedySubcategory.comedyInterviews.rawValue == "Comedy Interviews")
        #expect(ITunesCategory.ComedySubcategory.improv.rawValue == "Improv")
        #expect(ITunesCategory.ComedySubcategory.standUp.rawValue == "Stand-Up")

        // Education
        #expect(ITunesCategory.EducationSubcategory.courses.rawValue == "Courses")
        #expect(ITunesCategory.EducationSubcategory.howTo.rawValue == "How To")
        #expect(ITunesCategory.EducationSubcategory.languageLearning.rawValue == "Language Learning")
        #expect(ITunesCategory.EducationSubcategory.selfImprovement.rawValue == "Self-Improvement")

        // Fiction
        #expect(ITunesCategory.FictionSubcategory.comedyFiction.rawValue == "Comedy Fiction")
        #expect(ITunesCategory.FictionSubcategory.drama.rawValue == "Drama")
        #expect(ITunesCategory.FictionSubcategory.scienceFiction.rawValue == "Science Fiction")
    }

    @Test("Health, Kids, Leisure, Music, News subcategory raw values")
    func subcategoryRawValuesGroup2() {
        // Health & Fitness
        #expect(ITunesCategory.HealthAndFitnessSubcategory.alternativeHealth.rawValue == "Alternative Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.fitness.rawValue == "Fitness")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.medicine.rawValue == "Medicine")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.mentalHealth.rawValue == "Mental Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.nutrition.rawValue == "Nutrition")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.sexuality.rawValue == "Sexuality")

        // Kids & Family
        #expect(ITunesCategory.KidsAndFamilySubcategory.educationForKids.rawValue == "Education for Kids")
        #expect(ITunesCategory.KidsAndFamilySubcategory.parenting.rawValue == "Parenting")
        #expect(ITunesCategory.KidsAndFamilySubcategory.petsAndAnimals.rawValue == "Pets & Animals")
        #expect(ITunesCategory.KidsAndFamilySubcategory.storiesForKids.rawValue == "Stories for Kids")

        // Leisure
        #expect(ITunesCategory.LeisureSubcategory.animationAndManga.rawValue == "Animation & Manga")
        #expect(ITunesCategory.LeisureSubcategory.automotive.rawValue == "Automotive")
        #expect(ITunesCategory.LeisureSubcategory.aviation.rawValue == "Aviation")
        #expect(ITunesCategory.LeisureSubcategory.crafts.rawValue == "Crafts")
        #expect(ITunesCategory.LeisureSubcategory.games.rawValue == "Games")
        #expect(ITunesCategory.LeisureSubcategory.hobbies.rawValue == "Hobbies")
        #expect(ITunesCategory.LeisureSubcategory.homeAndGarden.rawValue == "Home & Garden")
        #expect(ITunesCategory.LeisureSubcategory.videoGames.rawValue == "Video Games")

        // Music
        #expect(ITunesCategory.MusicSubcategory.musicCommentary.rawValue == "Music Commentary")
        #expect(ITunesCategory.MusicSubcategory.musicHistory.rawValue == "Music History")
        #expect(ITunesCategory.MusicSubcategory.musicInterviews.rawValue == "Music Interviews")

        // News
        #expect(ITunesCategory.NewsSubcategory.businessNews.rawValue == "Business News")
        #expect(ITunesCategory.NewsSubcategory.dailyNews.rawValue == "Daily News")
        #expect(ITunesCategory.NewsSubcategory.entertainmentNews.rawValue == "Entertainment News")
        #expect(ITunesCategory.NewsSubcategory.newsCommentary.rawValue == "News Commentary")
        #expect(ITunesCategory.NewsSubcategory.politics.rawValue == "Politics")
        #expect(ITunesCategory.NewsSubcategory.sportsNews.rawValue == "Sports News")
        #expect(ITunesCategory.NewsSubcategory.techNews.rawValue == "Tech News")
    }

    @Test("Religion, Science, Society, Sports, TV subcategory raw values")
    func subcategoryRawValuesGroup3() {
        // Religion & Spirituality
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.buddhism.rawValue == "Buddhism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.christianity.rawValue == "Christianity")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.hinduism.rawValue == "Hinduism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.islam.rawValue == "Islam")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.judaism.rawValue == "Judaism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.religion.rawValue == "Religion")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.spirituality.rawValue == "Spirituality")

        // Science
        #expect(ITunesCategory.ScienceSubcategory.astronomy.rawValue == "Astronomy")
        #expect(ITunesCategory.ScienceSubcategory.chemistry.rawValue == "Chemistry")
        #expect(ITunesCategory.ScienceSubcategory.earthSciences.rawValue == "Earth Sciences")
        #expect(ITunesCategory.ScienceSubcategory.lifeSciences.rawValue == "Life Sciences")
        #expect(ITunesCategory.ScienceSubcategory.mathematics.rawValue == "Mathematics")
        #expect(ITunesCategory.ScienceSubcategory.naturalSciences.rawValue == "Natural Sciences")
        #expect(ITunesCategory.ScienceSubcategory.nature.rawValue == "Nature")
        #expect(ITunesCategory.ScienceSubcategory.physics.rawValue == "Physics")
        #expect(ITunesCategory.ScienceSubcategory.socialSciences.rawValue == "Social Sciences")

        // Society & Culture
        #expect(ITunesCategory.SocietyAndCultureSubcategory.documentary.rawValue == "Documentary")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.personalJournals.rawValue == "Personal Journals")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.philosophy.rawValue == "Philosophy")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.placesAndTravel.rawValue == "Places & Travel")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.relationships.rawValue == "Relationships")

        // Sports
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

        // TV & Film
        #expect(ITunesCategory.TvAndFilmSubcategory.afterShows.rawValue == "After Shows")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmHistory.rawValue == "Film History")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmInterviews.rawValue == "Film Interviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmReviews.rawValue == "Film Reviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.tvReviews.rawValue == "TV Reviews")
    }

    // MARK: - ITunesOwner

    @Test("ITunesOwner holds name and email")
    func itunesOwnerProperties() {
        let owner = ITunesOwner(name: "Wlad Dicario", email: "wlad@ateliersocle.com")
        #expect(owner.name == "Wlad Dicario")
        #expect(owner.email == "wlad@ateliersocle.com")
    }

    // MARK: - Item iTunes Properties

    @Test("Item initializes with all iTunes namespace properties")
    func itemAllITunesProperties() {
        let imageURL = makeURL("https://example.com/ep1-art.jpg")

        let item = Item(
            title: "Episode with Full iTunes Metadata",
            itunesAuthor: "Jane Swift",
            itunesBlock: false,
            itunesDuration: 3600,
            itunesEpisode: 42,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: imageURL,
            itunesKeywords: ["swift", "concurrency", "actors"],
            itunesSeason: 3,
            itunesSubtitle: "A deep dive into actors",
            itunesSummary: "In this episode we explore the actor model in Swift concurrency...",
            itunesTitle: "Actors Deep Dive"
        )

        #expect(item.itunesAuthor == "Jane Swift")
        #expect(item.itunesBlock == false)
        #expect(item.itunesDuration == 3600)
        #expect(item.itunesEpisode == 42)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesImage == imageURL)
        #expect(item.itunesKeywords.count == 3)
        #expect(item.itunesSeason == 3)
        #expect(item.itunesSubtitle == "A deep dive into actors")
        #expect(item.itunesSummary?.contains("actor model") == true)
        #expect(item.itunesTitle == "Actors Deep Dive")
    }
}
