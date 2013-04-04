require 'test_helper'

describe Backends::Katello do
  let(:username) { "admin" }
  let(:password) { "admin" }
  let(:url) { "https://locahost/katello" }
  let(:user) { User.new username, password }
  let(:backend) { Backends::Katello.new }
  let(:authentication) { backend.authenticate(user) }

  describe "#authenticate" do
    describe "successful response" do
      before do
        stub_request(:get, "#{url}?password=#{password}&username=#{username}").
            to_return(:status => 200, :body => "", :headers => {})
      end
      it "returns true" do
        Configuration.config.backends.katello.stub :url, url do
          authentication.must_equal true
        end
      end
    end

    describe "negative response" do
      before do
        stub_request(:get, "#{url}?password=#{password}&username=#{username}").
            to_return(:status => 403, :body => "", :headers => {})
      end
      it "returns false" do
        Configuration.config.backends.katello.stub :url, url do
          authentication.must_equal false
        end
      end
    end
  end
end