module EdgeCache
  class BustPodcast
    def self.call(path)
      return unless path

      EdgeCache::Purger.purge_urls([URL.url("/#{path}")])
    end
  end
end
