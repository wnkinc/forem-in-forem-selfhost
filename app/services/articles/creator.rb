module Articles
  class Creator
    def self.call(...)
      new(...).call
    end

    # @param user [User]
    # @param article_params [Hash]
    # @option article_params [NilClass, String] :title
    # @option article_params [NilClass, String] :body_markdown
    # @option article_params [NilClass, String] :main_image
    # @option article_params [Boolean]     :published
    # @option article_params [NilClass, String] :description
    # @option article_params [NilClass, String] :video_thumbnail_url
    # @option article_params [NilClass, String] :canonical_url
    # @option article_params [NilClass, String] :series        series slug
    # @option article_params [Integer, NilClass] :collection_id
    # @option article_params [Boolean]     :archived
    # @option article_params [String<Array>] :tags
    # @option article_params [NilClass, String, ActiveSupport::TimeWithZone] :published_at
    def initialize(user, article_params)
      @user           = user
      @article_params = normalize_params(article_params)
    end

    def call
      rate_limit!

      create_article.tap do
        subscribe_author                 if article.persisted?
        refresh_auto_audience_segments   if article.published?
      end
    end

    private

    attr_reader :article, :user, :article_params

    # Strip out :tags array (handled via tag_list), leave everything else in place
    def normalize_params(original_params)
      original_params.except(:tags).tap do |params|
        if (tags = original_params[:tags]).present?
          params[:tag_list] = tags.join(", ")
        end
      end
    end

    def rate_limit!
      limiter = user.decorate.considered_new? ? :published_article_antispam_creation : :published_article_creation
      user.rate_limiter.check_limit!(limiter)
    end

    def refresh_auto_audience_segments
      user.refresh_auto_audience_segments
    end

    def create_article
      @article = Article.create(article_params) do |article|
        if article_params[:published] && anonymous_tag?
          # Anonymous post: swap in the anonymous account as the public author,
          # and record the real user as a co_author.
          article.user_id       = User.anonymous_account.id
          article.co_author_ids = ([user.id] + Array(article.co_author_ids)).uniq
        else
          article.user_id = user.id
        end

        article.show_comments = true
        article.collection    = series if series.present?
      end
    end

    def series
      @series ||= if article_params[:series].blank?
                    []
                  else
                    Collection.find_series(article_params[:series], user)
                  end
    end

    def subscribe_author
      NotificationSubscription.create(
        user:       user,
        notifiable: article,
        config:     "all_comments"
      )
    end

    # True if the submitted tag_list includes exactly "anonymous"
    def anonymous_tag?
      (article_params[:tag_list] || "")
        .split(",")
        .map(&:strip)
        .include?("anonymous")
    end
  end
end
