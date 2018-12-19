class SetSession < Kemal::Handler
  def call(env)
    env.set "user_id", env.session.bigint?("session")
    env.set "is_auth", env.session.bigint?("session") != nil
    if env.get("is_auth")
      user = User.get(env.get("user_id").as(Int64))
      env.set "is_admin", user.as(User).is_admin
    else
      env.set "is_admin", false
    end
    call_next env
  end
end
