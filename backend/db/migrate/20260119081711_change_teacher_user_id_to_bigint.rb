class ChangeTeacherUserIdToBigint < ActiveRecord::Migration[7.0]
  def up
    # Step 1: Drop foreign keys that reference teachers.user_id
    remove_foreign_key :ai_conversations, :teachers if foreign_key_exists?(:ai_conversations, :teachers)
    remove_foreign_key :teachers, :users if foreign_key_exists?(:teachers, :users)
    
    # Step 2: Drop indexes
    remove_index :teachers, :user_id if index_exists?(:teachers, :user_id)
    remove_index :ai_conversations, :teacher_id if index_exists?(:ai_conversations, :teacher_id)
    
    # Step 3: Change ai_conversations.teacher_id from string to bigint
    # First, we need to convert the string user_id values to integer user.id values
    execute <<-SQL
      UPDATE ai_conversations ac
      INNER JOIN teachers t ON ac.teacher_id = t.user_id
      INNER JOIN users u ON t.user_id = u.user_id
      SET ac.teacher_id = u.id
    SQL
    
    change_column :ai_conversations, :teacher_id, :bigint, null: false
    
    # Step 4: Change teachers.user_id from string to bigint
    # First, we need to convert the string user_id values to integer user.id values
    # Create a temporary column to store the new bigint values
    add_column :teachers, :user_id_new, :bigint
    
    # Update the new column with user.id values
    execute <<-SQL
      UPDATE teachers t
      INNER JOIN users u ON t.user_id = u.user_id
      SET t.user_id_new = u.id
    SQL
    
    # Remove old primary key constraint
    execute "ALTER TABLE teachers DROP PRIMARY KEY"
    
    # Remove old column and rename new column
    remove_column :teachers, :user_id
    rename_column :teachers, :user_id_new, :user_id
    
    # Add new primary key
    execute "ALTER TABLE teachers ADD PRIMARY KEY (user_id)"
    
    # Step 5: Re-add indexes
    add_index :teachers, :user_id
    add_index :ai_conversations, :teacher_id
    
    # Step 6: Re-add foreign keys with correct references
    add_foreign_key :teachers, :users, column: :user_id, primary_key: :id
    add_foreign_key :ai_conversations, :teachers, column: :teacher_id, primary_key: :user_id
  end

  def down
    # Reverse the migration
    remove_foreign_key :ai_conversations, :teachers if foreign_key_exists?(:ai_conversations, :teachers)
    remove_foreign_key :teachers, :users if foreign_key_exists?(:teachers, :users)
    
    remove_index :teachers, :user_id if index_exists?(:teachers, :user_id)
    remove_index :ai_conversations, :teacher_id if index_exists?(:ai_conversations, :teacher_id)
    
    # Change back to string
    add_column :teachers, :user_id_string, :string
    
    # Update with user.user_id values
    execute <<-SQL
      UPDATE teachers t
      INNER JOIN users u ON t.user_id = u.id
      SET t.user_id_string = u.user_id
    SQL
    
    execute "ALTER TABLE teachers DROP PRIMARY KEY"
    remove_column :teachers, :user_id
    rename_column :teachers, :user_id_string, :user_id
    execute "ALTER TABLE teachers ADD PRIMARY KEY (user_id)"
    
    # Change ai_conversations back
    add_column :ai_conversations, :teacher_id_string, :string
    
    execute <<-SQL
      UPDATE ai_conversations ac
      INNER JOIN teachers t ON ac.teacher_id = t.user_id
      SET ac.teacher_id_string = t.user_id
    SQL
    
    remove_column :ai_conversations, :teacher_id
    rename_column :ai_conversations, :teacher_id_string, :teacher_id
    change_column :ai_conversations, :teacher_id, :string, null: false
    
    add_index :teachers, :user_id
    add_index :ai_conversations, :teacher_id
    
    add_foreign_key :teachers, :users, column: :user_id, primary_key: :user_id
    add_foreign_key :ai_conversations, :teachers, column: :teacher_id, primary_key: :user_id
  end
end
