class CreateLegacyComments < ActiveRecord::Migration
  def change
    create_table :legacy_comments do |t|
      t.integer :legacy_commentable_id
      t.string :legacy_commentable_type
      t.string :author_email
      t.string :author_name
      t.datetime :published_at
      t.string :ip_address
      t.text :content

      t.timestamps
    end
  end
end
