class CreateAuthorsDrafts < ActiveRecord::Migration
  def change
    create_table :authors_drafts do |t|
      t.integer :author_id
      t.integer :draft_id
    end
  end
end
