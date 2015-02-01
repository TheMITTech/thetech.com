module Varnish
  class Purger
    class Purge < Net::HTTPRequest
      METHOD = "PURGE"
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
    end

    def self.purge(url)
      http = Net::HTTP.new("localhost", "80")
      response = http.request(Purge.new(url))
    end
  end
end