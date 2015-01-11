class AddAuthorsLineToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :authors_line, :text
  end
end
