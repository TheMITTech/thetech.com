class AddPublishedAtToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :published_at, :datetime
  end
end
