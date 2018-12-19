require "uuid"

class Building < Crecto::Model
  def initialize(user_id : Int64, floorCount : Int64, address : String, country : String)
    @user_id = user_id
    @floorCount = floorCount
    @address = address
    @country = country
  end

  schema "building" do
    field :floorCount, Int64

    # Address
    field :address, String
    field :country, String

    # Picture
    field :picture_data, String
    field :picture_name, String
    field :picture_mime, String

    # Associations
    belongs_to :user, User
    has_many :ticket, Ticket
  end

  # Required field
  validate_required [:floorCount, :address, :country]
  validate_exclusion :country, in: ["Norvège"]

  def insert : Int64
    # Check for input validity
    changeset = Building.changeset(self)
    if !changeset.valid?
      raise InsertionException.new("Building.insert : Building is not valid : #{changeset.errors}")
    end

    # Insert Building
    changeset = Repo.insert(self)
    if !changeset.valid?
      raise InsertionException.new("Building.insert : Error inserting building : #{changeset.errors}")
    end

    changeset.instance.id.as(Int64)
  end

  def self.get_by_id(building_id : Int64)
    Repo.get(Building, building_id)
  end

  def self.get(user_id : Int64)
    Repo.all(Building, Query.where(user_id: user_id))
  end

  def self.set_picture(building_id : Int64, picture_data : String, picture_name : String)
    building = Repo.get!(Building, building_id)
    building.picture_data = picture_data
    building.picture_name = UUID.random.to_s + File.extname(picture_name)
    case File.extname(picture_name)
    when ".jpg", ".jpeg"
      building.picture_mime = "image/jpeg"
    when ".png"
      building.picture_mime = "image/png"
    else
      building.picture_mime = ""
    end
    changeset = Repo.update(building)
    # TODO Check errors
  end
end
