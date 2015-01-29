class AddDefaultToHomepagesStatus < ActiveRecord::Migration
  def change
    change_column_default :homepages, :status, 0
  end
end
