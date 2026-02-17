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

/// ANSI terminal color support with `NO_COLOR` and `--no-color` awareness.
///
/// Respects the `NO_COLOR` environment variable (https://no-color.org/)
/// and the `--no-color` command-line flag.
enum ColorOutput {

    /// Whether colored output is enabled.
    ///
    /// Computed from immutable state: `NO_COLOR` env var and `--no-color` CLI flag.
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["NO_COLOR"] == nil
            && !CommandLine.arguments.contains("--no-color")
    }

    /// Wraps text in red ANSI escape codes.
    static func error(_ text: String) -> String {
        wrap(text, code: "31")
    }

    /// Wraps text in yellow ANSI escape codes.
    static func warning(_ text: String) -> String {
        wrap(text, code: "33")
    }

    /// Wraps text in green ANSI escape codes.
    static func success(_ text: String) -> String {
        wrap(text, code: "32")
    }

    /// Wraps text in blue ANSI escape codes.
    static func info(_ text: String) -> String {
        wrap(text, code: "34")
    }

    /// Wraps text in bold ANSI escape codes.
    static func bold(_ text: String) -> String {
        wrap(text, code: "1")
    }

    /// Wraps text in dim ANSI escape codes.
    static func dim(_ text: String) -> String {
        wrap(text, code: "2")
    }

    private static func wrap(_ text: String, code: String) -> String {
        guard isEnabled else { return text }
        return "\u{001B}[\(code)m\(text)\u{001B}[0m"
    }
}
