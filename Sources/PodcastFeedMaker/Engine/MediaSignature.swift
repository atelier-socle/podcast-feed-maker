import Foundation

// MARK: - MediaSignature

/// Known file signatures (magic bytes) for detecting media file formats.
///
/// Each signature defines a human-readable name, a set of compatible MIME types,
/// and a matcher closure that inspects raw bytes to determine format.
///
/// ## Usage
///
/// ```swift
/// let data = ... // first 12 bytes of a file
/// if let signature = MediaSignature.detect(from: data) {
///     print(signature.name) // e.g. "MP3 (ID3)"
/// }
/// ```
internal struct MediaSignature: Sendable {

    /// Human-readable format name (e.g., "MP3 (ID3)", "JPEG", "PNG").
    let name: String

    /// Set of MIME types compatible with this format.
    let mimeTypes: Set<String>

    /// Closure that inspects raw bytes and returns `true` if they match this signature.
    let matcher: @Sendable (Data) -> Bool

    // MARK: - Detection

    /// Attempts to detect the file format from raw bytes.
    ///
    /// Iterates through all known signatures and returns the first match.
    /// Order matters: more specific signatures (e.g., WAV, AVI) are checked
    /// before generic ones (e.g., RIFF).
    ///
    /// - Parameter data: The raw bytes to inspect (typically first 12 bytes).
    /// - Returns: The matching signature, or `nil` if no match is found.
    static func detect(from data: Data) -> MediaSignature? {
        guard !data.isEmpty else { return nil }
        for signature in allSignatures where signature.matcher(data) {
            return signature
        }
        return nil
    }

    // MARK: - Known Signatures

    /// All known file signatures, ordered for correct detection priority.
    ///
    /// More specific signatures (WAV, AVI, MOV) must precede generic ones
    /// (ftyp container) to avoid false positives.
    static let allSignatures: [MediaSignature] = [
        // Audio: MP3 with ID3 tag
        MediaSignature(
            name: "MP3 (ID3)",
            mimeTypes: ["audio/mpeg", "audio/mp3"],
            matcher: { data in
                guard data.count >= 3 else { return false }
                return data[data.startIndex] == 0x49
                    && data[data.startIndex + 1] == 0x44
                    && data[data.startIndex + 2] == 0x33
            }
        ),
        // Audio: MP3 sync word
        MediaSignature(
            name: "MP3",
            mimeTypes: ["audio/mpeg", "audio/mp3"],
            matcher: { data in
                guard data.count >= 2 else { return false }
                let first = data[data.startIndex]
                let second = data[data.startIndex + 1]
                return first == 0xFF
                    && (second == 0xFB || second == 0xF3 || second == 0xF2)
            }
        ),
        // Audio: OGG Vorbis
        MediaSignature(
            name: "OGG Vorbis",
            mimeTypes: ["audio/ogg", "application/ogg"],
            matcher: { data in
                guard data.count >= 4 else { return false }
                return data[data.startIndex] == 0x4F
                    && data[data.startIndex + 1] == 0x67
                    && data[data.startIndex + 2] == 0x67
                    && data[data.startIndex + 3] == 0x53
            }
        ),
        // Audio: FLAC
        MediaSignature(
            name: "FLAC",
            mimeTypes: ["audio/flac", "audio/x-flac"],
            matcher: { data in
                guard data.count >= 4 else { return false }
                return data[data.startIndex] == 0x66
                    && data[data.startIndex + 1] == 0x4C
                    && data[data.startIndex + 2] == 0x61
                    && data[data.startIndex + 3] == 0x43
            }
        ),
        // Audio: WAV (RIFF + WAVE) — must precede generic RIFF checks
        MediaSignature(
            name: "WAV",
            mimeTypes: ["audio/wav", "audio/x-wav"],
            matcher: { data in
                guard data.count >= 12 else { return false }
                return data[data.startIndex] == 0x52
                    && data[data.startIndex + 1] == 0x49
                    && data[data.startIndex + 2] == 0x46
                    && data[data.startIndex + 3] == 0x46
                    && data[data.startIndex + 8] == 0x57
                    && data[data.startIndex + 9] == 0x41
                    && data[data.startIndex + 10] == 0x56
                    && data[data.startIndex + 11] == 0x45
            }
        ),
        // Video: AVI (RIFF + AVI) — must precede generic RIFF checks
        MediaSignature(
            name: "AVI",
            mimeTypes: ["video/x-msvideo", "video/avi"],
            matcher: { data in
                guard data.count >= 12 else { return false }
                return data[data.startIndex] == 0x52
                    && data[data.startIndex + 1] == 0x49
                    && data[data.startIndex + 2] == 0x46
                    && data[data.startIndex + 3] == 0x46
                    && data[data.startIndex + 8] == 0x41
                    && data[data.startIndex + 9] == 0x56
                    && data[data.startIndex + 10] == 0x49
                    && data[data.startIndex + 11] == 0x20
            }
        ),
        // Audio: WMA (ASF header)
        MediaSignature(
            name: "WMA",
            mimeTypes: ["audio/x-ms-wma"],
            matcher: { data in
                guard data.count >= 8 else { return false }
                return data[data.startIndex] == 0x30
                    && data[data.startIndex + 1] == 0x26
                    && data[data.startIndex + 2] == 0xB2
                    && data[data.startIndex + 3] == 0x75
                    && data[data.startIndex + 4] == 0x8E
                    && data[data.startIndex + 5] == 0x66
                    && data[data.startIndex + 6] == 0xCF
                    && data[data.startIndex + 7] == 0x11
            }
        ),
        // Video: MOV (ftypqt or moov)
        MediaSignature(
            name: "MOV",
            mimeTypes: ["video/quicktime"],
            matcher: { data in
                guard data.count >= 8 else { return false }
                // Check for "ftypqt" at offset 4
                if data.count >= 10
                    && data[data.startIndex + 4] == 0x66
                    && data[data.startIndex + 5] == 0x74
                    && data[data.startIndex + 6] == 0x79
                    && data[data.startIndex + 7] == 0x70
                    && data[data.startIndex + 8] == 0x71
                    && data[data.startIndex + 9] == 0x74
                {
                    return true
                }
                // Check for "moov" at start
                return data[data.startIndex] == 0x6D
                    && data[data.startIndex + 1] == 0x6F
                    && data[data.startIndex + 2] == 0x6F
                    && data[data.startIndex + 3] == 0x76
            }
        ),
        // MPEG-4 container (ftyp) — covers M4A, M4B, M4V, MP4
        // Must come after MOV to avoid false positives
        MediaSignature(
            name: "MPEG-4 container",
            mimeTypes: [
                "audio/x-m4a", "audio/mp4", "audio/aac", "audio/x-m4b",
                "video/mp4", "video/x-m4v"
            ],
            matcher: { data in
                guard data.count >= 8 else { return false }
                // "ftyp" at offset 4
                return data[data.startIndex + 4] == 0x66
                    && data[data.startIndex + 5] == 0x74
                    && data[data.startIndex + 6] == 0x79
                    && data[data.startIndex + 7] == 0x70
            }
        ),
        // Document: PDF
        MediaSignature(
            name: "PDF",
            mimeTypes: ["application/pdf"],
            matcher: { data in
                guard data.count >= 4 else { return false }
                return data[data.startIndex] == 0x25
                    && data[data.startIndex + 1] == 0x50
                    && data[data.startIndex + 2] == 0x44
                    && data[data.startIndex + 3] == 0x46
            }
        ),
        // Image: JPEG
        MediaSignature(
            name: "JPEG",
            mimeTypes: ["image/jpeg"],
            matcher: { data in
                guard data.count >= 3 else { return false }
                return data[data.startIndex] == 0xFF
                    && data[data.startIndex + 1] == 0xD8
                    && data[data.startIndex + 2] == 0xFF
            }
        ),
        // Image: PNG
        MediaSignature(
            name: "PNG",
            mimeTypes: ["image/png"],
            matcher: { data in
                guard data.count >= 8 else { return false }
                return data[data.startIndex] == 0x89
                    && data[data.startIndex + 1] == 0x50
                    && data[data.startIndex + 2] == 0x4E
                    && data[data.startIndex + 3] == 0x47
                    && data[data.startIndex + 4] == 0x0D
                    && data[data.startIndex + 5] == 0x0A
                    && data[data.startIndex + 6] == 0x1A
                    && data[data.startIndex + 7] == 0x0A
            }
        )
    ]
}
