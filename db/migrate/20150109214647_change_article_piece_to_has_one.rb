class ChangeArticlePieceToHasOne < ActiveRecord::Migration
  def change
    drop_table :articles_pieces

    add_column :articles, :piece_id, :integer
  end
end
