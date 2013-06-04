require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

SimpleCov.root Rails.root
require "minitest/autorun"
require "minitest/rails"
require 'webmock/minitest'

# Uncomment if you want awesome colorful output
# require "minitest/pride"

class MiniTest::Unit::TestCase

end

require 'action_controller/test_case'

class MiniTest::Spec
  class << self
    alias context describe
  end

  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveSupport::Testing::Assertions

  alias :method_name :__name__ if defined? :__name__
end

class ControllerSpec < MiniTest::Spec
  include Rails.application.routes.url_helpers
  include ActionController::TestCase::Behavior

  # Rails 3.2 determines the controller class by matching class names that end in Test
  # This overides the #determine_default_controller_class method to allow you use Controller
  # class names in your describe argument
  # cf: https://github.com/rawongithub/minitest-rails/blob/gemspec/lib/minitest/rails/controller.rb
  def self.determine_default_controller_class(name)
    if name.match(/.*(?:^|::)(\w+Controller)/)
      $1.safe_constantize
    else
      super(name)
    end
  end

  before do
    @controller = self.class.name.match(/((.*)Controller)/)[1].constantize.new
    @routes     = Rails.application.routes
  end

  subject do
    @controller
  end
end

# Test subjects ending with 'Controller' are treated as functional tests
#   e.g. describe TestController do ...
MiniTest::Spec.register_spec_type(/Controller$/, ControllerSpec)