module Listings
  class BustCacheWorker < BustCacheBaseWorker
    def perform(listing_id)
      listing = Listing.find_by(id: listing_id)

      return unless listing

      urls = [
        URL.url(listing.path),
        URL.url("#{listing.path}?i=i"),
      ]
      EdgeCache::Purger.purge_urls(urls)
    end
  end
end
