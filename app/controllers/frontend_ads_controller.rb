class FrontendAdsController < FrontendController
  def ads_manifest
    json = Hash[Ad.positions.map do |k, v|
      [
        k,
        Ad.active.where(position: v).map do |a|
          {
            image: ads_relay_path(a),
            link: a.link
          }
        end
      ]
    end]

    render json: json
  end

  def relay
    require 'open-uri'

    ad = Ad.find(params[:id].to_i)

    data = Paperclip.io_adapters.for(ad.content).read
    send_data data
  end
end