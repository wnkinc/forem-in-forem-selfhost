module EdgeCache
  class BustPodcastEpisode
    def self.call(podcast_episode, path, podcast_slug)
      return unless podcast_episode && path && podcast_slug

      urls = [
        URL.url(path),
        URL.url("/#{podcast_slug}"),
        URL.url("/pod"),
      ]

      EdgeCache::Purger.purge_urls(urls)
    rescue StandardError => e
      Rails.logger.warn(e)
    end
  end
end
