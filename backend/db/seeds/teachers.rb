# frozen_string_literal: true

# Seed data for Teachers

# Clear existing data
Teacher.delete_all

# Get teacher users (role = 'teacher')
teacher_users = User.where(role: 'teacher')

if teacher_users.empty?
  puts "⚠️  No teacher users found. Please seed users with role 'teacher' first."
  return
end

# Update user_id field with id if blank
teacher_users.each do |user|
  if user.user_id.blank?
    user.update(user_id: user.id.to_s)
  end
end

# Reload to get updated data
teacher_users.reload

# Teacher data
teacher_data = [
  {
    bio: "Experienced Ruby on Rails developer with 10+ years in web development. Passionate about teaching best practices and modern architecture patterns.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.8
  },
  {
    bio: "Full-stack developer specializing in React, Node.js, and MongoDB. Love mentoring junior developers and building scalable applications.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.6
  },
  {
    bio: "Database architect and SQL expert. Focused on teaching database design, optimization, and complex queries.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.9
  },
  {
    bio: "JavaScript specialist with expertise in modern frameworks. Teaching vanilla JS, React, Vue, and Angular.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.7
  },
  {
    bio: "DevOps and cloud infrastructure specialist. AWS, Docker, Kubernetes expert helping students master deployment and scaling.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.5
  },
  {
    bio: "Python developer and data science enthusiast. Teaching Python, Django, and data analysis with real-world projects.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.8
  },
  {
    bio: "Frontend design and UX specialist. Teaching HTML, CSS, responsive design, and modern UI frameworks.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.4
  },
  {
    bio: "Software architect with focus on system design and patterns. Teaching design patterns, SOLID principles, and clean code.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.9
  },
  {
    bio: "Mobile development expert specializing in iOS and Android. Teaching native development and cross-platform frameworks.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.7
  },
  {
    bio: "Quality assurance and testing specialist. Teaching automated testing, TDD, and QA best practices.",
    package_id: nil,
    package_expiry: nil,
    rating_avg: 4.6
  }
]

# Create teachers from teacher users
teacher_users.each_with_index do |user, index|
  data = teacher_data[index] || teacher_data[0]
  
  Teacher.create!(
    user_id: user.id,
    bio: data[:bio],
    qr_code: "QR-#{user.user_id}",
    package_id: data[:package_id],
    package_expiry: data[:package_expiry],
    rating_avg: data[:rating_avg]
  )
  
  puts "✅ Created teacher: #{user.full_name}"
end

puts "✅ Teacher seed completed! Created #{Teacher.count} teachers."
