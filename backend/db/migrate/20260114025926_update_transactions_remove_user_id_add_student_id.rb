class UpdateTransactionsRemoveUserIdAddStudentId < ActiveRecord::Migration[7.0]
  def change
    # Remove user_id if exists
    if column_exists?(:transactions, :user_id)
      remove_foreign_key :transactions, :users, if_exists: true
      remove_column :transactions, :user_id
    end

    # Add student_id if not exists
    unless column_exists?(:transactions, :student_id)
      add_reference :transactions, :student, foreign_key: true, null: false
    end

    # Add index on student_id and status
    add_index :transactions, [:student_id, :status], unique: false, if_not_exists: true
  end
end
