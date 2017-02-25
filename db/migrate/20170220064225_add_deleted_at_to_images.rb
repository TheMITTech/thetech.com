class AddDeletedAtToImages < ActiveRecord::Migration
  def change
    add_column :images, :deleted_at, :datetime
    add_index :images, :deleted_at
  end
end
