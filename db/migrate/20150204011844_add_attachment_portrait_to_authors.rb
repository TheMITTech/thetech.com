class AddAttachmentPortraitToAuthors < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.attachment :portrait
    end
  end

  def self.down
    remove_attachment :authors, :portrait
  end
end
