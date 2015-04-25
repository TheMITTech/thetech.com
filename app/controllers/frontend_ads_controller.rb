class FrontendAdsController < FrontendController
  def ads_manifest
    json = Hash[Ad.positions.map do |k, v|
      [
        k,
        Ad.active.where(position: v).map do |a|
          {
            image: a.content.url,
            link: a.link
          }
        end
      ]
    end]

    render json: json
  end
end