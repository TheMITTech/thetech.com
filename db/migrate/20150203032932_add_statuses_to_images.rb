class AddStatusesToImages < ActiveRecord::Migration
  def change
    add_column :images, :web_status, :integer, default: 0
    add_column :images, :print_status, :integer, default: 0
  end
end
