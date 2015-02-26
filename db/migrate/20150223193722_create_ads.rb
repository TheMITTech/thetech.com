class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.text :name
      t.date :start_date
      t.date :end_date
      t.integer :type

      t.timestamps
    end
  end
end
