require "net/http"
require "uri"
require "json"

module EdgeCache
  class Purger
    MAX_CF_FILES = 30

    def self.purge_urls(urls)
      urls = Array(urls).compact_blank.uniq
      return true if urls.empty?

      if ENV["EDGE_PROVIDER"] == "cloudflare"
        Cloudflare.purge_urls(urls)
      else
        FastlyCompat.purge_urls(urls)
      end
    end

    def self.purge_keys(keys)
      if ENV["EDGE_PROVIDER"] == "cloudflare"
        Cloudflare.purge_keys(keys)
      else
        FastlyCompat.purge_keys(keys)
      end
    end
  end

  class Cloudflare
    ENDPOINT = "https://api.cloudflare.com/client/v4"

    def self.purge_urls(urls)
      zone  = ENV.fetch("CF_ZONE_ID")
      token = ENV.fetch("CF_API_TOKEN")

      urls.each_slice(Purger::MAX_CF_FILES) do |chunk|
        uri = URI("#{ENDPOINT}/zones/#{zone}/purge_cache")
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = "Bearer #{token}"
        req["Content-Type"]  = "application/json"
        req.body = { files: chunk }.to_json

        res = http(uri).request(req)
        unless res.is_a?(Net::HTTPSuccess)
          Rails.logger.warn("Cloudflare purge failed: #{res.code} #{res.body}")
        end
      end
      true
    end

    # No-op unless you wire up Cloudflare Cache Tags.
    def self.purge_keys(_keys)
      true
    end

    def self.http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 10
      http
    end
  end

  class FastlyCompat
    def self.purge_urls(_urls); true; end
    def self.purge_keys(_keys); true; end
  end
end
