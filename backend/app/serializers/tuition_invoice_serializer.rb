# frozen_string_literal: true

class TuitionInvoiceSerializer
  def initialize(tuition_invoice)
    @invoice = tuition_invoice
  end

  def serialize
    # Use attributes_before_type_cast or direct attribute access to avoid callbacks
    attrs = @invoice.attributes
    {
      id: attrs['id'],
      title: attrs['title'],
      description: attrs['description'],
      amount: attrs['amount'],
      status: attrs['status'],
      due_date: attrs['due_date'],
      paid_date: attrs['paid_date'],
      invoice_code: attrs['invoice_code'],
      created_at: attrs['created_at'],
      updated_at: attrs['updated_at'],
      teacher_qr_code: @invoice.school_class&.teacher&.qr_code
    }
  end

  def self.serialize(tuition_invoice)
    new(tuition_invoice).serialize
  end

  def self.serialize_collection(invoices)
    return [] if invoices.nil? || invoices.empty?
    
    # Ensure we have an array, not ActiveRecord::Relation
    invoice_array = invoices.is_a?(Array) ? invoices : invoices.to_a
    return [] if invoice_array.empty?
    
    # Serialize each invoice
    invoice_array.map { |invoice| new(invoice).serialize }
  end
end
