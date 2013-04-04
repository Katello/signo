require 'test_helper'

describe Backends::Ldap do
  let(:username) { "admin" }
  let(:password) { "admin" }
  let(:user) { User.new username, password }
  let(:backend) { Backends::Ldap.new }
  let(:authentication) { backend.authenticate(user) }

  describe "#authenticate" do
    describe "successful response" do
      it "returns true" do
        backend.stub :do_auth, true do
          backend.instance_variable_set :@result, true
          authentication.must_equal true
        end
      end
    end

    describe "negative response" do
      it "returns false" do
        backend.stub :do_auth, false do
          backend.instance_variable_set :@result, false
          authentication.must_equal false
        end
      end
    end
  end
end