class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.integer :article_id
      t.text :headline
      t.text :subhead
      t.text :bytitle
      t.text :lede
      t.text :attribution
      t.string :redirect_url
      t.text :chunks
      t.text :web_template
      t.integer :user_id
      t.integer :web_status,      default: 0
      t.integer :print_status,    default: 0
      t.datetime :published_at

      t.timestamps
    end
  end
end
