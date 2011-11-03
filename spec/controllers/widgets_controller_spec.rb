require 'spec/spec_helper'

describe WidgetsController do
  let(:active_top_searches) { mock('active top searches') }
  before do
    TopSearch.should_receive(:find_active_entries).and_return(active_top_searches)
  end

  describe "#top_searches" do
    it "should assign the top searches to the top 5 positions" do
      get :top_searches
      assigns[:active_top_searches].should == active_top_searches
    end
  end

  describe "#trending_searches" do
    context "when format=html" do
      before do
        get :trending_searches
      end

      it { assign_to(:active_top_searches).with(active_top_searches) }
      it { should respond_with_content_type :html }
      it { should respond_with :success }
    end

    context "when format=xml" do
      before do
        get :trending_searches, :format => 'xml'
      end

      it { assign_to(:active_top_searches).with(active_top_searches) }
      it { should respond_with_content_type :xml }
      it { should respond_with :success }
    end

    context "when format=json" do
      before do
        get :trending_searches, :format => 'json'
      end

      it { should respond_with :not_acceptable }
    end
  end
end

