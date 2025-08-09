module EdgeCache
  class BustArticle
    TIMEFRAMES = [
      [-> { 1.week.ago }, "week"],
      [-> { 1.month.ago }, "month"],
      [-> { 1.year.ago }, "year"],
      [-> { 5.years.ago }, "infinity"],
    ].freeze

    def self.call(article)
      return unless article

      EdgeCache::BustUser.call(article.user)
      EdgeCache::BustOrganization.call(article.organization, article.organization.slug) if article.organization

      paths = [
        article.path,
        "/api/articles/#{article.id}",
        "/api/articles/#{article.slug}",
      ]
      paths.concat(home_paths(article))
      paths.concat(tag_paths(article))

      urls = paths.map { |p| URL.url(p) }
      EdgeCache::Purger.purge_urls(urls)
    end

    def self.home_paths(article)
      paths = []
      paths << "/" if article.published_at.to_i > Time.current.to_i
      paths << "/videos" if article.video.present? && article.published_at.to_i > 10.days.ago.to_i
      TIMEFRAMES.each do |timestamp, interval|
        next unless Article.published.where("published_at > ?", timestamp.call)
                                    .order(public_reactions_count: :desc).limit(3).ids.include?(article.id)
        paths << "/top/#{interval}"
      end
      paths << "/latest" if article.published && article.published_at > 1.hour.ago
      paths << "/" if Article.published.order(hotness_score: :desc).limit(4).ids.include?(article.id)
      paths
    end
    private_class_method :home_paths

    def self.tag_paths(article)
      paths = []
      return paths unless article.published

      article.tag_list.each do |tag|
        paths << "/t/#{tag}/latest" if article.published_at.to_i > 2.minutes.ago.to_i
        TIMEFRAMES.each do |timestamp, interval|
          next unless Article.published.where("published_at > ?", timestamp.call).cached_tagged_with_any(tag)
                                      .order(public_reactions_count: :desc).limit(3).ids.include?(article.id)
          paths << "/top/#{interval}"
          12.times do |i|
            paths << "/api/articles?tag=#{tag}&top=#{i}"
          end
        end
        next unless rand(2) == 1 &&
                    Article.published.tagged_with(tag)
                           .order(hotness_score: :desc).limit(2).ids.include?(article.id)
        paths << "/t/#{tag}"
      end
      paths
    end
    private_class_method :tag_paths
  end
end
