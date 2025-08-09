# config/initializers/excon_disable_aws_streaming.rb
require "excon"

# Monkey-patch Excon’s AWS SigV4 middleware so it never signs in streaming mode.
module Excon
  class Middleware::AwsSignerV4
    # Excon uses this to decide if it should do a chunked, streaming signature.
    # Always return false so it falls back to a normal, single-chunk PUT.
    def chunked_upload?
      false
    end
  end
end
