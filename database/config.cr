# Database configuration
module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::SQLite3
    conf.hostname = "localhost"
    conf.database = "./database/cristal.db"
  end
end

if LOG_DB
  Crecto::DbLogger.set_handler(STDOUT)
end

# Alias
Query = Crecto::Repo::Query
