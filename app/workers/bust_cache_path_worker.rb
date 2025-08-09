class BustCachePathWorker < BustCacheBaseWorker
  def perform(path)
    EdgeCache::Purger.purge_urls([URL.url(path)])
  end
end
