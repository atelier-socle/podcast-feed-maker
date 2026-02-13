import Foundation

// MARK: - ImageDimensionParser

/// Extracts image dimensions from raw header bytes.
///
/// Supports PNG (IHDR chunk) and JPEG (SOF marker) formats.
/// Only the first few hundred bytes are needed — typically 24 bytes for PNG
/// and up to 1024 bytes for JPEG (to locate the SOF marker after EXIF data).
///
/// ## Usage
///
/// ```swift
/// let data = ... // first 1024 bytes of an image file
/// if let dims = ImageDimensionParser.parse(data) {
///     print("\(dims.width)×\(dims.height), square: \(dims.isSquare)")
/// }
/// ```
internal struct ImageDimensionParser: Sendable {

    /// Image dimensions with convenience properties.
    struct Dimensions: Sendable, Equatable {

        /// The image width in pixels.
        let width: Int

        /// The image height in pixels.
        let height: Int

        /// Whether the image is square (width equals height).
        var isSquare: Bool { width == height }

        /// The aspect ratio (width / height).
        var aspectRatio: Double { Double(width) / Double(height) }
    }

    // MARK: - PNG

    /// Parses PNG dimensions from IHDR chunk header bytes.
    ///
    /// PNG stores dimensions in the IHDR chunk immediately after the 8-byte signature:
    /// - Bytes 0-7: PNG signature
    /// - Bytes 8-11: IHDR chunk length
    /// - Bytes 12-15: "IHDR" chunk type
    /// - Bytes 16-19: Width (big-endian UInt32)
    /// - Bytes 20-23: Height (big-endian UInt32)
    ///
    /// - Parameter data: Raw PNG header bytes (minimum 24 bytes required).
    /// - Returns: The dimensions, or `nil` if the data is too short or not valid PNG.
    static func parsePNG(_ data: Data) -> Dimensions? {
        guard data.count >= 24 else { return nil }

        // Verify PNG signature
        guard data[data.startIndex] == 0x89,
            data[data.startIndex + 1] == 0x50,
            data[data.startIndex + 2] == 0x4E,
            data[data.startIndex + 3] == 0x47,
            data[data.startIndex + 4] == 0x0D,
            data[data.startIndex + 5] == 0x0A,
            data[data.startIndex + 6] == 0x1A,
            data[data.startIndex + 7] == 0x0A
        else { return nil }

        let width = readUInt32BigEndian(data, at: 16)
        let height = readUInt32BigEndian(data, at: 20)

        guard width > 0, height > 0 else { return nil }

        return Dimensions(width: Int(width), height: Int(height))
    }

    // MARK: - JPEG

    /// Parses JPEG dimensions from SOF marker header bytes.
    ///
    /// JPEG dimensions are in a SOF (Start of Frame) marker (FF C0, FF C1, or FF C2).
    /// The SOF marker can appear at variable offsets after APP0, APP1/EXIF, and other
    /// markers. This method scans through the data looking for SOF markers.
    ///
    /// - Parameter data: Raw JPEG header bytes (typically 1024 bytes to ensure
    ///   the SOF marker is captured).
    /// - Returns: The dimensions, or `nil` if no SOF marker is found.
    static func parseJPEG(_ data: Data) -> Dimensions? {
        guard data.count >= 10 else { return nil }

        // Verify JPEG SOI marker
        guard data[data.startIndex] == 0xFF,
            data[data.startIndex + 1] == 0xD8
        else { return nil }

        var offset = 2

        while offset < data.count - 8 {
            guard data[data.startIndex + offset] == 0xFF else {
                offset += 1
                continue
            }

            let marker = data[data.startIndex + offset + 1]

            // SOF markers: SOF0 (0xC0), SOF1 (0xC1), SOF2 (0xC2)
            if marker == 0xC0 || marker == 0xC1 || marker == 0xC2 {
                // SOF structure: FF Cx, 2 bytes length, 1 byte precision,
                // 2 bytes height, 2 bytes width
                let heightOffset = offset + 5
                let widthOffset = offset + 7

                guard widthOffset + 1 < data.count else { return nil }

                let height = readUInt16BigEndian(data, at: heightOffset)
                let width = readUInt16BigEndian(data, at: widthOffset)

                guard width > 0, height > 0 else { return nil }

                return Dimensions(width: Int(width), height: Int(height))
            }

            // Skip fill bytes and special markers
            if marker == 0x00 || marker == 0xFF || marker == 0xD8 {
                offset += 1
                continue
            }

            // Skip this segment: next 2 bytes are segment length
            guard offset + 3 < data.count else { return nil }

            let segmentLength = readUInt16BigEndian(data, at: offset + 2)
            offset += 2 + Int(segmentLength)
        }

        return nil
    }

    // MARK: - Auto-detect

    /// Auto-detects the image format and parses dimensions.
    ///
    /// Tries PNG first (8-byte signature check), then JPEG (FF D8 check).
    ///
    /// - Parameter data: Raw image header bytes.
    /// - Returns: The dimensions, or `nil` if the format is unrecognized or
    ///   dimensions cannot be extracted.
    static func parse(_ data: Data) -> Dimensions? {
        if let png = parsePNG(data) {
            return png
        }
        return parseJPEG(data)
    }

    // MARK: - Byte Helpers

    /// Reads a big-endian UInt32 from data at the given byte offset.
    private static func readUInt32BigEndian(_ data: Data, at offset: Int) -> UInt32 {
        let base = data.startIndex + offset
        return UInt32(data[base]) << 24
            | UInt32(data[base + 1]) << 16
            | UInt32(data[base + 2]) << 8
            | UInt32(data[base + 3])
    }

    /// Reads a big-endian UInt16 from data at the given byte offset.
    private static func readUInt16BigEndian(_ data: Data, at offset: Int) -> UInt16 {
        let base = data.startIndex + offset
        return UInt16(data[base]) << 8 | UInt16(data[base + 1])
    }
}
