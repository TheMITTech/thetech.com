class AddSlugToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :slug, :string
    add_index :authors, :slug, unique: true
  end
end
