class AddStatusToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :status, :integer, default: 0
  end
end
