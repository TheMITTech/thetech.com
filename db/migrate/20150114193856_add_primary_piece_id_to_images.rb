class AddPrimaryPieceIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :primary_piece_id, :integer
  end
end
