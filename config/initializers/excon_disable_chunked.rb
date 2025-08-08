# config/initializers/excon_disable_chunked.rb
require "excon"

# (Optionally) strip out any chunked middleware just in case
Excon.defaults[:middlewares].reject! do |middleware|
  middleware.name =~ /Chunked|Streaming/
end
