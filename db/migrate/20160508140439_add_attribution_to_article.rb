class AddAttributionToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :attribution, :string
  end
end
