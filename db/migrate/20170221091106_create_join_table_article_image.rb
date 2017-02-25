class CreateJoinTableArticleImage < ActiveRecord::Migration
  def change
    create_join_table :articles, :images do |t|
      t.index [:article_id, :image_id]
      t.index [:image_id, :article_id]
    end
  end
end
