class AddSocialMediaBlurbToPieces < ActiveRecord::Migration
  def change
   add_column :pieces, :social_media_blurb, :string
  end
end
