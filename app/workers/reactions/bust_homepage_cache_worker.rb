module Reactions
  class BustHomepageCacheWorker
    include Sidekiq::Job

    sidekiq_options queue: :high_priority, retry: 10

    def perform(reaction_id)
      reaction = Reaction.find_by(id: reaction_id, reactable_type: "Article")
      return unless reaction&.reactable

      featured_articles_ids = Article.featured.order(hotness_score: :desc).limit(3).ids
      return unless featured_articles_ids.include?(reaction.reactable_id)

      reaction.reactable.touch
      urls = ["/", "/?i=i"].map { |p| URL.url(p) }
      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
