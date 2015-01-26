class AddRankToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :rank, :integer, default: 99
  end
end
