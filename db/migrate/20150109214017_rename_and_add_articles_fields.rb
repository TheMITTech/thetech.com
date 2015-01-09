class RenameAndAddArticlesFields < ActiveRecord::Migration
  def change
    rename_column :articles, :title, :headline
    rename_column :articles, :byline, :bytitle

    add_column :articles, :subhead, :text
    add_column :articles, :author_ids, :text
    add_column :articles, :lede, :text
  end
end
