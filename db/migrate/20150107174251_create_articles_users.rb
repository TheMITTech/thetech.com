class CreateArticlesUsers < ActiveRecord::Migration
  def change
    create_table :articles_users, :id => false do |t|
      t.references :article, :user
    end

    add_index :articles_users, [:article_id, :user_id],
      name: "articles_users_index",
      unique: true
  end
end
