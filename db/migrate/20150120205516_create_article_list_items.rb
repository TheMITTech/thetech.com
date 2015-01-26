class CreateArticleListItems < ActiveRecord::Migration
  def change
    create_table :article_list_items do |t|
      t.integer :article_list_id
      t.integer :piece_id
      t.text :title

      t.timestamps
    end
  end
end
