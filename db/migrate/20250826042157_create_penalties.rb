class CreatePenalties < ActiveRecord::Migration[8.0]
  def change
    create_table :penalties do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :month, null: false
      t.integer :year, null: false
      t.integer :no_show_count, default: 0, null: false
      t.integer :cancel_count, default: 0, null: false
      t.boolean :is_blocked, default: false, null: false

      t.timestamps
    end
    
    add_index :penalties, [:user_id, :month, :year], unique: true
  end
end
