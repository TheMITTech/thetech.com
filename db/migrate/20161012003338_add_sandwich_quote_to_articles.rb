class AddSandwichQuoteToArticles < ActiveRecord::Migration
  def change
   add_column :articles, :sandwich_quotes, :string
  end
end
