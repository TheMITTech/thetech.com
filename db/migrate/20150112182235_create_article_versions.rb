class CreateArticleVersions < ActiveRecord::Migration
  def change
    create_table :article_versions do |t|
      t.integer :article_id
      t.text :contents

      t.timestamps
    end
  end
end
