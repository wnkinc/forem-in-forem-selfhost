module EdgeCache
  class BustTag
    def self.call(tag)
      return unless tag

      urls = [
        URL.url("/t/#{tag.name}"),
        URL.url("/t/#{tag.name}/"),
        URL.url("/tags"),
      ]

      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
