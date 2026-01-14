class UpdateTuitionInvoicesAndTransactionsAssociations < ActiveRecord::Migration[7.0]
  def change
    # Add class_id to tuition_invoices
    add_reference :tuition_invoices, :class, foreign_key: { to_table: :classes }, null: true
    
    # Remove class_id from transactions
    remove_foreign_key :transactions, :classes
    remove_column :transactions, :class_id
  end
end
