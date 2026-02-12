import Foundation

// MARK: - FeedGenerator + RSS 2.0, iTunes, Atom

extension FeedGenerator {

    // MARK: - RSS 2.0 Simple Types

    func generateEnclosure(_ enclosure: Enclosure, builder b: XMLBuilder) -> String {
        b.selfClosingElement(
            "enclosure",
            attributes: [
                ("url", XMLBuilder.encodeURL(enclosure.url)),
                ("length", "\(enclosure.length)"),
                ("type", "\(enclosure.type)")
            ]
        )
    }

    func generateGUID(_ guid: GUID, builder b: XMLBuilder) -> String {
        b.element("guid", content: guid.value, attributes: [("isPermaLink", "\(guid.isPermaLink)")])
    }

    func generateRSSCategory(_ category: RSSCategory, builder b: XMLBuilder) -> String {
        if let domain = category.domain {
            return b.element("category", content: category.value, attributes: [("domain", domain)])
        }
        return b.element("category", content: category.value)
    }

    func generateRSSSource(_ source: RSSSource, builder b: XMLBuilder) -> String {
        b.element("source", content: source.title, attributes: [("url", XMLBuilder.encodeURL(source.url))])
    }

    func generateRSSImage(_ image: RSSImage, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("image"))
        let b2 = b.indented()
        lines.append(b2.element("url", content: XMLBuilder.encodeURL(image.url)))
        lines.append(b2.element("title", content: image.title))
        lines.append(b2.element("link", content: XMLBuilder.encodeURL(image.link)))
        if let width = image.width { lines.append(b2.element("width", content: "\(width)")) }
        if let height = image.height { lines.append(b2.element("height", content: "\(height)")) }
        if let desc = image.imageDescription { lines.append(b2.element("description", content: desc)) }
        lines.append(b.closeTag("image"))
        return lines
    }

    func generateRSSCloud(_ cloud: RSSCloud, builder b: XMLBuilder) -> String {
        b.selfClosingElement(
            "cloud",
            attributes: [
                ("domain", cloud.domain),
                ("port", "\(cloud.port)"),
                ("path", cloud.path),
                ("registerProcedure", cloud.registerProcedure),
                ("protocol", cloud.protocolType)
            ]
        )
    }

    func generateRSSTextInput(_ textInput: RSSTextInput, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("textInput"))
        let b2 = b.indented()
        lines.append(b2.element("title", content: textInput.title))
        lines.append(b2.element("description", content: textInput.description))
        lines.append(b2.element("name", content: textInput.name))
        lines.append(b2.element("link", content: XMLBuilder.encodeURL(textInput.link)))
        lines.append(b.closeTag("textInput"))
        return lines
    }

    func generateSkipSchedule(_ schedule: SkipSchedule, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        let b2 = b.indented()
        if !schedule.hours.isEmpty {
            lines.append(b.openTag("skipHours"))
            for hour in schedule.hours.sorted() {
                lines.append(b2.element("hour", content: "\(hour)"))
            }
            lines.append(b.closeTag("skipHours"))
        }
        if !schedule.days.isEmpty {
            lines.append(b.openTag("skipDays"))
            for day in schedule.days.sorted(by: { $0.rawValue < $1.rawValue }) {
                lines.append(b2.element("day", content: day.rawValue))
            }
            lines.append(b.closeTag("skipDays"))
        }
        return lines
    }

    // MARK: - iTunes Types

    func generateITunesCategory(_ category: ITunesCategory, builder b: XMLBuilder) -> [String] {
        if category.subcategories.isEmpty {
            return [b.selfClosingElement("itunes:category", attributes: [("text", XMLBuilder.escape(category.text))])]
        }
        var lines: [String] = []
        lines.append(b.openTag("itunes:category", attributes: [("text", XMLBuilder.escape(category.text))]))
        let b2 = b.indented()
        for sub in category.subcategories {
            lines.append(b2.selfClosingElement("itunes:category", attributes: [("text", XMLBuilder.escape(sub.text))]))
        }
        lines.append(b.closeTag("itunes:category"))
        return lines
    }

    func generateITunesOwner(_ owner: ITunesOwner, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("itunes:owner"))
        let b2 = b.indented()
        lines.append(b2.element("itunes:name", content: owner.name))
        lines.append(b2.element("itunes:email", content: owner.email))
        lines.append(b.closeTag("itunes:owner"))
        return lines
    }

    // MARK: - Atom Types

    func generateAtomLink(_ link: AtomLink, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(link.href))]
        if let rel = link.rel { attrs.append(("rel", rel)) }
        if let type = link.type { attrs.append(("type", type)) }
        if let hreflang = link.hreflang { attrs.append(("hreflang", hreflang)) }
        if let title = link.title { attrs.append(("title", XMLBuilder.escape(title))) }
        if let length = link.length { attrs.append(("length", "\(length)")) }
        return b.selfClosingElement("atom:link", attributes: attrs)
    }
}
