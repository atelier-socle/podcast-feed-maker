import Foundation
import PodcastFeedMaker

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Loads and parses podcast feeds from files or URLs.
enum FeedLoader {

    /// Loads raw XML from a file path or URL string.
    ///
    /// - Parameter source: A file path or URL string.
    /// - Returns: The raw XML string.
    static func loadXML(from source: String) throws -> String {
        let resolved = try InputResolver.resolve(source)
        switch resolved {
        case .file(let path):
            return try loadFile(path)
        case .url(let url):
            return try loadURL(url)
        }
    }

    /// Loads and parses a feed from a file path or URL string.
    ///
    /// - Parameter source: A file path or URL string.
    /// - Returns: The parsed podcast feed.
    static func load(from source: String) throws -> PodcastFeed {
        let xml = try loadXML(from: source)
        return try FeedParser().parse(xml)
    }

    // MARK: - Private

    private static func loadFile(_ path: String) throws -> String {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw InputError.fileNotFound(path)
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw InputError.fileReadError(path, error)
        }
    }

    private static func loadURL(_ url: URL) throws -> String {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw InputError.fileReadError(url.absoluteString, error)
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw InputError.fileReadError(
                url.absoluteString,
                NSError(
                    domain: "FeedLoader",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Cannot decode response as UTF-8"]
                ))
        }
        return string
    }
}
