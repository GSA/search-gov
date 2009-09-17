require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::TimelineController do

  describe "#show" do

    describe "- route generation" do
      it "should map { :controller => 'analytics/timeline', :action => 'show', :query=>'foo.com 9/11' } to /analytics/timeline/foo.com%209%2F11" do
        route_for(:controller => "analytics/timeline", :action => "show", :query=>"foo.com 9/11").should == "/analytics/timeline/foo.com%209%2F11"
      end

      it "should map { :controller => 'analytics/timeline', :action => 'show', :query=>'9/11' } to /analytics/timeline/9%2F11" do
        route_for(:controller => "analytics/timeline", :action => "show", :query=>"9/11").should == "/analytics/timeline/9%2F11"
      end
    end

    describe "- route recognition" do
      it "should generate params { :controller => 'analytics/timeline', :action => 'show', :query=>'foo.com 9/11'  } from GET /analytics/timeline/foo.com%209%2F11" do
        params_from(:get, "/analytics/timeline/foo.com%209%2F11").should == { :controller => 'analytics/timeline', :action => 'show', :query=>'foo.com 9/11'  }
      end

      it "should generate params { :controller => 'analytics/timeline', :action => 'show', :query=>'9/11'  } from GET /analytics/timeline/9%2F11" do
        params_from(:get, "/analytics/timeline/9%2F11").should == { :controller => 'analytics/timeline', :action => 'show', :query=>'9/11'  }
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
