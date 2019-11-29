# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user1 = User.create(name: 'name1', account: 'account1', password: 'pass', role: 'admin')
user2 = User.create(name: 'name2', account: 'account2', password: 'pass', role: 'admin')
user3 = User.create(name: 'name3', account: 'account3', password: 'pass', role: 'admin')

5.times do |index|
  user1.tasks.create(name: "#{user1.name}-todo#{index}")
  user2.tasks.create(name: "#{user2.name}-todo#{index}")
  user3.tasks.create(name: "#{user3.name}-todo#{index}")
  user1.tasks.create(name: "#{user1.name}-done#{index}", status: 'done')
  user2.tasks.create(name: "#{user2.name}-done#{index}", status: 'done')
  user3.tasks.create(name: "#{user3.name}-done#{index}", status: 'done')
  Label.create(name: "label-#{index}")
end

Config.create(name: 'maintenance', enabled: 0)
