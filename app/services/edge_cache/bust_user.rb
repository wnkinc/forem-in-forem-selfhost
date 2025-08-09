module EdgeCache
  class BustUser
    def self.call(user)
      return unless user

      user_id = user.id
      urls = [
        URL.user(user),
        URL.url("/api/users/#{user_id}"),
      ].compact

      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
