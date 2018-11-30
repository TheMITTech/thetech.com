class UseHmTForAuthorships < ActiveRecord::Migration
  def up
    create_table :authorships do |t|
      t.belongs_to :draft
      t.belongs_to :author
      t.integer :byline_order, default: 0
      t.timestamps
    end

    execute "insert into authorships(draft_id, author_id) select draft_id, author_id from authors_drafts"

    drop_table :authors_drafts
  end

  def down
    rename_table :authorships, :authors_drafts
  end
end
