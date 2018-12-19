-- This file exist because our ORM (Crecto) is shit
-- It cannot create tables itself


DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS building;
DROP TABLE IF EXISTS ticket;


-- This table will be use to store users data
CREATE TABLE users(

  -- Schema
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  phone varchar(255) NOT NULL,
  -- This field will be checked with a regexp in the ORM part
  email varchar(255) NOT NULL,
  -- The role field will be either "user" or "admin", this will be checked in the ORM
  role varchar(255) NOT NULL,

  -- Bob can blacklist some annoying clients
  -- they can still connect to the website but all their tickets will be discarded automaticaly
  blacklist bool NOT NULL,

  -- The password will be hashed with advanced hashing algorithm (blockchain and deep learning based)
  -- This algorithm will leave no room for potential vulnerabilities and our website will be **secure by design**
  password varchar(255),


  -- Autoupdated with the ORM
  created_at DATETIME,
  updated_at DATETIME,

  -- Constraint
  CONSTRAINT phone_unique UNIQUE (phone),
  CONSTRAINT email_unique UNIQUE (email)
);


CREATE TABLE building(
  -- Schema
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  floorCount INTEGER NOT NULL,
  address varchar(255) NOT NULL,
  country varchar(255) NOT NULL,

  picture_data BLOB,
  picture_name varchar(255),
  picture_mime varchar(255),


  -- Foreign key to the user table
  user_id INTEGER references users(id),

  -- Autoupdated with the ORM
  created_at DATETIME,
  updated_at DATETIME
);

CREATE TABLE ticket(
  -- Schema
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  orientation INTEGER NOT NULL,
  floor INTEGER NOT NULL,
  intervention_time DATETIME,
  state INTEGER NOT NULL,

  picture_data BLOB,
  picture_name varchar(255),
  picture_mime varchar(255),

  -- Foreign key to the users table
  user_id INTEGER references users(id),
  -- Foreign key to the building table
  building_id INTEGER references building(id),

  -- Autoupdated with the ORM
  created_at DATETIME,
  updated_at DATETIME
);
