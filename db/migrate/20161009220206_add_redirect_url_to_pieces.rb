class AddRedirectUrlToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :redirect_url, :string
  end
end
