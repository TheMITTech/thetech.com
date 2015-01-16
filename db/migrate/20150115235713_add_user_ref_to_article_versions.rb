class AddUserRefToArticleVersions < ActiveRecord::Migration
  def change
    add_reference :article_versions, :user, index: true
  end
end
