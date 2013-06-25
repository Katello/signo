# encoding: utf-8
require 'test_helper'

describe Url do
  let(:url) { Url.new('http://foreman.com/foreman?param=event %3D true') }

  describe "#sslize" do
    it { url.sslize.to_s.must_include('https://') }
  end

  describe "#add_username(name)" do
    it { url.add_username("ares").to_s.must_include('username=ares') }
    it { url.add_username("ářeš").to_s.must_include('username=%C3%A1%C5%99e%C5%A1') }
  end

  describe "#to_s" do
    it { url.to_s.must_equal('http://foreman.com/foreman?param=event%20%3D%20true') }
  end

end
