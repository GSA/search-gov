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
        get :trending_searches, :widget_source => 'usa.gov'
      end

      it { should assign_to(:active_top_searches).with(active_top_searches) }
      it { should assign_to(:widget_source).with('usa.gov') }
      it { should respond_with_content_type :html }
      it { should respond_with :success }
    end

    context "when format=xml and widget_source is blank" do
      before do
        get :trending_searches, :format => 'xml'
      end

      it { should assign_to(:active_top_searches).with(active_top_searches) }
      it { should assign_to(:widget_source).with('xml') }
      it { should respond_with_content_type :xml }
      it { should respond_with :success }
    end

    context "when format=xml and widget source is not blank" do
      before do
        get :trending_searches, :format => 'xml', :widget_source => 'agency'
      end

      it { should assign_to(:active_top_searches).with(active_top_searches) }
      it { should assign_to(:widget_source).with('agency') }
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

