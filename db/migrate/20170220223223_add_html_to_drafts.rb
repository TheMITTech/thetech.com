class AddHtmlToDrafts < ActiveRecord::Migration
  def change
    add_column :drafts, :html, :text
  end
end
