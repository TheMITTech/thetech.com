class CreatePiecesSeries < ActiveRecord::Migration
  def change
    create_table :pieces_series, :id => false do |t|
      t.references :piece, :series
    end

    add_index :pieces_series, [:piece_id, :series_id],
      name: "pieces_series_index",
      unique: true
  end
end
