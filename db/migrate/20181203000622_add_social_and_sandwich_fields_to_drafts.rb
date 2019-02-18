class AddSocialAndSandwichFieldsToDrafts < ActiveRecord::Migration
  def change
    add_column :drafts, :social_media_blurb, :text, default: ""
    add_column :drafts, :sandwich_quotes, :text, default: ""
  end
end
