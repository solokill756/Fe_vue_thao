# Detailed Seed data for TuitionInvoices
# Run: rails db:seed

puts "🎓 Seeding TuitionInvoices..."

student_count = 0
invoice_count = 0

User.find_each do |user|
  # Only create tuition invoices for users with student profile
  next unless user.respond_to?(:student_profile) && user.student_profile

  student = user.student_profile
  next unless student

  student_count += 1
  current_date = Date.current

  # 1. Pending invoice - Current month
  pending_invoice = TuitionInvoice.find_or_create_by(
    student_id: student.id,
    invoice_code: "INV-#{current_date.strftime('%Y%m')}-001"
  ) do |invoice|
    invoice.title = "Học phí Tháng #{current_date.month}/#{current_date.year} - Combo Toán + Anh"
    invoice.description = "Gói học phí tháng này (đã trừ ưu đãi Tết)"
    invoice.amount = 2_000_000
    invoice.due_date = current_date.end_of_month + 15.days
    invoice.status = 'pending'
  end
  invoice_count += 1 if pending_invoice.persisted?
  puts "  ✅ Created pending invoice: #{pending_invoice.title} (#{student.user.full_name})" rescue puts "  ✅ Created pending invoice: #{pending_invoice.title}"

  # 2. Overdue invoice - Previous month
  overdue_invoice = TuitionInvoice.find_or_create_by(
    student_id: student.id,
    invoice_code: "INV-#{(current_date - 1.month).strftime('%Y%m')}-002"
  ) do |invoice|
    invoice.title = "Phụ phí tài liệu Vật Lý - Tháng #{(current_date - 1.month).month}/#{(current_date - 1.month).year}"
    invoice.description = "Sách bài tập nâng cao Tập 1"
    invoice.amount = 500_000
    invoice.due_date = (current_date - 1.month).end_of_month
    invoice.status = 'overdue'
  end
  invoice_count += 1 if overdue_invoice.persisted?
  puts "  ✅ Created overdue invoice: #{overdue_invoice.title} (#{student.user.full_name})" rescue puts "  ✅ Created overdue invoice: #{overdue_invoice.title}"

  # 3. Additional pending invoice - Next month
  next_pending = TuitionInvoice.find_or_create_by(
    student_id: student.id,
    invoice_code: "INV-#{(current_date + 1.month).strftime('%Y%m')}-003"
  ) do |invoice|
    invoice.title = "Học phí Tháng #{(current_date + 1.month).month}/#{(current_date + 1.month).year}"
    invoice.description = "Gói học phí cho tháng tiếp theo"
    invoice.amount = 2_500_000
    invoice.due_date = (current_date + 1.month).end_of_month
    invoice.status = 'pending'
  end
  invoice_count += 1 if next_pending.persisted?
  puts "  ✅ Created next month invoice: #{next_pending.title} (#{student.user.full_name})" rescue puts "  ✅ Created next month invoice: #{next_pending.title}"

  # 4-6. Paid invoices - History (last 3 months)
  (1..3).each do |i|
    past_date = current_date - i.months
    paid_invoice = TuitionInvoice.find_or_create_by(
      student_id: student.id,
      invoice_code: "INV-#{past_date.strftime('%Y%m')}-PAID"
    ) do |invoice|
      invoice.title = "Học phí Tháng #{past_date.month}/#{past_date.year} (Đã thanh toán)"
      invoice.description = "Gói học phí đã được thanh toán đầy đủ"
      invoice.amount = 2_500_000
      invoice.due_date = past_date.end_of_month
      invoice.paid_date = past_date.end_of_month - (5 - i).days
      invoice.status = 'paid'
    end
    invoice_count += 1 if paid_invoice.persisted?
    puts "  ✅ Created paid invoice: #{paid_invoice.title}"
  end
end

puts "\n📊 TuitionInvoices Seed Summary:"
puts "  Total students processed: #{student_count}"
puts "  Total invoices created: #{invoice_count}"
puts "✨ TuitionInvoices seeding completed!\n"
