# frozen_string_literal: true

class TransactionService
  def record(tuition_invoice_id, params)
    transaction = Transaction.new(tuition_invoice_id:,
                                  **params)

    if transaction.save
      Result.success(transaction)
    else
      Result.failure(transaction.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Transaction creation error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    Result.failure({ error: e.message })
  end

  def update(transaction, params)
    if transaction.update(params)
      Result.success(transaction)
    else
      Result.failure(transaction.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def delete(transaction)
    if transaction.destroy
      Result.success({ message: 'Transaction deleted successfully' })
    else
      Result.failure(transaction.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def get_student_transactions(user_id)
    transactions = Transaction.joins(:tuition_invoice).where(tuition_invoices: { student_id: user_id }).order(created_at: :desc)
    Result.success(transactions)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
end
