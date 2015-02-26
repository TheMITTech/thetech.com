class RenameAdsTypeToPosition < ActiveRecord::Migration
  def change
    rename_column :ads, :type, :position
  end
end
