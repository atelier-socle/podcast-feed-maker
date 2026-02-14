// MARK: - AuditCategory

/// The 5 audit categories with their weights and point allocations.
///
/// Each category contributes a weighted fraction to the global score:
/// - **Metadata** (25%): Channel metadata quality
/// - **Episodes** (25%): Episode completeness and quality
/// - **Compliance** (20%): Standards conformity (PSP-1, Podcast NS)
/// - **Accessibility** (15%): Transcripts, chapters, rich descriptions
/// - **Discoverability** (15%): SEO, keywords, links, social
public enum AuditCategory: String, Sendable, Equatable, Hashable, Codable, CaseIterable {
    case metadata
    case episodes
    case compliance
    case accessibility
    case discoverability

    /// Weight as a fraction — all weights sum to 1.0.
    public var weight: Double {
        switch self {
        case .metadata: 0.25
        case .episodes: 0.25
        case .compliance: 0.20
        case .accessibility: 0.15
        case .discoverability: 0.15
        }
    }

    /// Human-readable display name.
    public var displayName: String {
        switch self {
        case .metadata: "Metadata"
        case .episodes: "Episodes"
        case .compliance: "Compliance"
        case .accessibility: "Accessibility"
        case .discoverability: "Discoverability"
        }
    }

    /// Maximum raw points for this category.
    public var maxPoints: Int {
        switch self {
        case .metadata: 25
        case .episodes: 25
        case .compliance: 20
        case .accessibility: 15
        case .discoverability: 15
        }
    }
}
