# encoding: UTF-8
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

    describe "wide characters in credentials" do
      let(:wide_username) { "ářěš" }
      let(:wide_password) { "šwórď" }
      before do
        stub_request(:get, "#{url}?password=#{URI.escape(wide_password)}&username=#{URI.escape(wide_username)}").
            to_return(:status => 200, :body => "", :headers => {})
      end

      it "escapes credentials" do
        Configuration.config.backends.katello.stub :url, url do
          Backends::Katello.new.authenticate(User.new(wide_username, wide_password))
        end
      end
    end
  end
end
