class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
      t.text :web_template

      t.timestamps
    end
  end
end
