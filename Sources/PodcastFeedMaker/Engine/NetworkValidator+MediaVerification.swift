// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - Media Type Verification & Artwork Dimension Checking

extension NetworkValidator {

    // MARK: - Public API

    /// Verifies actual media file types by downloading first 12 bytes (magic bytes).
    ///
    /// For each enclosure in the feed, downloads the first 12 bytes via a Range
    /// request, detects the actual file format using magic-byte signatures, and
    /// compares it against the declared MIME type.
    ///
    /// For artwork URLs, verifies that the file is a JPEG or PNG.
    ///
    /// - Parameter feed: The feed whose media URLs to verify.
    /// - Returns: Validation results for mismatches, unknown formats, and errors.
    public func verifyMediaTypes(
        _ feed: PodcastFeed
    ) async throws -> [ValidationResult] {
        let entries = extractMediaVerificationEntries(from: feed)
        guard !entries.isEmpty else { return [] }

        return await withTaskGroup(
            of: [ValidationResult].self,
            returning: [ValidationResult].self
        ) { group in
            var results: [ValidationResult] = []
            var pending = 0

            for entry in entries {
                if pending >= maxConcurrency {
                    if let batch = await group.next() {
                        results += batch
                        pending -= 1
                    }
                }

                group.addTask {
                    await self.verifySingleMediaType(entry)
                }
                pending += 1
            }

            for await batch in group {
                results += batch
            }

            return results
        }
    }

    /// Checks artwork image dimensions and aspect ratio by downloading first 1024 bytes.
    ///
    /// For each artwork URL in the feed, downloads the first 1024 bytes via a Range
    /// request, detects the image format, parses dimensions, and validates against
    /// platform-specific requirements.
    ///
    /// Platform requirements:
    /// - **Apple**: 1400-3000px, square required
    /// - **Spotify**: 1400-2048px, square required
    /// - **Amazon**: 1400-3000px, square recommended
    /// - **Podcast Index / PSP-1**: no dimension requirements
    ///
    /// - Parameters:
    ///   - feed: The feed whose artwork URLs to check.
    ///   - platform: The target platform for dimension requirements.
    /// - Returns: Validation results for dimension issues and errors.
    public func checkArtworkDimensions(
        _ feed: PodcastFeed,
        for platform: ValidationPlatform
    ) async throws -> [ValidationResult] {
        let entries = extractArtworkDimensionEntries(from: feed)
        guard !entries.isEmpty else { return [] }

        return await withTaskGroup(
            of: [ValidationResult].self,
            returning: [ValidationResult].self
        ) { group in
            var results: [ValidationResult] = []
            var pending = 0

            for entry in entries {
                if pending >= maxConcurrency {
                    if let batch = await group.next() {
                        results += batch
                        pending -= 1
                    }
                }

                group.addTask {
                    await self.checkSingleArtworkDimensions(entry, for: platform)
                }
                pending += 1
            }

            for await batch in group {
                results += batch
            }

            return results
        }
    }

    // MARK: - Entry Extraction

    /// Entry for media type verification.
    struct MediaVerificationEntry: Sendable {
        let url: URL
        let declaredType: String?
        let field: String
        let isArtwork: Bool
    }

    func extractMediaVerificationEntries(
        from feed: PodcastFeed
    ) -> [MediaVerificationEntry] {
        guard let channel = feed.channel else { return [] }
        var entries: [MediaVerificationEntry] = []

        if let imageURL = channel.itunesImage {
            entries.append(
                MediaVerificationEntry(
                    url: imageURL, declaredType: nil,
                    field: "channel.itunesImage", isArtwork: true
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let enclosure = item.enclosure {
                entries.append(
                    MediaVerificationEntry(
                        url: enclosure.url, declaredType: enclosure.type,
                        field: "channel.items[\(idx)].enclosure", isArtwork: false
                    ))
            }
            if let imageURL = item.itunesImage {
                entries.append(
                    MediaVerificationEntry(
                        url: imageURL, declaredType: nil,
                        field: "channel.items[\(idx)].itunesImage", isArtwork: true
                    ))
            }
        }

        for (idx, liveItem) in channel.liveItems.enumerated() {
            if let enclosure = liveItem.enclosure {
                entries.append(
                    MediaVerificationEntry(
                        url: enclosure.url, declaredType: enclosure.type,
                        field: "channel.liveItems[\(idx)].enclosure", isArtwork: false
                    ))
            }
            if let imageURL = liveItem.itunesImage {
                entries.append(
                    MediaVerificationEntry(
                        url: imageURL, declaredType: nil,
                        field: "channel.liveItems[\(idx)].itunesImage", isArtwork: true
                    ))
            }
        }

        return entries
    }

    /// Entry for artwork dimension checking.
    struct ArtworkDimensionEntry: Sendable {
        let url: URL
        let field: String
    }

    func extractArtworkDimensionEntries(
        from feed: PodcastFeed
    ) -> [ArtworkDimensionEntry] {
        guard let channel = feed.channel else { return [] }
        var entries: [ArtworkDimensionEntry] = []

        if let imageURL = channel.itunesImage {
            entries.append(
                ArtworkDimensionEntry(url: imageURL, field: "channel.itunesImage"))
        }

        for (idx, item) in channel.items.enumerated() {
            if let imageURL = item.itunesImage {
                entries.append(
                    ArtworkDimensionEntry(
                        url: imageURL, field: "channel.items[\(idx)].itunesImage"
                    ))
            }
        }

        return entries
    }

    // MARK: - Single URL Verification

    private func verifySingleMediaType(
        _ entry: MediaVerificationEntry
    ) async -> [ValidationResult] {
        do {
            let data = try await downloadBytes(from: entry.url, byteCount: 12)
            guard let signature = MediaSignature.detect(from: data) else {
                return [unrecognizedFormatResult(for: entry)]
            }
            return matchSignature(signature, against: entry)
        } catch {
            return [
                ValidationResult(
                    severity: .warning,
                    message: "Could not verify media type for \(entry.url.absoluteString): "
                        + error.localizedDescription,
                    field: entry.field
                )
            ]
        }
    }

    /// Returns the result when no signature is detected for a media entry.
    private func unrecognizedFormatResult(
        for entry: MediaVerificationEntry
    ) -> ValidationResult {
        if entry.isArtwork {
            return ValidationResult(
                severity: .warning,
                message: "Artwork at \(entry.url.absoluteString) does not appear to be JPEG or PNG",
                field: entry.field
            )
        }
        return ValidationResult(
            severity: .info,
            message: "Could not determine actual file type for \(entry.url.absoluteString)",
            field: entry.field
        )
    }

    /// Compares a detected signature against the entry's declared type.
    private func matchSignature(
        _ signature: MediaSignature,
        against entry: MediaVerificationEntry
    ) -> [ValidationResult] {
        if entry.isArtwork {
            let imageTypes: Set<String> = ["image/jpeg", "image/png"]
            if signature.mimeTypes.isDisjoint(with: imageTypes) {
                return [
                    ValidationResult(
                        severity: .warning,
                        message: "Artwork at \(entry.url.absoluteString) "
                            + "does not appear to be JPEG or PNG",
                        field: entry.field
                    )
                ]
            }
            return []
        }

        if let declaredType = entry.declaredType {
            let normalizedDeclared = declaredType.lowercased()
            let normalizedMimeTypes = Set(signature.mimeTypes.map { $0.lowercased() })
            if !normalizedMimeTypes.contains(normalizedDeclared) {
                return [
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure at \(entry.url.absoluteString) declares \(declaredType) "
                            + "but file signature indicates \(signature.name)",
                        field: entry.field
                    )
                ]
            }
        }

        return []
    }

    private func checkSingleArtworkDimensions(
        _ entry: ArtworkDimensionEntry,
        for platform: ValidationPlatform
    ) async -> [ValidationResult] {
        do {
            let data = try await downloadBytes(from: entry.url, byteCount: 1024)
            guard let dimensions = ImageDimensionParser.parse(data) else {
                return [
                    ValidationResult(
                        severity: .info,
                        message: "Could not determine dimensions for \(entry.url.absoluteString)",
                        field: entry.field,
                        platform: platform
                    )
                ]
            }
            return validateDimensions(
                dimensions, url: entry.url, field: entry.field, for: platform)
        } catch {
            return [
                ValidationResult(
                    severity: .warning,
                    message: "Could not check artwork dimensions for \(entry.url.absoluteString): "
                        + error.localizedDescription,
                    field: entry.field,
                    platform: platform
                )
            ]
        }
    }

    // MARK: - Dimension Validation

    private func validateDimensions(
        _ dimensions: ImageDimensionParser.Dimensions,
        url: URL,
        field: String,
        for platform: ValidationPlatform
    ) -> [ValidationResult] {
        guard let requirements = platformDimensionRequirements(for: platform) else {
            return []
        }

        var results: [ValidationResult] = []
        let urlString = url.absoluteString
        let width = dimensions.width
        let height = dimensions.height

        if let minSize = requirements.minSize,
            width < minSize || height < minSize
        {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Artwork at \(urlString) is \(width)\u{00D7}\(height), "
                        + "minimum is \(minSize)\u{00D7}\(minSize) for \(platform.rawValue)",
                    field: field,
                    platform: platform
                ))
        }

        if let maxSize = requirements.maxSize,
            width > maxSize || height > maxSize
        {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Artwork at \(urlString) is \(width)\u{00D7}\(height), "
                        + "maximum is \(maxSize)\u{00D7}\(maxSize) for \(platform.rawValue)",
                    field: field,
                    platform: platform
                ))
        }

        if !dimensions.isSquare {
            switch requirements.aspectRatio {
            case .required:
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Artwork at \(urlString) is \(width)\u{00D7}\(height), "
                            + "must be square (1:1 aspect ratio) for \(platform.rawValue)",
                        field: field,
                        platform: platform
                    ))
            case .recommended:
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Artwork at \(urlString) is \(width)\u{00D7}\(height), "
                            + "square (1:1) recommended for \(platform.rawValue)",
                        field: field,
                        platform: platform
                    ))
            case .none:
                break
            }
        }

        return results
    }

    // MARK: - Platform Requirements

    /// Aspect ratio requirement level.
    enum AspectRatioRequirement: Sendable {
        case required
        case recommended
        case none
    }

    /// Dimension requirements for a platform.
    struct DimensionRequirements: Sendable {
        let minSize: Int?
        let maxSize: Int?
        let aspectRatio: AspectRatioRequirement
    }

    func platformDimensionRequirements(
        for platform: ValidationPlatform
    ) -> DimensionRequirements? {
        switch platform {
        case .apple:
            return DimensionRequirements(
                minSize: 1400, maxSize: 3000, aspectRatio: .required)
        case .spotify:
            return DimensionRequirements(
                minSize: 1400, maxSize: 2048, aspectRatio: .required)
        case .amazon:
            return DimensionRequirements(
                minSize: 1400, maxSize: 3000, aspectRatio: .recommended)
        case .podcastIndex, .psp1:
            return nil
        }
    }

    // MARK: - Byte Download

    func downloadBytes(
        from url: URL, byteCount: Int
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(
            "bytes=0-\(byteCount - 1)",
            forHTTPHeaderField: "Range")
        request.timeoutInterval = timeout

        let (data, _) = try await session.data(for: request)

        if data.count > byteCount {
            return data.prefix(byteCount)
        }
        return data
    }
}
