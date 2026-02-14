import ArgumentParser

/// The root command for the `podcastfeed` CLI tool.
///
/// Groups all subcommands for podcast feed generation, parsing,
/// validation, and transformation.
public struct PodcastFeedCommand: ParsableCommand {

    public static let configuration = CommandConfiguration(
        commandName: "podcastfeed",
        abstract: "A toolkit for generating, parsing, and validating podcast RSS feeds.",
        version: "0.1.0",
        subcommands: [
            InitCommand.self,
            LintCommand.self,
            ValidateCommand.self,
            ReadCommand.self,
            EpisodesCommand.self,
            ChaptersCommand.self,
            DiffCommand.self,
            GenerateCommand.self,
            ConvertCommand.self,
            AddEpisodeCommand.self,
            OPMLExportCommand.self,
            OPMLImportCommand.self,
            AuditCommand.self
        ],
        defaultSubcommand: nil
    )

    // MARK: - Global Options

    /// Disables colored output.
    @Flag(name: .long, help: "Disable colored output.")
    public var noColor: Bool = false

    public init() {}
}
