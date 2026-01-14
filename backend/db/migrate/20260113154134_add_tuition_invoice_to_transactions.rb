# frozen_string_literal: true

class AddTuitionInvoiceToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :tuition_invoice, null: true, foreign_key: true
    add_index :transactions, [:tuition_invoice_id, :status]
  end
end
