class CreateImagesUsers < ActiveRecord::Migration
  def change
    create_table :images_users, :id => false do |t|
      t.references :image, :user
    end

    add_index :images_users, [:image_id, :user_id],
      name: "images_users_index",
      unique: true
  end
end
