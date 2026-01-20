# frozen_string_literal: true

class TuitionInvoiceService
  def create(params, student, class_id)
    invoice = student.tuition_invoices.build(params)
    invoice.class_id = class_id
    if invoice.save
      Result.success(invoice)
    else
      Result.failure(invoice.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def update(id, params, student)
    invoice = student.tuition_invoices.find_by(id: id)
    return Result.failure({ error: 'Invoice not found' }) unless invoice

    if invoice.update(params)
      Result.success(invoice)
    else
      Result.failure(invoice.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def destroy(id, student)
    invoice = student.tuition_invoices.find_by(id: id)
    return Result.failure({ error: 'Invoice not found' }) unless invoice

    if invoice.destroy
      Result.success({ message: 'Invoice deleted successfully' })
    else
      Result.failure(invoice.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def find(id, student)
    invoice = student.tuition_invoices.includes(school_class: :teacher).find_by(id: id)
    if invoice
      Result.success(invoice)
    else
      Result.failure({ error: 'Invoice not found' })
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  def list_by_student(student)
    invoices = student.tuition_invoices.includes(school_class: :teacher).not_paid
    Result.success(invoices)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end
end
