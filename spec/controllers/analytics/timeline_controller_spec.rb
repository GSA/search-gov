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

      context "when showing a timeline" do
        before do
          DailyQueryStat.delete_all
          DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME )
          DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME )
        end

        context "when query term passed in" do
          before do
            get :show, :query => "query1"
          end

          it "should assign the timelines array, with at least one entry" do
            assigns[:timelines].should be_instance_of(Array)
            assigns[:timelines].size.should == 1
            assigns[:timelines].first.should_not be_nil
          end

          it "should assign the query term" do
            assigns[:query].should_not be_nil
          end
        end
      
        context "when a comparison query term is passed in" do
          before do
            get :show, :query => 'query1', :comparison_query => 'query2'
          end
        
          it "should assign the timelines array, with two entries" do
            assigns[:timelines].should be_instance_of(Array)
            assigns[:timelines].size.should == 2
            assigns[:timelines].first.should_not be_nil
            assigns[:timelines].last.should_not be_nil
          end
        
          it "should assign the query term and the comparison query term" do
            assigns[:query].should_not be_nil
            assigns[:query].should == 'query1'
            assigns[:comparison_query].should_not be_nil
            assigns[:comparison_query].should == 'query2'
          end
        end
      
        context "when the comparison term passed in has no data" do
          before do
            get :show, :query => 'query1', :comparison_query => 'nothing'
          end
          
          it "should return a timeline for the query value, and an empty timeline for the comparison value" do
            assigns[:timelines].should be_instance_of(Array)
            assigns[:timelines].size.should == 2
            assigns[:timelines].first.should_not be_nil
            assigns[:timelines].last.should_not be_nil
            assigns[:timelines].last.series.collect{|datum| datum.y}.uniq.size.should == 1
            assigns[:query].should_not be_nil
            assigns[:comparison_query].should_not be_nil
          end
        end
          
        context "when query group passed in" do
          before do
            qg = QueryGroup.create!(:name=>"foo")
            qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
            qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
            @timeline = Timeline.new("foo", "1")
          end

          it "should use the query group to create the timeline" do
            Timeline.should_receive(:new).with("foo", "1").and_return @timeline
            get :show, :query => "foo", :grouped => 1
          end

          it "should assign the query group" do
            get :show, :query=>"foo", :grouped=>1
            assigns[:query_group].name.should == "foo"
          end
        end
      end
    end
  end
end
