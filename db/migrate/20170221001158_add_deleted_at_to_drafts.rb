class AddDeletedAtToDrafts < ActiveRecord::Migration
  def change
    add_column :drafts, :deleted_at, :datetime
    add_index :drafts, :deleted_at
  end
end
