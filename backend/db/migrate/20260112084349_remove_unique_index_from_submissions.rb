class RemoveUniqueIndexFromSubmissions < ActiveRecord::Migration[7.0]
  def change
    # Remove the unique index to allow multiple submissions per student per assignment
    remove_index :submissions, [:assignment_id, :student_id], unique: true
    
    # Add a non-unique index instead for query performance
    add_index :submissions, [:assignment_id, :student_id]
  end
end
