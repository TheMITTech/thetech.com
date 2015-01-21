class AddPrintedStateToArticleVersions < ActiveRecord::Migration
  def change
      rename_column :article_versions, :status, :web_status
      add_column :article_versions, :print_status, :integer, default: 0
  end
end
