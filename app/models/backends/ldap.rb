require 'ldap_fluff'

class Backends::Ldap < Backends::Base
  attr_accessor :username, :password

  def authenticate(user)
    parse_options(user)
    do_auth
    check_result
  end

  private

  def parse_options(user)
    @username = user.username
    @password = user.password
  end

  def do_auth
    ldap = LdapFluff.new(Configuration.config.backends.ldap)
    @result = ldap.authenticate? @username, @password
  # TODO support LdapFluff::ConfigError when merged in ldap_fluff upstream
  rescue Net::LDAP::LdapError => e
    logger.error "An error #{e.class} occured with message #{e.message}"
    logger.error e.backtrace.join("\n")
    # @response will be nil and will result in false
  end

  def check_result
    logger.info "user #{@username} authentication: #{@result}"
    @result
  end

  def self.logger
    Logging.logger['ldap']
  end
end