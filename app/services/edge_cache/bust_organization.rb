module EdgeCache
  class BustOrganization
    def self.call(organization, slug)
      return unless organization && slug

      urls = [URL.url("/#{slug}")]

      begin
        organization.articles.find_each do |article|
          urls << URL.article(article)
        end
      rescue StandardError => e
        Rails.logger.error("Tag issue: #{e}")
      end

      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
