require 'test_helper'

describe User do
  let(:user) { User.new('admin', 'admin') }

  describe "#authenticate" do
    it "respects Backends::Base" do
      [true, false].each do |bool|
        Backends::Base.stub(:authenticate, bool) do
          user.authenticate.must_equal(bool)
        end
      end
    end
  end

end