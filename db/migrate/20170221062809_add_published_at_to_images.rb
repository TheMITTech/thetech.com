class AddPublishedAtToImages < ActiveRecord::Migration
  def change
    add_column :images, :published_at, :datetime
  end
end
