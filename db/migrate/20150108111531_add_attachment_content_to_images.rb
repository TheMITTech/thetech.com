class AddAttachmentContentToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :content
    end
  end

  def self.down
    remove_attachment :images, :content
  end
end
