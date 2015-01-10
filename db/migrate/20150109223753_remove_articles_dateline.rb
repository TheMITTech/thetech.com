class RemoveArticlesDateline < ActiveRecord::Migration
  def change
    remove_column :articles, :dateline
  end
end
