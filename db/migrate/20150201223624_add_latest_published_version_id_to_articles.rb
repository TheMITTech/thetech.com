class AddLatestPublishedVersionIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :latest_published_version_id, :integer
  end
end
