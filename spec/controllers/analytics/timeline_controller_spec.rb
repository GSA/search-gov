require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::TimelineController do

  describe "#show" do

    describe "- route generation" do
      it "should map { :controller => 'analytics/timeline', :action => 'show', :query=>'foo' } to /analytics/timeline/foo" do
        route_for(:controller => "analytics/timeline", :action => "show", :query=>"foo").should == "/analytics/timeline/foo"
      end
    end

    describe "- route recognition" do
      it "should generate params { :controller => 'analytics/timeline', :action => 'show', :query=>'foo'  } from GET /analytics/timeline/foo" do
        params_from(:get, "/analytics/timeline/foo").should == { :controller => 'analytics/timeline', :action => 'show', :query=>'foo'  }
      end
    end

    context "when query term passed in" do
      before do
        get :show, :query=>"foo"
      end

      it "should assign the dates array" do
        assigns[:dates].should be_instance_of(Array)
      end

      it "should assign the series data" do
        assigns[:series].should be_instance_of(Array)
      end

      it "should assign the query term" do
        assigns[:query].should_not be_nil
      end
    end

  end
end
