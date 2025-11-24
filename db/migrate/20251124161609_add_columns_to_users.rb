class AddColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :status, :string
    add_column :users, :phone, :integer
  end
end
