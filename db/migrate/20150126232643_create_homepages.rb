class CreateHomepages < ActiveRecord::Migration
  def change
    create_table :homepages do |t|
      t.text :layout

      t.timestamps
    end
  end
end
