module Varnish
  class Purger
    require 'open-uri'

    URL_REGEX = /http:\/\/[^\/]*(.*)/

    class Purge < Net::HTTPRequest
      METHOD = "PURGE"
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
    end

    def self.purge(url, touch = false)
      return unless ENV["VARNISH_USED"]

      match = URL_REGEX.match(url)
      url = match[1] if match

      Rails.logger.info "Purging cached pages matching #{url}, touch = #{touch.to_s}"

      purge_list.each do |host|
        url_with_host = "http://#{host}#{url}"

        Rails.logger.info "  Purging #{url_with_host}. " if ENV["DEBUG"] == 'true'

        http = Net::HTTP.new(host, "80")
        response = http.request(Purge.new(url_with_host))

        Thread.new do
          open(url_with_host).read if touch
        end
      end
    end

    private
      def self.purge_list
        @@purge_list ||= [
          ENV["VARNISH_HOST_NAME"]
        ].compact
      end
  end
end