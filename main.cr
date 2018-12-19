require "kemal"
require "kemal-session"

LOG_DB = true

require "./database/database"
require "./handler.cr"
require "./email.cr"

Kemal::Session.config.engine = Kemal::Session::FileEngine.new({:sessions_dir => "sessions/"})
Kemal::Session.config do |config|
  config.cookie_name = "session"
  config.secret = "some_secret"
  config.gc_interval = 2.minutes # 2 minutes
end

public_folder "static"
serve_static({"gzip" => true, "dir_listing" => false})
add_handler SetSession.new

logging false
gzip true

get "/" do |env|
  error = nil
  logged = env.get("is_auth")
  is_admin = env.get("is_admin")
  next render "index.ecr"
end

post "/signin" do |env|
  if env.get("is_auth")
    next env.redirect "/"
  end

  email = env.params.body["email"].as(String)
  user = User.get_by_email(email)
  logged = false
  is_admin = env.get("is_admin")
  if user == nil
    error = "Email not found"
    next render "index.ecr"
  end

  password = env.params.body["password"].as(String)
  if !user.as(User).check_password(password)
    error = "Bad password"
    next render "index.ecr"
  end

  env.session.bigint("session", user.as(User).id.as(Int64)) # set the value of "session"
  next env.redirect "/"
end

get "/signout" do |env|
  if !env.get("is_auth")
    next env.redirect "/"
  end
  env.session.destroy
  env.redirect "/"
end

get "/tickets" do |env|
  env.response.content_type = "application/json"
  if env.get("is_auth")
  else
    next env.redirect "/403"
  end

  Ticket.get(env.get("user_id").as(Int64)).to_json
end

get "/admin/tickets" do |env|
  env.response.content_type = "application/json"
  if !env.get("is_auth") || !env.get("is_admin")
    halt env, status_code: 403, response: "Forbidden"
  end

  Ticket.all.to_json
end

patch "/admin/ticket/state/:state/:id" do |env|
  if !env.get("is_auth") || !env.get("is_admin")
    halt env, status_code: 403, response: "Forbidden"
  end

  # Check if ticket exist
  ticket_id = env.params.url["id"]
  ticket = Repo.get!(Ticket, ticket_id)
  if ticket == nil
    halt env, status_code: 404
  end

  case env.params.url["state"]
  when "accept"
    ticket.state = 1_i64
  when "refuse"
    ticket.state = 3_i64
  when "done"
    ticket.state = 2_i64
  else
    halt env, status_code: 404
  end
  Repo.update(ticket)
  "Ok"
end

get "/ticket/:id/img" do |env|
  if !env.get("is_auth")
    halt env, status_code: 403, response: "Forbidden"
  end
  # Check if ticket exist
  ticket_id = env.params.url["id"]
  ticket = Repo.get!(Ticket, ticket_id)
  if ticket == nil
    halt env, status_code: 404
  end

  # Check if ticket is owned by user or is admin
  if !env.get("is_admin")
    user_id = env.get("user_id").as(Int64)
    if ticket.user_id != user_id
      halt env, status_code: 403
    end
  end

  if !ticket.picture_data.nil?
    send_file env, Base64.decode(ticket.picture_data.not_nil!), ticket.picture_mime
  else
    send_file env, Base64.decode("PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTkuMS4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDY0LjgyOCA2NC44MjgiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDY0LjgyOCA2NC44Mjg7IiB4bWw6c3BhY2U9InByZXNlcnZlIiB3aWR0aD0iNTEycHgiIGhlaWdodD0iNTEycHgiPgo8Zz4KCTxwYXRoIGQ9Ik01Ny40MTQsMTdsLTAuNzA3LDAuNzA3Yy0xLjMyNCwxLjMyNC0yLjI4NywxLjcwNy00LjI5MywxLjcwN2MtNC4wNTYsMC03LTIuOTQ0LTctN2MwLTIuMDA2LDAuMzgzLTIuOTY5LDEuNzA3LTQuMjkzICAgbDAuNzA3LTAuNzA3TDQwLjQxNCwwTDAsNDAuNDE0bDcuNDE0LDcuNDE0bDAuNzA3LTAuNzA3YzEuMzI0LTEuMzI0LDIuMjg3LTEuNzA3LDQuMjkzLTEuNzA3YzQuMDU2LDAsNywyLjk0NCw3LDcgICBjMCwyLjAwNi0wLjM4MywyLjk2OS0xLjcwNyw0LjI5M0wxNyw1Ny40MTRsNy40MTQsNy40MTRsNDAuNDE0LTQwLjQxNEw1Ny40MTQsMTd6IE0xOS44LDU3LjM4NSAgIGMxLjE5Mi0xLjQyMSwxLjYxNC0yLjc5LDEuNjE0LTQuOTcxYzAtNS4xMzEtMy44NjktOS05LTljLTIuMTgxLDAtMy41NSwwLjQyMi00Ljk3MiwxLjYxNGwtNC42MTQtNC42MTRsMjMuNTg2LTIzLjU4NmwzLjI5MywzLjI5MyAgIGwxLjQxNC0xLjQxNGwtMy4yOTMtMy4yOTNMNDAuNDE0LDIuODI4bDQuNjE0LDQuNjE1Yy0xLjE5MiwxLjQyMS0xLjYxNCwyLjc5LTEuNjE0LDQuOTcxYzAsNS4xMzEsMy44NjksOSw5LDkgICBjMi4xODEsMCwzLjU1LTAuNDIyLDQuOTcyLTEuNjE0TDYyLDI0LjQxNEw0OS40MTQsMzdsLTMuMjkzLTMuMjkzbC0xLjQxNCwxLjQxNEw0OCwzOC40MTRMMjQuNDE0LDYyTDE5LjgsNTcuMzg1eiIgZmlsbD0iIzAwMDAwMCIvPgoJPHBhdGggZD0iTTM1LjcwNywyNi4xMjJsLTQtNGwxLjQxNC0xLjQxNGw0LDRMMzUuNzA3LDI2LjEyMnoiIGZpbGw9IiMwMDAwMDAiLz4KCTxwYXRoIGQ9Ik00Mi43MDcsMzMuMTIybC00LTRsMS40MTQtMS40MTRsNCw0TDQyLjcwNywzMy4xMjJ6IiBmaWxsPSIjMDAwMDAwIi8+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPC9zdmc+Cg=="), "image/svg+xml"
  end
end

post "/ticket" do |env|
  if !env.get("is_auth")
    halt env, status_code: 403, response: "Forbidden"
  end

  building_id = env.params.json["building"].as(Int64)
  orientation = env.params.json["orientation"].as(Int64)
  building_floor = env.params.json["building_floor"].as(Int64)

  # Warning ! Since Crystal 0.27 Time.epoch_ms become Time.unix_ms
  # And of course that shit lang that is crytal did not documented this
  # I needed to deepdive the source code to understand this ..
  intervention_date = Time.unix_ms(env.params.json["intervention_date"].as(Int))

  # Check if building exist
  building = Repo.get!(Building, building_id)
  if building == nil
    halt env, status_code: 404
  end

  # Check if floor exist
  if building_floor < 0 || building_floor > building.floorCount.as(Int64)
    halt env, status_code: 404
  end

  # Check if building is owned by user
  user_id = env.get("user_id").as(Int64)
  if building.user_id != user_id
    halt env, status_code: 403
  end

  # insert ticket
  ticket = Ticket.new orientation, building_floor, user_id, building_id, intervention_date
  ticket_id = ticket.insert

  # insert image
  file_data = env.params.json["file_data"]
  file_name = env.params.json["file_name"]
  if file_data != nil && file_name != nil && file_name != "" && file_name != ""
    Ticket.set_picture(ticket_id, file_data.as(String), file_name.as(String))
  end

  # Send email
  user = Repo.get!(User, user_id)
  email_ticket_waiting_validation(user.email.as(String))

  "Ok"
end

get "/buildings" do |env|
  env.response.content_type = "application/json"
  if env.get("is_auth")
    User.get_buildings(env.get("user_id").as(Int64)).to_json
  else
    next env.redirect "/403"
  end
end

get "/building/:id/img" do |env|
  if !env.get("is_auth")
    halt env, status_code: 403, response: "Forbidden"
  end
  # Check if building exist
  building_id = env.params.url["id"]
  building = Repo.get!(Building, building_id)
  if building == nil
    halt env, status_code: 404
  end

  # Check if building is owned by user
  user_id = env.get("user_id").as(Int64)
  if building.user_id != user_id
    halt env, status_code: 403
  end

  if !building.picture_data.nil?
    send_file env, Base64.decode(building.picture_data.not_nil!), building.picture_mime
  else
    send_file env, Base64.decode("PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTkuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDI0Ny43ODkgMjQ3Ljc4OSIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMjQ3Ljc4OSAyNDcuNzg5OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4Ij4KPHBhdGggZD0iTTIyMy43NzksMTIyLjg5NWMtMy4zMTMsMC02LDIuNjg3LTYsNnYxMDYuODk1aC02NC4zODR2LTY3LjEwMmMwLTMuMzEzLTIuNjg3LTYtNi02aC00N2MtMy4zMTMsMC02LDIuNjg3LTYsNnY1My4yMDcgIGMwLDMuMzEzLDIuNjg3LDYsNiw2czYtMi42ODcsNi02di00Ny4yMDdoMzV2NjEuMTAySDMwLjAxVjg4LjkyOWw5My44ODQtNzUuMjM5bDk2LjEzMiw3Ny4wNGMyLjU4NiwyLjA3Myw2LjM2MiwxLjY1NSw4LjQzNC0wLjkzICBjMi4wNzItMi41ODYsMS42NTYtNi4zNjEtMC45My04LjQzNEwxMjcuNjQ2LDEuMzE4Yy0yLjE5Mi0xLjc1OC01LjMxMi0xLjc1OC03LjUwNCwwTDIwLjI1OCw4MS4zNjYgIGMtMS40MjEsMS4xMzktMi4yNDgsMi44Ni0yLjI0OCw0LjY4MnYxNTUuNzQxYzAsMy4zMTMsMi42ODYsNiw2LDZoMTk5Ljc2OWMzLjMxNCwwLDYtMi42ODcsNi02VjEyOC44OTUgIEMyMjkuNzc5LDEyNS41ODEsMjI3LjA5MywxMjIuODk1LDIyMy43NzksMTIyLjg5NXoiIGZpbGw9IiMwMDAwMDAiLz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPC9zdmc+Cg=="), "image/svg+xml"
  end
end

post "/building" do |env|
  if !env.get("is_auth")
    halt env, status_code: 403, response: "Forbidden"
  end
  user_id = env.get("user_id").as(Int64)
  # name = env.params.json["name"].as(String)
  nb_floor = env.params.json["nb_floor"].as(String).to_i64
  address = env.params.json["address"].as(String)
  country = env.params.json["country"].as(String)

  # insert building
  building = Building.new user_id, nb_floor, address, country
  building_id = building.insert

  # insert image
  file_data = env.params.json["file_data"]
  file_name = env.params.json["file_name"]
  if file_data != nil && file_name != nil && file_name != "" && file_name != ""
    Building.set_picture(building_id, file_data.as(String), file_name.as(String))
  end
end

delete "/building/:id" do |env|
  if !env.get("is_auth")
    halt env, status_code: 403, response: "Forbidden"
  end

  # Check if building exist
  building_id = env.params.url["id"]
  building = Repo.get!(Building, building_id)
  if building == nil
    halt env, status_code: 404
  end

  # Check if building is owned by user
  user_id = env.get("user_id").as(Int64)
  if building.user_id != user_id
    halt env, status_code: 403
  end

  changeset = Repo.delete(building)
end

get "/all" do |env|
  env.response.content_type = "application/json"

  if env.get("is_auth")
    User.get_buildings(env.get("user_id").as(Int64)).to_json
  else
    next env.redirect "/403"
  end
end

error 404 do
  "This is a customized 404 page."
end

error 403 do
  "Access Forbidden!"
end

Kemal.config.port = 8080
Kemal.config.host_binding = "127.0.0.1"

Kemal.run
