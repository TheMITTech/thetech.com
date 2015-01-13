class CreateLegacyPages < ActiveRecord::Migration
  def change
    create_table :legacy_pages do |t|
      t.text :html
      t.integer :issue_id
      t.string :archivetag
      t.text :headline

      t.timestamps
    end
  end
end
