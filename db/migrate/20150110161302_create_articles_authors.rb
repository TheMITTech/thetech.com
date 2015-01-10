class CreateArticlesAuthors < ActiveRecord::Migration
  def change
    create_table :articles_authors, :id => false do |t|
      t.references :article, :author
    end

    add_index :articles_authors, [:article_id, :author_id],
      name: "articles_authors_index",
      unique: true
  end
end
