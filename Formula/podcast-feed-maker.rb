# Homebrew formula for podcast-feed-maker
#
# Tap: atelier-socle/homebrew-tools
# Install: brew install atelier-socle/tools/podcast-feed-maker

class PodcastFeedMaker < Formula
  desc "CLI tool for generating, parsing, and validating podcast RSS feeds"
  homepage "https://github.com/atelier-socle/podcast-feed-maker"
  url "https://github.com/atelier-socle/podcast-feed-maker/archive/refs/tags/0.1.0.tar.gz"
  sha256 "UPDATE_SHA256_AFTER_RELEASE"
  license "MIT"

  depends_on xcode: ["26.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/podcastfeed"
  end

  test do
    system "#{bin}/podcastfeed", "--help"
  end
end
