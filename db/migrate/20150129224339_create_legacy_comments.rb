class CreateLegacyComments < ActiveRecord::Migration
  def change
    create_table :legacy_comments do |t|
      t.integer :piece_id
      t.text :author_email
      t.text :author_name
      t.datetime :published_at
      t.string :ip_address
      t.text :content

      t.timestamps
    end
  end
end
