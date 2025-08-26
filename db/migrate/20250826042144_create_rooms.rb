class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.integer :number, null: false
      t.boolean :has_outlet, default: false, null: false

      t.timestamps
    end
  end
end
