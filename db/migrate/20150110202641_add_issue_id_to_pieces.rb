class AddIssueIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :issue_id, :integer
  end
end
