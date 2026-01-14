class RemoveStudentIdFromTransactions < ActiveRecord::Migration[7.0]
  def change
    # Remove foreign key constraint first
    remove_foreign_key :transactions, :students, if_exists: true
    
    # Remove indexes
    remove_index :transactions, [:student_id, :status], if_exists: true
    remove_index :transactions, :student_id, if_exists: true
    
    # Remove column
    remove_column :transactions, :student_id, :bigint
  end
end
