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
