module Articles
  class BustMultipleCachesWorker
    include Sidekiq::Job
    sidekiq_options queue: :low_priority, retry: 10

    def perform(article_ids)
      Article.select(:id, :path).where(id: article_ids).find_each do |article|
        urls = [
          URL.url(article.path),
          URL.url("#{article.path}?i=i"),
        ]
        EdgeCache::Purger.purge_urls(urls)
      end
    end
  end
end
