class ChangeIssuesPublishedAtToDate < ActiveRecord::Migration
  def change
    change_column :issues, :published_at, :date
  end
end
