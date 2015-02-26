class AddDimensionsToAds < ActiveRecord::Migration
  def change
    add_column :ads, :dimensions, :text
  end
end
