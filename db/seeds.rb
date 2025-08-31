# Create rooms
puts "Creating rooms..."
[2, 4, 7, 8].each do |number|
  Room.create!(number: number, has_outlet: true)
end

[1, 3, 5, 6].each do |number|
  Room.create!(number: number, has_outlet: false)
end

puts "Created #{Room.count} rooms"

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@monemusicpractice.com',
  password: 'admin123456',
  password_confirmation: 'admin123456',
  username: 'admin',
  name: '관리자',
  teacher: User::TEACHERS.first,
  approved: true,
  is_admin: true
)

puts "Admin user created: #{admin.email}"

# Create test users
puts "Creating test users..."
3.times do |i|
  user = User.create!(
    email: "user#{i+1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    username: "user#{i+1}",
    name: "테스트유저#{i+1}",
    teacher: User::TEACHERS.sample,
    approved: i == 0  # Only first user is approved
  )
  puts "Created user: #{user.email}"
end

puts "Seeding completed!"