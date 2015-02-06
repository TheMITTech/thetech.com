module Varnish
  class Purger
    class Purge < Net::HTTPRequest
      METHOD = "PURGE"
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
    end

    def self.purge(url, host)
      return unless ENV["VARNISH_USED"]

      Rails.logger.info "Purging cached pages matching #{url}"

      purge_list.each do |host|
        http = Net::HTTP.new(host, "80")
        response = http.request(Purge.new("http://#{host}#{url}"))
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