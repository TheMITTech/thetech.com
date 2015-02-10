class AddTwitterToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :twitter, :string
  end
end
