require File.dirname(__FILE__) + '/spec_helper'

class FakeController < ActionController::Base
  has_mobile_fu
end

describe FakeController do

  describe "#in_mobile_view?" do

    describe "with mobile format format" do
      let(:controller) { FakeController.new }
      let(:request) { mock('request', :format => :mobile) }

      before do
        controller.should_receive(:request).at_least(1).times.and_return(request)
      end

      specify { controller.should be_in_mobile_view }
    end

    describe "with non mobile format format" do
      let(:controller) { FakeController.new }
      let(:request) { mock('request', :format => 'text/html') }

      before do
        controller.should_receive(:request).at_least(1).times.and_return(request)
      end

      specify { controller.should_not be_in_mobile_view }
    end

    describe "with unspecified format" do
      let(:controller) { FakeController.new }
      let(:request) { mock('request', :format => nil) }

      before do
        controller.should_receive(:request).at_least(1).times.and_return(request)
      end

      specify { controller.should_not be_in_mobile_view }
    end
  end
end