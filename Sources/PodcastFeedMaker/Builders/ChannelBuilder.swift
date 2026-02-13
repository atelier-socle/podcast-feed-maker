import Foundation

// MARK: - Channel Fluent Modifiers

extension Channel {

    /// Sets the podcast author (`itunes:author`).
    ///
    /// - Parameter name: The author's name.
    /// - Returns: A modified copy of the channel.
    public func author(_ name: String) -> Channel {
        var copy = self
        copy.itunesAuthor = name
        return copy
    }

    /// Sets the feed language (BCP 47 / RFC 5646).
    ///
    /// - Parameter code: The language code (e.g., `"en-us"`).
    /// - Returns: A modified copy of the channel.
    public func language(_ code: String) -> Channel {
        var copy = self
        copy.language = code
        return copy
    }

    /// Sets the copyright notice.
    ///
    /// - Parameter notice: The copyright text.
    /// - Returns: A modified copy of the channel.
    public func copyright(_ notice: String) -> Channel {
        var copy = self
        copy.copyright = notice
        return copy
    }

    /// Appends an iTunes category.
    ///
    /// - Parameter category: The category to add.
    /// - Returns: A modified copy of the channel.
    public func category(_ category: ITunesCategory) -> Channel {
        var copy = self
        copy.itunesCategories.append(category)
        return copy
    }

    /// Replaces all iTunes categories.
    ///
    /// - Parameter categories: The categories to set.
    /// - Returns: A modified copy of the channel.
    public func categories(_ categories: [ITunesCategory]) -> Channel {
        var copy = self
        copy.itunesCategories = categories
        return copy
    }

    /// Sets the explicit content flag (`itunes:explicit`).
    ///
    /// - Parameter value: Whether the podcast contains explicit content.
    /// - Returns: A modified copy of the channel.
    public func explicit(_ value: Bool) -> Channel {
        var copy = self
        copy.itunesExplicit = value
        return copy
    }

    /// Sets the podcast artwork URL (`itunes:image`).
    ///
    /// - Parameter urlString: The image URL as a string.
    /// - Returns: A modified copy of the channel. If the URL is invalid, the image is not set.
    public func image(_ urlString: String) -> Channel {
        var copy = self
        copy.itunesImage = URL(string: urlString)
        return copy
    }

    /// Sets the show type (`itunes:type`).
    ///
    /// - Parameter showType: Either `"episodic"` or `"serial"`.
    /// - Returns: A modified copy of the channel.
    public func type(_ showType: String) -> Channel {
        var copy = self
        copy.itunesType = ITunesShowType(rawValue: showType)
        return copy
    }

    /// Sets the iTunes owner contact.
    ///
    /// - Parameters:
    ///   - name: The owner's name.
    ///   - email: The owner's email address.
    /// - Returns: A modified copy of the channel.
    public func owner(name: String, email: String) -> Channel {
        var copy = self
        copy.itunesOwner = ITunesOwner(name: name, email: email)
        return copy
    }

    /// Sets the feed as locked with an owner (`podcast:locked`).
    ///
    /// - Parameter owner: The owner's email or identifier.
    /// - Returns: A modified copy of the channel.
    public func locked(owner: String) -> Channel {
        var copy = self
        copy.locked = Locked(isLocked: true, owner: owner)
        return copy
    }

    /// Sets the podcast GUID (`podcast:guid`).
    ///
    /// - Parameter value: The UUID string.
    /// - Returns: A modified copy of the channel.
    public func guid(_ value: String) -> Channel {
        var copy = self
        copy.podcastGuid = PodcastGuid(value: value)
        return copy
    }

    /// Appends a funding link (`podcast:funding`).
    ///
    /// - Parameters:
    ///   - url: The funding page URL as a string.
    ///   - text: The call-to-action text.
    /// - Returns: A modified copy of the channel. If the URL is invalid, no funding is added.
    public func funding(url: String, text: String) -> Channel {
        var copy = self
        if let fundingURL = URL(string: url) {
            copy.funding.append(Funding(url: fundingURL, message: text))
        }
        return copy
    }

    /// Appends an Atom link.
    ///
    /// - Parameters:
    ///   - href: The link URL as a string.
    ///   - rel: The relationship type (e.g., `"self"`).
    /// - Returns: A modified copy of the channel. If the URL is invalid, no link is added.
    public func atomLink(href: String, rel: String) -> Channel {
        var copy = self
        if let linkURL = URL(string: href) {
            copy.atomLinks.append(AtomLink(href: linkURL, rel: rel))
        }
        return copy
    }

    /// Sets the podcast medium (`podcast:medium`).
    ///
    /// - Parameter medium: The medium type.
    /// - Returns: A modified copy of the channel.
    public func medium(_ medium: PodcastMedium) -> Channel {
        var copy = self
        copy.medium = medium
        return copy
    }

    /// Sets the publisher (`podcast:publisher`).
    ///
    /// - Parameters:
    ///   - name: The publisher name.
    ///   - url: Optional publisher website URL as a string.
    /// - Returns: A modified copy of the channel.
    public func publisher(name: String, url: String? = nil) -> Channel {
        var copy = self
        copy.publisher = PodcastPublisher(
            name: name,
            url: url.flatMap { URL(string: $0) }
        )
        return copy
    }
}
