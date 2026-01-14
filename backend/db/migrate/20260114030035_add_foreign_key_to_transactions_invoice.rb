class AddForeignKeyToTransactionsInvoice < ActiveRecord::Migration[7.0]
  def change
    # Add foreign key constraint for tuition_invoice_id in transactions
    add_foreign_key :transactions, :tuition_invoices, if_not_exists: true
  end
end
