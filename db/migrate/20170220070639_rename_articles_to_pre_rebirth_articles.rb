class RenameArticlesToPreRebirthArticles < ActiveRecord::Migration
  def change
    rename_table :articles, :pre_rebirth_articles
    rename_table :articles_users, :pre_rebirth_articles_users
  end
end
