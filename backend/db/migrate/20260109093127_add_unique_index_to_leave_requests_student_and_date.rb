class AddUniqueIndexToLeaveRequestsStudentAndDate < ActiveRecord::Migration[7.0]
  def change
    # Xóa duplicate records - giữ lại record mới nhất cho mỗi (student_id, date)
    execute <<-SQL
      DELETE FROM leave_requests
      WHERE id NOT IN (
        SELECT * FROM (
          SELECT MAX(id)
          FROM leave_requests
          GROUP BY student_id, date
        ) AS keep_ids
      );
    SQL

    add_index :leave_requests, [:student_id, :date], unique: true, name: 'index_leave_requests_on_student_and_date_unique'
  end
end
