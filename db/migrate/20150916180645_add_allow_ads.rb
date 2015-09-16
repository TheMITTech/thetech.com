class AddAllowAds < ActiveRecord::Migration
  def change
    add_column :pieces, :published_allow_ads, :boolean, default: true
    add_column :pieces, :allow_ads, :boolean, default: true
  end
end
