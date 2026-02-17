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

/// Creates a URL from a compile-time string literal.
///
/// Using `StaticString` ensures only string literals are passed,
/// making the `preconditionFailure` unreachable in practice since
/// `URL(string:)` succeeds for all well-formed literal URLs.
func makeURL(_ string: StaticString) -> URL {
    guard let url = URL(string: "\(string)") else {
        preconditionFailure("Invalid URL string: \(string)")
    }
    return url
}
