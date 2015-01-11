class AddSlugToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :slug, :string

    add_index :pieces, :slug, unique: true
  end
end
