class CreateImagesPieces < ActiveRecord::Migration
  def change
    create_table :images_pieces, :id => false do |t|
      t.references :image, :piece
    end

    add_index :images_pieces, [:image_id, :piece_id],
      name: "images_pieces_index",
      unique: true
  end
end
