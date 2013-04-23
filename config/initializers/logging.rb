::Signo::Logging.new(Configuration.config.logging).configure

require 'openid'
::OpenID::Util.logger = ::Logging.logger['openid']
