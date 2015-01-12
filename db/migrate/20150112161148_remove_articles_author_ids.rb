class RemoveArticlesAuthorIds < ActiveRecord::Migration
  def change
    remove_column :articles, :author_ids
  end
end
