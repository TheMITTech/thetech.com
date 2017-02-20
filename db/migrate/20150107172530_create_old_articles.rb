class CreateOldArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :title
      t.text :byline
      t.text :dateline
      t.text :chunks

      t.timestamps
    end
  end
end
