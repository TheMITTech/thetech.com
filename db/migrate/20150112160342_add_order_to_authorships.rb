class AddOrderToAuthorships < ActiveRecord::Migration
  def change
    add_column :authorships, :order, :integer
  end
end
