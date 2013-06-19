require 'net/http'
require 'net/https'

class Backends::Katello < Backends::Base
  attr_accessor :username, :password, :auth_url, :response

  def authenticate(user)
    parse_options(user)
    do_auth
    check_result
  end

  private

  def parse_options(user)
    @username = user.username
    @password = user.password
    @auth_url = Configuration.config.backends.katello.url
  end

  def do_auth
    username_esc = URI.escape(username)
    password_esc = URI.escape(password)
    uri          = URI.parse("#{auth_url}?username=#{username_esc}&password=#{password_esc}")
    http         = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https' || Configuration.config.enforce_ssl
      http.use_ssl = true 
      http.ca_file = Configuration.config.ca_file
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    request      = Net::HTTP::Get.new(uri.request_uri)
    @response    = http.request(request)
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ECONNREFUSED => e
    logger.error "An error #{e.class} occured with message #{e.message}"
    logger.error e.backtrace.join("\n")
    # @response will be nil and will result in false
  rescue OpenSSL::SSL::SSLError => e
    logger.error "An SSL error #{e.class} occured with message #{e.message}"
    logger.error "check whether #{auth_url} certificate is trusted by CA #{Configuration.config.ca_file}"
    logger.error e.backtrace.join("\n")
  end

  def check_result
    (@response && @response.code == '200').tap do |result|
      logger.info "user #{@username} authentication: #{result}"
    end
  end

  def self.logger
    Logging.logger['katello']
  end
end
