class AddForeignKeyToTuitionInvoicesClass < ActiveRecord::Migration[7.0]
  def change
    # Add foreign key constraint for class_id in tuition_invoices
    add_foreign_key :tuition_invoices, :classes, column: :class_id, if_not_exists: true
  end
end
