# frozen_string_literal: true

class TuitionInvoiceSerializer
  include FastJsonapi::Serializer
  attributes :id, :title, :description, :amount, :status, :due_date, :paid_date, :invoice_code
  belongs_to :student
end
