class AddAttachmentContentToAds < ActiveRecord::Migration
  def self.up
    change_table :ads do |t|
      t.attachment :content
    end
  end

  def self.down
    remove_attachment :ads, :content
  end
end
