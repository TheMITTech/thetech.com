class AddAttachmentContentToPictures < ActiveRecord::Migration
  def self.up
    change_table :pictures do |t|
      t.attachment :content
    end
  end

  def self.down
    remove_attachment :pictures, :content
  end
end
