class RenameImagesToPreRebirthImages < ActiveRecord::Migration
  def change
    rename_table :images, :pre_rebirth_images
    rename_table :images_pieces, :pieces_pre_rebirth_images
  end
end
