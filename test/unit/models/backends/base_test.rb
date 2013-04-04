require 'test_helper'

class Backends::DummyTrue < Backends::Base
  def authenticate(*args)
    true
  end
end

class Backends::DummyFalse < Backends::Base
  def authenticate(*args)
    false
  end
end

describe Backends::Base do
  describe ".authenticate" do
    let(:result) { Backends::Base.authenticate({}) }

    context "one of backend returns true" do
      it "should go through all of backends" do
        Configuration.config.backends.stub :enabled, ['dummy_false', 'dummy_true'] do
          result.must_equal(true)
        end
      end
    end

    context "none of backends returns true" do
      it "should go through all of backends" do
        Configuration.config.backends.stub :enabled, ['dummy_false'] do
          result.must_equal(false)
        end
      end
    end

    context "wrong configuration" do
      it "should not raise any error" do
        Configuration.config.backends.stub :enabled, ['not_existing'] do
          result # won't raise any error
        end
      end
    end
  end


end