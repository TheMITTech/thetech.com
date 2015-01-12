class RenameAuthorshipsOrderToRank < ActiveRecord::Migration
  def change
    rename_column :authorships, :order, :rank
  end
end
