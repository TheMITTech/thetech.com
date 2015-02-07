require 'spec_helper'
require 'digest'

module ApiHelper
  def expect_checksum_to_be_correct(response)
    response = JSON.parse(response.body)
    real_checksum = Digest::SHA256.hexdigest response['data']
    expect(real_checksum).to eq(response['checksum'])
  end

  def get_response_data(response)
    JSON.parse(response.body)['data']
  end
end
