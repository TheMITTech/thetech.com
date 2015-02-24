class FrontendAdsController < FrontendController
  def ads_manifest
    json = Hash[Ad.positions.map do |k, v|
      [
        k,
        Ad.active.where(position: v).map(&:content).map(&:url)
      ]
    end]

    render json: json
  end
end