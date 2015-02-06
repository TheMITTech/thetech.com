class AddCachingFieldsToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :published_author_ids, :string
    add_column :pieces, :published_tag_ids, :string
    add_column :pieces, :published_headline, :string
    add_column :pieces, :published_subhead, :string
    add_column :pieces, :published_content, :text
    add_column :pieces, :published_section_id, :integer
  end
end
