# Seed data for TuitionInvoices
# Run: rails db:seed

User.find_each do |user|
  # Only create tuition invoices for users with student profile
  next unless user.respond_to?(:student) && user.student

  student = user.student
  next unless student

  # Create sample tuition invoices
  current_date = Date.current
  
  # Pending invoice
  TuitionInvoice.find_or_create_by(
    student_id: student.id,
    invoice_code: "INV-#{current_date.strftime('%Y%m')}-#{SecureRandom.random_bytes(3).unpack1('H*').upcase}"
  ) do |invoice|
    invoice.title = "Học phí Tháng #{current_date.month}/#{current_date.year} - Combo Toán + Anh"
    invoice.description = "Gói học phí tháng này (đã trừ ưu đãi Tết)"
    invoice.amount = 2_000_000
    invoice.due_date = (current_date + 15.days).end_of_month
    invoice.status = 'pending'
  end

  # Overdue invoice (optional)
  if current_date.day > 15
    TuitionInvoice.find_or_create_by(
      student_id: student.id,
      invoice_code: "INV-#{(current_date - 1.month).strftime('%Y%m')}-OVER01"
    ) do |invoice|
      invoice.title = "Phụ phí tài liệu Vật Lý"
      invoice.description = "Sách bài tập nâng cao Tập 1"
      invoice.amount = 500_000
      invoice.due_date = (current_date - 5.days)
      invoice.status = 'overdue'
    end
  end

  # Paid invoices (history)
  (1..3).each do |i|
    past_date = current_date - i.months
    TuitionInvoice.find_or_create_by(
      student_id: student.id,
      invoice_code: "INV-#{past_date.strftime('%Y%m')}-PAID#{i}"
    ) do |invoice|
      invoice.title = "Học phí Tháng #{past_date.month}/#{past_date.year}"
      invoice.amount = 2_500_000
      invoice.due_date = past_date.end_of_month
      invoice.paid_date = past_date.end_of_month
      invoice.status = 'paid'
    end
  end
end

puts "TuitionInvoices seeded successfully!"
