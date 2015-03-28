class AddSearchContentToImages < ActiveRecord::Migration
  def change
    add_column :images, :search_content, :text
  end
end
