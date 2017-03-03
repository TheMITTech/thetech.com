class AddDeletedToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :deleted, :boolean, :default => false
  end
end
