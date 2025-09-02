class ChangeApprovedToStatusInUsers < ActiveRecord::Migration[8.0]
  def up
    # Add status column first
    add_column :users, :status, :string, default: 'pending', null: false
    
    # Migrate existing data
    execute <<-SQL
      UPDATE users SET status = CASE 
        WHEN approved = true THEN 'approved'
        ELSE 'pending'
      END
    SQL
    
    # Remove old column
    remove_column :users, :approved
  end
  
  def down
    # Add approved column back
    add_column :users, :approved, :boolean, default: false, null: false
    
    # Migrate data back
    execute <<-SQL
      UPDATE users SET approved = CASE 
        WHEN status = 'approved' THEN true
        ELSE false
      END
    SQL
    
    # Remove status column
    remove_column :users, :status
  end
end
