require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::TimelineController do
  fixtures :users

  context "when logged in as an analyst" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("analyst").email, :password => "admin")
    end

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
          params_from(:get, "/analytics/timeline/foo.com%209%2F11").should == { :controller => 'analytics/timeline', :action => 'show', :query=>'foo.com 9/11' }
        end

        it "should generate params { :controller => 'analytics/timeline', :action => 'show', :query=>'9/11', :grouped=>'1'  } from GET /analytics/timeline/9%2F11?grouped=1" do
          params_from(:get, "/analytics/timeline/9%2F11?grouped=1").should == { :controller => 'analytics/timeline', :action => 'show', :query=>'9/11', :grouped=>'1' }
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

      context "when query group passed in" do
        before do
          DailyQueryStat.delete_all
          DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME )
          DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME )
          qg = QueryGroup.create!(:name=>"foo")
          qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
          qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
        end

        it "should use the query group to create the timeline" do
          timeline = Timeline.new("foo", "1")
          Timeline.should_receive(:new).with("foo", "1").and_return(timeline)
          get :show, :query=>"foo", :grouped=>1
        end

        it "should assign the query group" do
          get :show, :query=>"foo", :grouped=>1
          assigns[:query_group].name.should == "foo"
        end
      end

    end
  end
end
