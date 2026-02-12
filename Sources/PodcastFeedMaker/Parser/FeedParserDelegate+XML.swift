import Foundation

// MARK: - XMLParserDelegate — Start Element

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes attributeDict: [String: String]
    ) {
        currentText = ""
        currentAttributes = attributeDict

        switch elementName {
        case "rss":
            if let version = attributeDict["version"] {
                feed.version = version
            }
            detectNamespaces(attributeDict)

        case "channel":
            pushContext(.channel)

        case "item" where currentContext == .channel:
            currentItem = Item()
            pushContext(.item)

        case "image" where currentContext == .channel:
            imageURL = nil
            imageTitle = nil
            imageLink = nil
            imageWidth = nil
            imageHeight = nil
            imageDescription = nil
            pushContext(.image)

        case "textInput" where currentContext == .channel:
            textInputTitle = nil
            textInputDescription = nil
            textInputName = nil
            textInputLink = nil
            pushContext(.textInput)

        case "skipHours" where currentContext == .channel:
            pushContext(.skipHours)

        case "skipDays" where currentContext == .channel:
            pushContext(.skipDays)

        case "itunes:owner" where currentContext == .channel:
            ownerName = nil
            ownerEmail = nil
            pushContext(.itunesOwner)

        case "itunes:category":
            handleITunesCategoryStart(attributeDict)

        case "podcast:value":
            handlePodcastValueStart(attributeDict)

        case "podcast:valueTimeSplit":
            handleValueTimeSplitStart(attributeDict)

        case "podcast:podroll" where currentContext == .channel:
            podrollItems = []
            pushContext(.podroll)

        case "podcast:alternateEnclosure":
            handleAlternateEnclosureStart(attributeDict)

        case "podcast:liveItem" where currentContext == .channel:
            handleLiveItemStart(attributeDict)

        case "psc:chapters":
            podloveVersion = attributeDict["version"] ?? "1.2"
            podloveChapterList = []
            pushContext(.podloveChapters)

        default:
            handleStartAttributes(elementName, attributeDict)
        }
    }
}

// MARK: - XMLParserDelegate — End Element

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName: String?
    ) {
        let text = currentText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        switch elementName {
        case "channel":
            finalizeChannel()
            popContext()

        case "item"
        where contextStack.contains(.item)
            && !contextStack.contains(.liveItem):
            if let item = currentItem {
                items.append(item)
            }
            currentItem = nil
            popContext()

        case "image" where currentContext == .image:
            finalizeImage()
            popContext()

        case "textInput" where currentContext == .textInput:
            finalizeTextInput()
            popContext()

        case "skipHours" where currentContext == .skipHours:
            popContext()

        case "skipDays" where currentContext == .skipDays:
            popContext()

        case "itunes:owner" where currentContext == .itunesOwner:
            finalizeITunesOwner()
            popContext()

        case "itunes:category"
        where currentContext == .itunesCategory:
            finalizeITunesCategory()

        case "podcast:value"
        where currentContext == .podcastValue:
            finalizePodcastValue()
            popContext()

        case "podcast:valueTimeSplit"
        where currentContext == .valueTimeSplit:
            finalizeValueTimeSplit()
            popContext()

        case "podcast:podroll"
        where currentContext == .podroll:
            chPodroll = Podroll(remoteItems: podrollItems)
            popContext()

        case "podcast:alternateEnclosure"
        where currentContext == .alternateEnclosure:
            finalizeAlternateEnclosure()
            popContext()

        case "podcast:liveItem"
        where currentContext == .liveItem:
            finalizeLiveItem()
            popContext()

        case "psc:chapters"
        where currentContext == .podloveChapters:
            let chapters = PodloveChapters(
                version: podloveVersion ?? "1.2",
                chapters: podloveChapterList
            )
            if contextStack.dropLast().contains(.item) {
                currentItem?.podloveChapters = chapters
            }
            popContext()

        default:
            dispatchEndElement(elementName, text: text)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func dispatchEndElement(_ name: String, text: String) {
        switch currentContext {
        case .channel:
            handleChannelEndElement(name, text: text)
        case .item:
            handleItemEndElement(name, text: text)
        case .image:
            handleImageEndElement(name, text: text)
        case .textInput:
            handleTextInputEndElement(name, text: text)
        case .skipHours:
            handleSkipHoursEndElement(name, text: text)
        case .skipDays:
            handleSkipDaysEndElement(name, text: text)
        case .itunesOwner:
            handleITunesOwnerEndElement(name, text: text)
        case .itunesCategory:
            break
        case .podcastValue:
            handlePodcastValueEndElement(name, text: text)
        case .valueTimeSplit:
            handleValueTimeSplitEndElement(name, text: text)
        case .podroll:
            break
        case .alternateEnclosure:
            handleAlternateEnclosureEndElement(name, text: text)
        case .liveItem:
            handleLiveItemEndElement(name, text: text)
        case .podloveChapters:
            break
        case .root:
            break
        }
    }
}

// MARK: - Start Attribute Dispatch

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity
    func handleStartAttributes(
        _ name: String,
        _ attrs: [String: String]
    ) {
        switch name {
        case "enclosure":
            handleEnclosureAttributes(attrs)
        case "atom:link":
            handleAtomLinkAttributes(attrs)
        case "podcast:transcript":
            handleTranscriptAttributes(attrs)
        case "podcast:chapters":
            handleChaptersLinkAttributes(attrs)
        case "podcast:source":
            handlePodcastSourceAttributes(attrs)
        case "podcast:integrity":
            handlePodcastIntegrityAttributes(attrs)
        case "podcast:remoteItem":
            handleRemoteItemAttributes(attrs)
        case "podcast:valueRecipient":
            handleValueRecipientAttributes(attrs)
        case "psc:chapter":
            handlePodloveChapterAttributes(attrs)
        case "cloud":
            handleCloudAttributes(attrs)
        case "itunes:image":
            handleITunesImageAttributes(attrs)
        default:
            break
        }
    }
}

// MARK: - Namespace Detection

extension FeedParserDelegate {

    func detectNamespaces(_ attrs: [String: String]) {
        var namespaces: [PodcastNamespace] = []
        for (key, value) in attrs {
            guard key.hasPrefix("xmlns:") else { continue }
            switch value {
            case "http://www.itunes.com/dtds/podcast-1.0.dtd":
                namespaces.append(.itunes)
            case "https://podcastindex.org/namespace/1.0":
                namespaces.append(.podcast)
            case "http://www.w3.org/2005/Atom":
                namespaces.append(.atom)
            case "http://purl.org/dc/elements/1.1/":
                namespaces.append(.dublinCore)
            case "http://purl.org/rss/1.0/modules/content/":
                namespaces.append(.content)
            case "http://podlove.org/simple-chapters":
                namespaces.append(.podloveSimpleChapters)
            default:
                namespaces.append(.custom(value))
            }
        }
        feed.namespaces = namespaces.sorted()
    }
}

// MARK: - Finalization

extension FeedParserDelegate {

    // swiftlint:disable:next function_body_length
    func finalizeChannel() {
        guard let title = channelTitle,
            let linkStr = channelLink,
            let link = URL(string: linkStr),
            let description = channelDescription
        else {
            parsingErrors.append(.missingChannel)
            return
        }

        var skipSchedule: SkipSchedule?
        if !channelSkipHours.isEmpty || !channelSkipDays.isEmpty {
            skipSchedule = SkipSchedule(
                hours: channelSkipHours,
                days: channelSkipDays
            )
        }

        let channel = Channel(
            title: title,
            link: link,
            description: description,
            language: channelLanguage,
            copyright: channelCopyright,
            managingEditor: channelManagingEditor,
            webMaster: channelWebMaster,
            pubDate: channelPubDate,
            lastBuildDate: channelLastBuildDate,
            categories: channelCategories,
            generator: channelGenerator,
            docs: channelDocs,
            cloud: channelCloud,
            ttl: channelTTL,
            image: channelImage,
            textInput: channelTextInput,
            skipSchedule: skipSchedule,
            items: items,
            itunesAuthor: chItunesAuthor,
            itunesBlock: chItunesBlock,
            itunesCategories: chItunesCategories,
            itunesComplete: chItunesComplete,
            itunesExplicit: chItunesExplicit,
            itunesImage: chItunesImage,
            itunesKeywords: chItunesKeywords,
            itunesNewFeedUrl: chItunesNewFeedUrl,
            itunesOwner: chItunesOwner,
            itunesSubtitle: chItunesSubtitle,
            itunesSummary: chItunesSummary,
            itunesTitle: chItunesTitle,
            itunesType: chItunesType,
            itunesVerify: chItunesVerify,
            atomLinks: chAtomLinks,
            dublinCore: chDublinCore,
            podcastGuid: chPodcastGuid,
            locked: chLocked,
            funding: chFunding,
            persons: chPersons,
            location: chLocation,
            license: chLicense,
            value: chValue,
            medium: chMedium,
            podcastBlocks: chPodcastBlocks,
            txtRecords: chTxtRecords,
            podroll: chPodroll,
            updateFrequency: chUpdateFrequency,
            podpingEnabled: chPodpingEnabled,
            trailers: chTrailers,
            liveItems: chLiveItems,
            publisher: chPublisher,
            chat: chChat
        )
        feed.channel = channel
    }

    func finalizeImage() {
        guard let urlStr = imageURL,
            let url = URL(string: urlStr),
            let title = imageTitle,
            let linkStr = imageLink,
            let link = URL(string: linkStr)
        else { return }
        channelImage = RSSImage(
            url: url, title: title, link: link,
            width: imageWidth, height: imageHeight,
            imageDescription: imageDescription
        )
    }

    func finalizeTextInput() {
        guard let title = textInputTitle,
            let desc = textInputDescription,
            let name = textInputName,
            let linkStr = textInputLink,
            let link = URL(string: linkStr)
        else { return }
        channelTextInput = RSSTextInput(
            title: title, description: desc,
            name: name, link: link
        )
    }

    func finalizeITunesOwner() {
        guard let name = ownerName, let email = ownerEmail
        else { return }
        chItunesOwner = ITunesOwner(name: name, email: email)
    }
}
