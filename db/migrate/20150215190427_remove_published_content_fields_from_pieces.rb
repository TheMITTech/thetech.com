class RemovePublishedContentFieldsFromPieces < ActiveRecord::Migration
  def change
    remove_column :pieces, :published_headline
    remove_column :pieces, :published_subhead
    remove_column :pieces, :published_content
  end
end
