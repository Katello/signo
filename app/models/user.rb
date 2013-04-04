# A user that can authenticate
class User
  attr_accessor :username, :password

  def initialize(username, password)
    self.username = username
    self.password = password
  end

  # authenticate user
  #
  # currently we use only Katello to authenticate user using his credentials
  # @return [true, false] was authentication successful?
  def authenticate
    Backends::Base.authenticate(self)
  end
end