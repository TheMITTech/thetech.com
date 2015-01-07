class CreateArticlesPieces < ActiveRecord::Migration
  def change
    create_table :articles_pieces, :id => false do |t|
      t.references :article, :piece
    end

    add_index :articles_pieces, [:article_id, :piece_id],
      name: "articles_pieces_index",
      unique: true
  end
end
