LOG_DB = true

require "../database/database"

test_number = 0_u32

user = User.new "Victor123", "Collette", "0102030405", "victor@collette.io", "test"

changeset = User.changeset(user)
if changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return false because first_name is invalid"
else
  puts "#{test_number += 1} - OK"
end

changeset = Repo.insert(user)
if changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return false because first_name is invalid"
else
  puts "#{test_number += 1} - OK"
end

user.first_name = "Victor"
changeset = User.changeset(user)

if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because first_name is valid"
else
  puts "#{test_number += 1} - OK"
end

changeset = Repo.insert(user)
if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because first_name is valid"
else
  puts "#{test_number += 1} - OK"
end

changeset = Repo.insert(user)
if changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return false because of unique constraint"
else
  puts "#{test_number += 1} - OK"
end

query = Query
  .order_by("users.first_name ASC")

users = Repo.all(User, query)
users = users.as(Array) unless users.nil?
if users.size != 1
  puts users
  raise "#{test_number += 1} - KO - The size must be 1"
else
  puts "#{test_number += 1} - OK"
end

if users[0].@first_name != "Victor"
  puts users
  raise "#{test_number += 1} - KO - Wrong firstname insertion"
else
  puts "#{test_number += 1} - OK"
end

#user = User.new "Aubin", "Lagorce", "0202030405", "victor@collette.io", "test"

changeset = User.changeset(user)
if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because user is valid"
else
  puts "#{test_number += 1} - OK"
end

user = User.new "Paul", "Banus", "08080808080", "paul@collette.io", "test"
user.role = "admin"
changeset = Repo.insert(user)
if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because user is valid"
else
  puts "#{test_number += 1} - OK"
end

user = User.new "Francois", "Cherrier", "1234567890", "francois@collette.io", "test"
changeset = User.changeset(user)
if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because user is valid"
else
  puts "#{test_number += 1} - OK"
end


user_id = user.insert
if user_id <= 0
  puts changeset.errors
  raise "#{test_number += 1} - KO - ID incorrect in user insertion"
else
  puts "#{test_number += 1} - OK"
end

building = Building.new 10, user_id, "14 ojfe", "France"
changeset = Building.changeset(building)
if !changeset.valid?
  puts changeset.errors
  raise "#{test_number += 1} - KO - Must return true because building is valid"
else
  puts "#{test_number += 1} - OK"
end

building_id = building.insert
if building_id <= 0
  puts changeset.errors
  raise "#{test_number += 1} - KO - ID incorrect in building insertion"
else
  puts "#{test_number += 1} - OK"
end

# ticket = Ticket.new 6, 120, user_id, building_id
# changeset = Ticket.changeset(ticket)
# if !changeset.valid?
#  puts changeset.errors
#  raise "#{test_number += 1} - KO - Must return true because ticket is valid"
# else
#  puts "#{test_number += 1} - OK"
# end

# if ticket.insert <= 0
#  puts changeset.errors
#  raise "#{test_number += 1} - KO - ID incorrect in ticket insertion"
# else
#  puts "#{test_number += 1} - OK"
# end
