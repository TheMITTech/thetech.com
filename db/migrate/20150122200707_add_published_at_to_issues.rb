class AddPublishedAtToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :published_at, :datetime
  end
end
