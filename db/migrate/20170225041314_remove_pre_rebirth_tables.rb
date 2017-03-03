class RemovePreRebirthTables < ActiveRecord::Migration
  def change
    drop_table :article_list_items
    drop_table :article_lists
    drop_table :article_versions
    drop_table :authorships
    drop_table :images_users
    drop_table :pictures
    drop_table :pieces
    drop_table :pieces_pre_rebirth_images
    drop_table :pieces_series
    drop_table :pre_rebirth_articles
    drop_table :pre_rebirth_articles_users
    drop_table :pre_rebirth_images
    drop_table :pre_rebirth_legacy_comments
    drop_table :series
  end
end
