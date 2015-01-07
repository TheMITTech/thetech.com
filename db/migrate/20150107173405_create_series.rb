class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.text :name

      t.timestamps
    end
  end
end
