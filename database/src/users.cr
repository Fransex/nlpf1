require "crypto/bcrypt/password"

class User < Crecto::Model
  def initialize(first_name : String, last_name : String, phone : String, email : String, password : String)
    @first_name = first_name
    @last_name = last_name
    @phone = phone
    @email = email
    @password = Crypto::Bcrypt::Password.create(password, cost: 10).to_s
  end

  def set_password(password : String)
    @password = Crypto::Bcrypt::Password.create(password, cost: 10).as(String).to_s
  end

  def check_password(password : String)
    Crypto::Bcrypt::Password.new(@password.as(String)) == password
  end

  def is_admin
    @role == "admin"
  end

  schema "users" do
    field :first_name, String
    field :last_name, String
    field :phone, String
    field :email, String
    field :password, String
    field :blacklist, Bool, default: false
    field :role, String, default: "user"

    # Associations
    has_many :buildings, Building
    has_many :tickets, Ticket
  end
  # Format
  validate_format :first_name, /^[a-zA-Z]*$/
  validate_format :email, /^[^@]+@[^.@]+\.[^@]+$/

  # Required field
  validate_required [:first_name, :last_name, :phone, :email, :blacklist]

  # Unique constraint
  unique_constraint :email
  unique_constraint :phone

  # Validation
  # role should be either admin or user
  # it may sound a bit discriminant to all the non-binary people out there
  # but we are strong believer of a binary world
  validate_inclusion :role, in: ["admin", "user"]

  def insert : Int64
    # Check for input validity
    changeset = User.changeset(self)
    if !changeset.valid?
      raise InsertionException.new("User.insert : User is not valid : #{changeset.errors}")
    end

    # Insert User
    changeset = Repo.insert(self)
    if !changeset.valid?
      raise InsertionException.new("User.insert : Error inserting user : #{changeset.errors}")
    end
    changeset.instance.id.as(Int64)
  end

  def self.get(user_id : Int64)
    Repo.get(User, user_id)
  end

  def self.get_by_email(user_email : String)
    Repo.get_by(User, email: user_email)
  end

  def self.get_tickets(user_id : Int64)
    user = Repo.get(User, user_id).as(User)
    Repo.get_association(user, :tickets).as(Array(Ticket))
  end

  def self.get_buildings(user_id : Int64)
    user = Repo.get(User, user_id).as(User)
    Repo.get_association(user, :buildings).as(Array(Building))
  end
end
