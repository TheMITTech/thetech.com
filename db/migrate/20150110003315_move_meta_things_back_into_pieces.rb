class MoveMetaThingsBackIntoPieces < ActiveRecord::Migration
  def change
    remove_column :articles, :section_id
    remove_column :images, :section_id

    add_column :pieces, :section_id, :integer
  end
end
