class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.belongs_to :user, index: true
      t.integer :value
      t.datetime :created_at
    end
  end
end
