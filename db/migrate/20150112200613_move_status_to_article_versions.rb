class MoveStatusToArticleVersions < ActiveRecord::Migration
  def change
    remove_column :articles, :status

    add_column :article_versions, :status, :integer, default: 0
  end
end
