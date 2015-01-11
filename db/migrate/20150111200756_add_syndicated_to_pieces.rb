class AddSyndicatedToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :syndicated, :boolean
  end
end
