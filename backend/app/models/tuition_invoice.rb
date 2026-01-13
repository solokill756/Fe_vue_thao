# frozen_string_literal: true

class TuitionInvoice < ApplicationRecord
  # Associations
  belongs_to :student
  has_many :transactions, dependent: :nullify

  # Validations
  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :status, inclusion: { in: %w[pending paid overdue] }
  validates :invoice_code, presence: true, uniqueness: true
  validates :student_id, presence: true

  # Enums
  enum status: { pending: 'pending', paid: 'paid', overdue: 'overdue' }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :by_student, ->(student_id) { where(student_id:) }
  scope :due_before, ->(date) { where('due_date < ?', date) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_create :generate_invoice_code
  before_save :check_overdue_status

  # Methods
  def mark_as_paid!(paid_date = Time.current)
    update(status: 'paid', paid_date:)
  end

  def mark_as_overdue!
    update(status: 'overdue') if pending? && due_date < Date.current
  end

  def paid?
    status == 'paid'
  end

  def pending?
    status == 'pending'
  end

  def overdue?
    status == 'overdue'
  end

  def days_until_due
    (due_date - Date.current).to_i
  end

  def is_overdue?
    pending? && due_date < Date.current
  end

  private

  def generate_invoice_code
    self.invoice_code ||= "INV-#{Date.current.strftime('%Y%m')}-#{SecureRandom.random_bytes(4).unpack1('H*').upcase[0..5]}"
  end

  def check_overdue_status
    self.status = 'overdue' if pending? && due_date < Date.current
  end
end
