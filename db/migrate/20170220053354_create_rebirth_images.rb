class CreateRebirthImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :caption
      t.text :attribution
      t.integer :issue_id
      t.integer :author_id
      t.integer :web_status,      default: 0
      t.integer :print_status,    default: 0

      t.timestamps
    end

    add_attachment :images, :web_photo
  end
end
