module Varnish
  class Purger
    require 'open-uri'

    class Purge < Net::HTTPRequest
      METHOD = "PURGE"
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
    end

    def self.purge(url, touch = false)
      return unless ENV["VARNISH_USED"]

      Rails.logger.info "Purging cached pages matching #{url}, touch = #{touch.to_s}"

      purge_list.each do |host|
        url = "http://#{host}#{url}"

        http = Net::HTTP.new(host, "80")
        response = http.request(Purge.new(url))

        Thread.new do
          open(url).read if touch
        end
      end
    end

    private
      def self.purge_list
        @@purge_list ||= [
          "127.0.0.1",
          ENV["TECH_APP_FRONTEND_HOSTNAME"]
        ].compact
      end
  end
end