class MakeEmailOptionalForUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :email, true
    remove_index :users, :email if index_exists?(:users, :email)
  end
end