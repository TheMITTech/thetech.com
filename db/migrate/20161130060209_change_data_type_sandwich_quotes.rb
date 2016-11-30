class ChangeDataTypeSandwichQuotes < ActiveRecord::Migration
  def change
    change_column :articles, :sandwich_quotes, :textgit
  end
end
