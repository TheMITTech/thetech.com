class AddStatusToHomepages < ActiveRecord::Migration
  def change
    add_column :homepages, :status, :integer
  end
end
