class AddSectionIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :section_id, :integer
  end
end
