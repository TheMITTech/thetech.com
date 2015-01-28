class CreateArticleLists < ActiveRecord::Migration
  def change
    create_table :article_lists do |t|
      t.text :name
      t.integer :piece_id

      t.timestamps
    end
  end
end
