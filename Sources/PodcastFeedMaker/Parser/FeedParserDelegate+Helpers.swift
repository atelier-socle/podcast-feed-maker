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

// MARK: - Publisher Finalization

extension FeedParserDelegate {

    func finalizePublisher() {
        if let remote = chPublisherRemoteItem {
            chPublisher = PodcastPublisher(remoteItem: remote)
        }
        chPublisherRemoteItem = nil
    }
}

// MARK: - Podcast Image / Images

extension FeedParserDelegate {

    func handlePodcastImageAttributes(_ attrs: [String: String]) {
        guard let hrefStr = attrs["href"],
            let href = URL(string: hrefStr)
        else { return }
        let image = PodcastImage(
            href: href,
            alt: attrs["alt"],
            aspectRatio: attrs["aspect-ratio"],
            width: attrs["width"].flatMap { Int($0) },
            height: attrs["height"].flatMap { Int($0) },
            type: attrs["type"],
            purpose: attrs["purpose"]
        )
        switch currentContext {
        case .channel: chPodcastImages.append(image)
        case .item: currentItem?.podcastImages.append(image)
        default: break
        }
    }

    func handlePodcastImagesSrcsetAttributes(_ attrs: [String: String]) {
        guard let srcset = attrs["srcset"] else { return }
        let images = PodcastImages(srcset: srcset)
        switch currentContext {
        case .channel: chPodcastImagesSrcset = images
        case .item: currentItem?.podcastImagesSrcset = images
        default: break
        }
    }
}

// MARK: - Shared Helpers

extension FeedParserDelegate {

    func buildPerson(
        text: String, attrs: [String: String]
    ) -> PodcastPerson? {
        guard !text.isEmpty else { return nil }
        return PodcastPerson(
            name: text,
            role: attrs["role"],
            group: attrs["group"],
            href: attrs["href"].flatMap { URL(string: $0) },
            img: attrs["img"].flatMap { URL(string: $0) }
        )
    }
}
