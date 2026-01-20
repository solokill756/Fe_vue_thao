# frozen_string_literal: true

# Seed data for Admin Users and Test Users
# Run: rails db:seed

puts "👤 Seeding Admin and Test Users..."

# Create Admin User
admin_user = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.full_name = 'Admin User'
  user.display_name = 'Admin'
  user.password = 'admin123'
  user.role = 'admin'
  user.otp_verified = true
  user.is_active = true
  user.user_id = SecureRandom.uuid
end

if admin_user.persisted? && admin_user.user_id.blank?
  admin_user.update(user_id: admin_user.id.to_s)
  admin_user.reload
end

puts "✅ Admin user: #{admin_user.email} (Password: admin123)"

# Create Test Teacher Users
teacher_users_data = [
  {
    email: 'teacher1@example.com',
    full_name: 'Nguyễn Văn A',
    password: 'teacher123',
    phone_number: '0901234567',
  },
  {
    email: 'teacher2@example.com',
    full_name: 'Trần Thị B',
    password: 'teacher123',
    phone_number: '0901234568',
  },
  {
    email: 'teacher3@example.com',
    full_name: 'Lê Văn C',
    password: 'teacher123',
    phone_number: '0901234569',
  },
]

teacher_users_data.each do |data|
  user = User.find_or_create_by(email: data[:email]) do |u|
    u.full_name = data[:full_name]
    u.display_name = data[:full_name]
    u.password = data[:password]
    u.role = 'teacher'
    u.otp_verified = true
    u.is_active = true
    u.phone_number = data[:phone_number]
    u.user_id = SecureRandom.uuid
  end

  if user.persisted? && user.user_id.blank?
    user.update(user_id: user.id.to_s)
    user.reload
  end

  # Create Teacher profile if doesn't exist
  unless user.teacher
    Teacher.create!(
      user_id: user.user_id,
      bio: "Giáo viên #{data[:full_name]}",
      rating_avg: rand(4.0..5.0).round(1)
    )
  end

  puts "✅ Teacher: #{user.email} (Password: #{data[:password]})"
end

# Create Test Student Users
student_users_data = [
  {
    email: 'student1@example.com',
    full_name: 'Phạm Văn D',
    password: 'student123',
    phone_number: '0901234570',
  },
  {
    email: 'student2@example.com',
    full_name: 'Hoàng Thị E',
    password: 'student123',
    phone_number: '0901234571',
  },
  {
    email: 'student3@example.com',
    full_name: 'Vũ Văn F',
    password: 'student123',
    phone_number: '0901234572',
  },
  {
    email: 'student4@example.com',
    full_name: 'Đỗ Thị G',
    password: 'student123',
    phone_number: '0901234573',
  },
  {
    email: 'student5@example.com',
    full_name: 'Bùi Văn H',
    password: 'student123',
    phone_number: '0901234574',
  },
]

student_users_data.each do |data|
  user = User.find_or_create_by(email: data[:email]) do |u|
    u.full_name = data[:full_name]
    u.display_name = data[:full_name]
    u.password = data[:password]
    u.role = 'student'
    u.otp_verified = true
    u.is_active = true
    u.phone_number = data[:phone_number]
    u.user_id = SecureRandom.uuid
  end

  if user.persisted? && user.user_id.blank?
    user.update(user_id: user.id.to_s)
    user.reload
  end

  # Create Student profile if doesn't exist
  unless user.student_profile
    # Generate unique student_code
    loop do
      student_code = "STD-#{SecureRandom.hex(4).upcase}"
      unless Student.exists?(student_code: student_code)
        Student.create!(
          user_id: user.id,
          full_name: data[:full_name],
          student_code: student_code,
          wallet_balance: 0
        )
        break
      end
    end
  end

  puts "✅ Student: #{user.email} (Password: #{data[:password]})"
end

# Create some inactive users for testing
inactive_users_data = [
  {
    email: 'teacher_inactive@example.com',
    full_name: 'Giáo viên Chưa Kích Hoạt',
    password: 'teacher123',
    role: 'teacher',
  },
  {
    email: 'student_inactive@example.com',
    full_name: 'Học sinh Chưa Kích Hoạt',
    password: 'student123',
    role: 'student',
  },
]

inactive_users_data.each do |data|
  user = User.find_or_create_by(email: data[:email]) do |u|
    u.full_name = data[:full_name]
    u.display_name = data[:full_name]
    u.password = data[:password]
    u.role = data[:role]
    u.otp_verified = false
    u.is_active = false
    u.user_id = SecureRandom.uuid
  end

  if user.persisted? && user.user_id.blank?
    user.update(user_id: user.id.to_s)
    user.reload
  end

  # Create profile if teacher
  if user.role == 'teacher' && !user.teacher
    Teacher.create!(user_id: user.id, bio: "Giáo viên #{data[:full_name]}")
  elsif user.role == 'student' && !user.student_profile
    # Generate unique student_code
    loop do
      student_code = "STD-#{SecureRandom.hex(4).upcase}"
      unless Student.exists?(student_code: student_code)
        Student.create!(
          user_id: user.id,
          full_name: data[:full_name],
          student_code: student_code,
          wallet_balance: 0
        )
        break
      end
    end
  end

  puts "✅ Inactive #{data[:role]}: #{user.email} (Password: #{data[:password]})"
end

puts "\n📊 Summary:"
puts "  - Admin users: #{User.where(role: 'admin').count}"
puts "  - Active teachers: #{User.where(role: 'teacher', is_active: true).count}"
puts "  - Active students: #{User.where(role: 'student', is_active: true).count}"
puts "  - Inactive users: #{User.where(is_active: false).count}"
puts "\n✅ Admin and test users seeded successfully!"
puts "\n🔑 Login credentials:"
puts "  Admin: admin@example.com / admin123"
puts "  Teacher: teacher1@example.com / teacher123"
puts "  Student: student1@example.com / student123"
