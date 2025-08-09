module Reactions
  class BustReactableCacheWorker
    include Sidekiq::Job

    sidekiq_options queue: :high_priority, retry: 10

    def perform(reaction_id)
      reaction = Reaction.find_by(id: reaction_id)
      return unless reaction&.reactable

      urls = [URL.url(reaction.user.path)]

      case reaction.reactable_type
      when "Article"
        urls << URL.url("/reactions?article_id=#{reaction.reactable_id}")
        article = reaction.reactable
        if Reaction.for_articles([reaction.reactable_id]).public_category.size == 1
          EdgeCache::BustArticle.call(article)
        end
      when "Comment"
        path = "/reactions?commentable_id=#{reaction.reactable.commentable_id}&" \
               "commentable_type=#{reaction.reactable.commentable_type}"
        urls << URL.url(path)
      end

      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
