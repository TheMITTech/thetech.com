class AddSearchContentToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :search_content, :text
  end
end
