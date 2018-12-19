LOG_DB = true

require "../database/database"

# Victor
victor = User.new "Victor", "Collette", "0202030405", "victor@collette.io", "test"
victor_id = victor.insert

victor_building = Building.new victor_id, "Cristal Building", 10, "1 avenue Foch Paris", "Paris", "75116", "France"
victor_building_id = victor_building.insert

# Aubin
aubin = User.new "Aubin", "Lagorce", "0657575757", "aubin.lagorce@epita.fr", "aubin"
aubin_id = aubin.insert

aubin_building = Building.new aubin_id, "Aubin Building", 10, "1 avenue Foch", "Paris", "75116", "France"
aubin_building_id = aubin_building.insert
