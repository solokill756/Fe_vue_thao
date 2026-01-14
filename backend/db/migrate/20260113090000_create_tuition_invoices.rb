# frozen_string_literal: true

class CreateTuitionInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :tuition_invoices do |t|
      t.references :student, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :status, default: 'pending' # pending, paid, overdue
      t.date :due_date, null: false
      t.datetime :paid_date
      t.string :invoice_code, null: false

      t.timestamps
    end

    add_index :tuition_invoices, [:student_id, :status]
    add_index :tuition_invoices, :due_date
    add_index :tuition_invoices, :invoice_code, unique: true
  end
end
