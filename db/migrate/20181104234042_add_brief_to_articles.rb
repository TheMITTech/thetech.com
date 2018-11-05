class AddBriefToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :brief, :boolean, default: false
  end
end
