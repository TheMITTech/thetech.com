class AddIndexToArticleVersions < ActiveRecord::Migration
  def change
  	add_index :article_versions, :web_status
  	add_index :article_versions, :print_status
  end
end
