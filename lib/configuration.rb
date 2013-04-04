class Configuration
  attr_accessor :config

  def initialize
    loader = Signo::Configuration::Loader.new(
        :config_file_paths        => %W(#{Rails.root}/config/sso.yml /etc/signo/sso.yml),
        :validation               => lambda {|_| },
        :default_config_file_path => "#{Rails.root}/config/sso_defaults.yml",
        :config_post_process => lambda do |config, environment|
          root = config.logging.loggers.root
          root[:path] = "#{Rails.root}/log" if !root.has_key?(:path) && environment
          root[:type] ||= 'file'
        end
    )
    @config = loader.config
  end

  def self.config
    @instance ||= new.config
  end
end