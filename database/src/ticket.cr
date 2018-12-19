class Ticket < Crecto::Model
  # We cannot use the sweet 'State' enum because Sqlite does not support enum type
  #  enum State
  #   PENDING
  #   DONE
  #   PLANIFIED
  #   CANCELED
  #  end
  # So we will use these instead (the @@ is for class variables, instead of instance variables) :
  @@PENDING = 0_i64
  @@PLANIFIED = 1_i64
  @@DONE = 2_i64
  @@CANCELED = 3_i64

  # We use 64 bits int because Crecto does not support smaller int types nor unsigned

  def initialize(orientation : Int64, floor : Int64, user_id : Int64, building_id : Int64, intervention_time : Time)
    @orientation = orientation
    @floor = floor
    @user_id = user_id
    @building_id = building_id
    @intervention_time = intervention_time
  end

  schema "ticket" do
    field :orientation, Int64
    field :floor, Int64
    field :intervention_time, Time
    field :state, Int64, default: 0_i64

    # Picture
    field :picture_data, String
    field :picture_name, String
    field :picture_mime, String

    # Associations
    belongs_to :user, User
    belongs_to :building, Building
  end

  # Required field
  validate_required [:orientation, :floor, :state, :intervention_time]

  # Validation
  # Orientation degree
  validate_inclusion :orientation, in: 0..360

  def insert : Int64
    # Check for input validity
    changeset = Ticket.changeset(self)
    if !changeset.valid?
      raise InsertionException.new("Ticket.insert : Ticket is not valid : #{changeset.errors}")
    end

    # Insert Ticket
    changeset = Repo.insert(self)
    if !changeset.valid?
      raise InsertionException.new("Ticket.insert : Error inserting ticket : #{changeset.errors}")
    end

    changeset.instance.id.as(Int64)
  end

  def self.update_intervention_time(ticket_id : Int64, intervention_time : Time) : Int64
    # Check for input validity
    ticket = nil
    begin
      ticket = Repo.get!(Ticket, ticket_id)
    rescue Crecto::NoResults
      raise UpdateException.new("No ticket with id : #{ticket_id}")
    end

    ticket.intervention_time = intervention_time
    # TODO : DONE if intervention_time > today
    ticket.state = @@PLANIFIED
    changeset = Repo.update(ticket)
    if !changeset.valid?
      raise UpdateException.new("Error inserting ticket : #{changeset.errors}")
    end
    changeset.instance.id.as(Int64)
  end

  def self.all
    Repo.all(Ticket, Query.order_by("state"), preload: [:building])
  end

  def self.all(state : Int64)
    query = Query.where(state: state)
    Repo.all(Ticket, query, preload: [:building])
  end

  def self.get(user_id : Int64)
    Repo.all(Ticket, Query.where(user_id: user_id), preload: [:building])
  end

  def self.set_picture(ticket_id : Int64, picture_data : String, picture_name : String)
    ticket = Repo.get!(Ticket, ticket_id)
    ticket.picture_data = picture_data
    ticket.picture_name = UUID.random.to_s + File.extname(picture_name)
    case File.extname(picture_name)
    when ".jpg", ".jpeg"
      ticket.picture_mime = "image/jpeg"
    when ".png"
      ticket.picture_mime = "image/png"
    else
      ticket.picture_mime = ""
    end
    changeset = Repo.update(ticket)
    # TODO Check errors
  end
end
