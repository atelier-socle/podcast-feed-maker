import Foundation

// MARK: - Channel Element Handling

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func handleChannelEndElement(_ name: String, text: String) {
        guard
            !text.isEmpty || name.hasPrefix("itunes:")
                || name.hasPrefix("dc:") || name.hasPrefix("podcast:")
        else {
            handleChannelNonTextElement(name, text: text)
            return
        }

        switch name {
        // RSS 2.0 Core
        case "title":
            channelTitle = text
        case "link":
            channelLink = text
        case "description":
            channelDescription = text
        case "category":
            if !text.isEmpty {
                let domain = currentAttributes["domain"]
                channelCategories.append(
                    RSSCategory(value: text, domain: domain)
                )
            }
        case "language":
            channelLanguage = text
        case "copyright":
            channelCopyright = text
        case "managingEditor":
            channelManagingEditor = text
        case "webMaster":
            channelWebMaster = text
        case "pubDate":
            channelPubDate = DateParser.parse(text)
        case "lastBuildDate":
            channelLastBuildDate = DateParser.parse(text)
        case "generator":
            channelGenerator = text
        case "docs":
            channelDocs = URL(string: text)
        case "ttl":
            channelTTL = Int(text)

        // iTunes
        case "itunes:author":
            chItunesAuthor = text
        case "itunes:block":
            chItunesBlock = parseBool(text)
        case "itunes:complete":
            chItunesComplete = parseBool(text)
        case "itunes:explicit":
            chItunesExplicit = parseBool(text)
        case "itunes:keywords":
            chItunesKeywords = text.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        case "itunes:new-feed-url":
            chItunesNewFeedUrl = URL(string: text)
        case "itunes:subtitle":
            chItunesSubtitle = text
        case "itunes:summary":
            chItunesSummary = text
        case "itunes:title":
            chItunesTitle = text
        case "itunes:type":
            chItunesType = ITunesShowType(rawValue: text)
        case "itunes:applepodcastsverify":
            chItunesVerify = parseBool(text)

        // Dublin Core
        case "dc:creator", "dc:contributor", "dc:date", "dc:description",
            "dc:format", "dc:identifier", "dc:language", "dc:publisher",
            "dc:relation", "dc:rights", "dc:source", "dc:subject",
            "dc:title", "dc:type", "dc:coverage":
            handleDublinCoreChannel(name, text: text)

        // Podcast NS
        default:
            handlePodcastChannelEndElement(name, text: text)
        }
    }

    private func handleChannelNonTextElement(
        _ name: String, text: String
    ) {
        // Placeholder for future non-text elements
    }

    // swiftlint:disable:next cyclomatic_complexity
    func handleDublinCoreChannel(_ name: String, text: String) {
        guard !text.isEmpty else { return }
        if chDublinCore == nil { chDublinCore = DublinCore() }
        let field = String(name.dropFirst(3))
        switch field {
        case "creator": chDublinCore?.creator = text
        case "contributor": chDublinCore?.contributor = text
        case "date": chDublinCore?.date = text
        case "description": chDublinCore?.description = text
        case "format": chDublinCore?.format = text
        case "identifier": chDublinCore?.identifier = text
        case "language": chDublinCore?.language = text
        case "publisher": chDublinCore?.publisher = text
        case "relation": chDublinCore?.relation = text
        case "rights": chDublinCore?.rights = text
        case "source": chDublinCore?.source = text
        case "subject": chDublinCore?.subject = text
        case "title": chDublinCore?.title = text
        case "type": chDublinCore?.type = text
        case "coverage": chDublinCore?.coverage = text
        default: break
        }
    }
}

// MARK: - Item Element Handling

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func handleItemEndElement(_ name: String, text: String) {
        switch name {
        // RSS 2.0 Core
        case "title":
            currentItem?.title = text.isEmpty ? nil : text
        case "link":
            currentItem?.link = URL(string: text)
        case "description":
            currentItem?.description = text.isEmpty ? nil : text
        case "author":
            currentItem?.author = text.isEmpty ? nil : text
        case "category":
            if !text.isEmpty {
                let domain = currentAttributes["domain"]
                currentItem?.categories.append(
                    RSSCategory(value: text, domain: domain)
                )
            }
        case "comments":
            currentItem?.comments = URL(string: text)
        case "guid":
            let isPermaLink =
                parseBool(
                    currentAttributes["isPermaLink"] ?? "true"
                ) ?? true
            if !text.isEmpty {
                currentItem?.guid = GUID(
                    value: text, isPermaLink: isPermaLink
                )
            }
        case "pubDate":
            currentItem?.pubDate = DateParser.parse(text)
        case "source":
            if let urlStr = currentAttributes["url"],
                let url = URL(string: urlStr), !text.isEmpty
            {
                currentItem?.source = RSSSource(title: text, url: url)
            }

        // iTunes
        case "itunes:author":
            currentItem?.itunesAuthor = text.isEmpty ? nil : text
        case "itunes:block":
            currentItem?.itunesBlock = parseBool(text)
        case "itunes:duration":
            currentItem?.itunesDuration = parseDuration(text)
        case "itunes:episode":
            currentItem?.itunesEpisode = Int(text)
        case "itunes:episodeType":
            currentItem?.itunesEpisodeType =
                ITunesEpisodeType(rawValue: text)
        case "itunes:explicit":
            currentItem?.itunesExplicit = parseBool(text)
        case "itunes:keywords":
            currentItem?.itunesKeywords = text.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        case "itunes:season":
            currentItem?.itunesSeason = Int(text)
        case "itunes:subtitle":
            currentItem?.itunesSubtitle = text.isEmpty ? nil : text
        case "itunes:summary":
            currentItem?.itunesSummary = text.isEmpty ? nil : text
        case "itunes:title":
            currentItem?.itunesTitle = text.isEmpty ? nil : text

        // Dublin Core
        case "dc:creator", "dc:contributor", "dc:date", "dc:description",
            "dc:format", "dc:identifier", "dc:language", "dc:publisher",
            "dc:relation", "dc:rights", "dc:source", "dc:subject",
            "dc:title", "dc:type", "dc:coverage":
            handleDublinCoreItem(name, text: text)

        // Content Module
        case "content:encoded":
            if !text.isEmpty {
                currentItem?.contentEncoded = ContentEncoded(value: text)
            }

        // Podcast NS
        default:
            handlePodcastItemEndElement(name, text: text)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func handleDublinCoreItem(_ name: String, text: String) {
        guard !text.isEmpty else { return }
        if currentItem?.dublinCore == nil {
            currentItem?.dublinCore = DublinCore()
        }
        let field = String(name.dropFirst(3))
        switch field {
        case "creator": currentItem?.dublinCore?.creator = text
        case "contributor": currentItem?.dublinCore?.contributor = text
        case "date": currentItem?.dublinCore?.date = text
        case "description": currentItem?.dublinCore?.description = text
        case "format": currentItem?.dublinCore?.format = text
        case "identifier": currentItem?.dublinCore?.identifier = text
        case "language": currentItem?.dublinCore?.language = text
        case "publisher": currentItem?.dublinCore?.publisher = text
        case "relation": currentItem?.dublinCore?.relation = text
        case "rights": currentItem?.dublinCore?.rights = text
        case "source": currentItem?.dublinCore?.source = text
        case "subject": currentItem?.dublinCore?.subject = text
        case "title": currentItem?.dublinCore?.title = text
        case "type": currentItem?.dublinCore?.type = text
        case "coverage": currentItem?.dublinCore?.coverage = text
        default: break
        }
    }
}

// MARK: - Nested RSS Element Handling

extension FeedParserDelegate {

    func handleImageEndElement(_ name: String, text: String) {
        switch name {
        case "url": imageURL = text
        case "title": imageTitle = text
        case "link": imageLink = text
        case "width": imageWidth = Int(text)
        case "height": imageHeight = Int(text)
        case "description": imageDescription = text
        default: break
        }
    }

    func handleTextInputEndElement(_ name: String, text: String) {
        switch name {
        case "title": textInputTitle = text
        case "description": textInputDescription = text
        case "name": textInputName = text
        case "link": textInputLink = text
        default: break
        }
    }

    func handleSkipHoursEndElement(_ name: String, text: String) {
        if name == "hour", let hour = Int(text) {
            channelSkipHours.insert(hour)
        }
    }

    func handleSkipDaysEndElement(_ name: String, text: String) {
        if name == "day", let day = SkipSchedule.Day(rawValue: text) {
            channelSkipDays.insert(day)
        }
    }

    func handleITunesOwnerEndElement(_ name: String, text: String) {
        switch name {
        case "itunes:name": ownerName = text
        case "itunes:email": ownerEmail = text
        default: break
        }
    }
}

// MARK: - iTunes Category

extension FeedParserDelegate {

    func handleITunesCategoryStart(_ attrs: [String: String]) {
        let text = attrs["text"] ?? ""
        if currentContext == .itunesCategory {
            subcategoryTexts.append(text)
        } else {
            categoryText = text
            subcategoryTexts = []
            categoryNestLevel = 0
            pushContext(.itunesCategory)
        }
        categoryNestLevel += 1
    }

    func finalizeITunesCategory() {
        categoryNestLevel -= 1
        if categoryNestLevel > 0 { return }

        if let text = categoryText {
            let subcats = subcategoryTexts.map {
                ITunesCategory(text: $0)
            }
            let category = ITunesCategory(
                text: text, subcategories: subcats
            )
            let parentContext = contextStack.dropLast().last ?? .root
            if parentContext == .channel {
                chItunesCategories.append(category)
            }
        }
        popContext()
    }
}

// MARK: - Attribute-Only Elements

extension FeedParserDelegate {

    func handleEnclosureAttributes(_ attrs: [String: String]) {
        guard let urlStr = attrs["url"],
            let url = URL(string: urlStr)
        else { return }
        let length = Int(attrs["length"] ?? "0") ?? 0
        let type = attrs["type"] ?? "audio/mpeg"
        let enclosure = Enclosure(url: url, length: length, type: type)

        switch currentContext {
        case .item:
            currentItem?.enclosure = enclosure
        case .liveItem:
            currentLiveItem?.enclosure = enclosure
        default: break
        }
    }

    func handleAtomLinkAttributes(_ attrs: [String: String]) {
        guard let hrefStr = attrs["href"],
            let href = URL(string: hrefStr)
        else { return }
        let link = AtomLink(
            href: href,
            rel: attrs["rel"],
            type: attrs["type"],
            hreflang: attrs["hreflang"],
            title: attrs["title"],
            length: attrs["length"].flatMap { Int($0) }
        )
        switch currentContext {
        case .channel: chAtomLinks.append(link)
        case .item: currentItem?.atomLinks.append(link)
        default: break
        }
    }

    func handleCloudAttributes(_ attrs: [String: String]) {
        guard let domain = attrs["domain"],
            let portStr = attrs["port"],
            let port = Int(portStr),
            let path = attrs["path"],
            let registerProcedure = attrs["registerProcedure"],
            let protocolType = attrs["protocol"]
        else { return }
        channelCloud = RSSCloud(
            domain: domain, port: port, path: path,
            registerProcedure: registerProcedure,
            protocolType: protocolType
        )
    }

    func handleITunesImageAttributes(_ attrs: [String: String]) {
        guard let href = attrs["href"],
            let url = URL(string: href)
        else { return }
        switch currentContext {
        case .channel: chItunesImage = url
        case .item: currentItem?.itunesImage = url
        case .liveItem: currentLiveItem?.itunesImage = url
        default: break
        }
    }
}
