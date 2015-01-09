class MoveSectionId < ActiveRecord::Migration
  def change
    remove_column :pieces, :section_id

    add_column :articles, :section_id, :integer
    add_column :images, :section_id, :integer
  end
end
