module Users
  module AnonymousAuthor
    def self.id = nil
    def self.name = "Anonymous"
    def self.username = "anonymous"
    def self.slug = "anonymous"
    def self.path = nil
    def self.profile_image_url = nil
    def self.profile_image_90 = Images::Profile.call(profile_image_url, length: 90)
    def self.profile_image_url_for(length:)
      Images::Profile.call(profile_image_url, length: length)
    end
    def self.cached_base_subscriber? = false
    def self.processed_website_url = nil
    def self.twitter_username = nil
    def self.github_username = nil
    def self.spam? = false
    def self.decorate = self
    def self.class_name = User.name
  end
end
