class AddNotesToDrafts < ActiveRecord::Migration
  def change
    add_column :drafts, :notes, :text, default: ""
  end
end
