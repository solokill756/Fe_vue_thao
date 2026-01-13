# frozen_string_literal: true

# Seed data for Assignments

# Clear existing data (skip if records exist to avoid foreign key issues)
# Assignment.delete_all
# AssignmentAttachment.delete_all

# Get existing classes (or create some if needed)
classes = SchoolClass.limit(5)

if classes.empty?
  puts "⚠️  No classes found. Please seed classes first."
  return
end

# Define assignment data
assignments_data = [
  {
    class: classes[0],
    title: "Introduction to Ruby Basics",
    content: "Learn the fundamentals of Ruby programming including variables, data types, and operators.",
    assignment_type: "homework",
    due_date: 2.days.from_now
  },
  {
    class: classes[0],
    title: "Ruby Method & Control Flow Quiz",
    content: "Test your understanding of Ruby methods, conditionals, and loops.",
    assignment_type: "test",
    due_date: 5.days.from_now
  },
  {
    class: classes[0],
    title: "Build a Command-Line Application",
    content: "Create a command-line Ruby application that demonstrates OOP concepts.",
    assignment_type: "project",
    due_date: 14.days.from_now
  },
  {
    class: classes[1],
    title: "SQL JOIN Operations",
    content: "Practice writing SQL queries with different types of joins (INNER, LEFT, RIGHT, FULL).",
    assignment_type: "homework",
    due_date: 3.days.from_now
  },
  {
    class: classes[1],
    title: "Database Design Assignment",
    content: "Design and normalize a database schema for an e-commerce system.",
    assignment_type: "project",
    due_date: 10.days.from_now
  },
  {
    class: classes[1],
    title: "SQL Query Optimization",
    content: "Optimize and explain the performance improvements of complex SQL queries.",
    assignment_type: "test",
    due_date: 7.days.from_now
  },
  {
    class: classes[2],
    title: "HTML & CSS Layout Exercise",
    content: "Create a responsive web layout using HTML5 semantic elements and CSS Grid/Flexbox.",
    assignment_type: "homework",
    due_date: 1.day.from_now
  },
  {
    class: classes[2],
    title: "JavaScript DOM Manipulation",
    content: "Build an interactive web application using vanilla JavaScript DOM methods.",
    assignment_type: "project",
    due_date: 12.days.from_now
  },
  {
    class: classes[2],
    title: "Web Development Midterm Exam",
    content: "Comprehensive exam covering HTML, CSS, and JavaScript fundamentals.",
    assignment_type: "test",
    due_date: 8.days.from_now
  },
  {
    class: classes[3],
    title: "React Component Basics",
    content: "Create reusable React components with props and state management.",
    assignment_type: "homework",
    due_date: 4.days.from_now
  },
  {
    class: classes[3],
    title: "Build a Todo App with React Hooks",
    content: "Develop a fully functional todo application using React hooks (useState, useEffect).",
    assignment_type: "project",
    due_date: 15.days.from_now
  },
  {
    class: classes[4],
    title: "Rails Model Associations",
    content: "Practice implementing has_many, belongs_to, and has_many :through associations.",
    assignment_type: "homework",
    due_date: 2.days.from_now
  }
]

# Create assignments with attachments
assignments_data.each do |data|
  assignment = Assignment.create!(
    school_class: data[:class],
    title: data[:title],
    content: data[:content],
    assignment_type: data[:assignment_type],
    due_date: data[:due_date]
  )

  # Add some sample attachments
  attachment_names = ["syllabus.pdf", "resources.pdf", "guidelines.docx", "example.zip"]
  rand(1..2).times do |i|
    AssignmentAttachment.create!(
      assignment: assignment,
      file_name: "#{assignment.title.parameterize}_#{i + 1}_#{attachment_names.sample}",
      file_url: "https://example.com/files/#{SecureRandom.hex(8)}.pdf"
    )
  end

  puts "✅ Created assignment: #{assignment.title} (#{assignment.assignment_type}) for class: #{assignment.school_class.name}"
end

puts "\n✅ Successfully seeded #{Assignment.count} assignments with attachments"
