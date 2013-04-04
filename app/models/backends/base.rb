class Backends::Base
  # runs authentication through all enabled backends
  def self.authenticate(user)
    Configuration.config.backends.enabled.any? do |name|
      begin
        backend = "Backends::#{name.to_s.camelize}".constantize
        logger.debug "Using backend #{backend.to_s}"
      rescue NameError => e
        logger.error "Wrong backend name #{name}, check application configuration, ignoring..."
        logger.debug e.backtrace.join("\n")
        next(false)
      end

      backend.new.authenticate(user)
    end
  end

  # should authenticate user and return true or false as a result
  # real authentication backends should implement this method
  def authenticate(user)
    raise NotImplementedError
  end

  private

  def self.logger
    Logging.logger['auth']
  end

  def logger
    self.class.logger
  end
end