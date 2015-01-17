class AddAttachmentPdfToIssues < ActiveRecord::Migration
  def self.up
    change_table :issues do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :issues, :pdf
  end
end
