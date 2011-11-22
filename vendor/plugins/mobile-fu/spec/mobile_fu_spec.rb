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

  describe "#is_mobile_device?" do
    ['Mozilla/5.0 (iPad; U; CPU OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5',
     'Mozilla/5.0 (Linux; U; Android 3.2.1; en-us; Xoom Build/HTK55D) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13'].each do |user_agent|
      describe "with request from tablet device" do
        let(:controller) { FakeController.new }
        let(:request) { mock('request', :user_agent => user_agent) }

        before do
          controller.should_receive(:request).at_least(1).times.and_return(request)
        end

        specify { controller.should_not be_is_mobile_device }
      end
    end

    ['Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5',
     'Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; Nexus One Build/GRJ22) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'].each do |user_agent|
      describe "with request from mobile device" do
        let(:controller) { FakeController.new }
        let(:request) { mock('request', :user_agent => user_agent) }

        before do
          controller.should_receive(:request).at_least(1).times.and_return(request)
        end

        specify { controller.should be_is_mobile_device }
      end
    end
  end
end
