module EdgeCache
  class BustComment
    def self.call(commentable)
      return unless commentable

      paths = []
      paths.concat(article_comment_paths(commentable)) if commentable.is_a?(Article)
      commentable.touch(:last_comment_at) if commentable.respond_to?(:last_comment_at)

      paths << "#{commentable.path}/comments/"
      paths << commentable.path.to_s

      commentable.comments.includes(:user).find_each do |comment|
        paths << comment.path
      end

      urls = paths.map { |path| URL.url(path) }
      EdgeCache::Purger.purge_urls(urls)
    end

    # bust commentable if it's an article
    def self.article_comment_paths(article)
      paths = []
      paths << "/" if Article.published.order(hotness_score: :desc).limit(3).ids.include?(article.id)
      paths << "/" if article.decorate.discussion?
      paths
    end

    private_class_method :article_comment_paths
  end
end
