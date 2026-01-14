# frozen_string_literal: true

class TransactionSerializer
  def initialize(transaction)
    @transaction = transaction
  end

  def serialize
    {
      id: @transaction.id,
      tuition_invoice_id: @transaction.tuition_invoice_id,
      amount: @transaction.amount,
      payment_date: @transaction.payment_date,
      method: @transaction.method,
      status: @transaction.status,
      description: @transaction.description,
      created_at: @transaction.created_at,
      updated_at: @transaction.updated_at
    }
  end

  def self.serialize(transaction)
    new(transaction).serialize
  end

  def self.serialize_collection(transactions)
    return [] if transactions.nil? || transactions.empty?
    transaction_array = transactions.is_a?(Array) ? transactions : transactions.to_a
    return [] if transaction_array.empty?
    transaction_array.map { |transaction| new(transaction).serialize }
  end
end
