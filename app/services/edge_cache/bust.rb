module EdgeCache
  class Bust
    def self.call(*paths)
      urls = Array(paths).flatten.map { |path| URL.url(path) }
      EdgeCache::Purger.purge_urls(urls)
    end

    def call(*paths)
      self.class.call(*paths)
    end
  end
end
