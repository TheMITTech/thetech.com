class AddAuthorIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :author_id, :integer
  end
end
