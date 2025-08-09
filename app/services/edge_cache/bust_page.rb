module EdgeCache
  class BustPage
    def self.call(slug)
      return unless slug

      urls = [
        URL.url("/page/#{slug}"),
        URL.url("/#{slug}"),
      ]

      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
