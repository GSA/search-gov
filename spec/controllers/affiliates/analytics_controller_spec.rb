require 'spec/spec_helper'

describe Affiliates::AnalyticsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "query search dates" do
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
      end

      it "should assign reasonable defaults for start/end dates" do
        get :index, :affiliate_id => @user.affiliates.first.id
        assigns[:start_date].should == 1.month.ago.to_date
        assigns[:end_date].should == Date.yesterday.to_date
      end

      it "should assign start/end dates from params" do
        get :query_search, :affiliate_id => @user.affiliates.first.id,
            :analytics_search_start_date=>"November 10, 2010",
            :analytics_search_end_date=>"November 20, 2010",
            :query => "foo"
        assigns[:start_date].should == Date.parse("November 10, 2010")
        assigns[:end_date].should == Date.parse("November 20, 2010")
      end
    end
  end

  describe "#analytics" do
    context "when requesting analytics for an affiliate" do
      before do
        @affiliate = affiliates("basic_affiliate")
      end

      context "when not logged in" do
        it "should redirect to the home page" do
          get :index, :affiliate_id => @affiliate.id
          response.should redirect_to login_path
        end
      end

      context "when logged in as a user that is neither an affiliate or an admin" do
        before do
          @user = users("non_affiliate_admin")
          UserSession.create(@user)
        end

        it "should redirect to the home page" do
          get :index, :affiliate_id => @affiliate.id
          response.should redirect_to(home_page_path)
        end
      end

      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          UserSession.create(@user)
          @admin_affiliate = affiliates("admin_affiliate")
        end

        it "should allow the admin to view analytics for his own affiliate" do
          get :index, :affiliate_id => @admin_affiliate.id
          response.should be_success
        end

        it "should allow the admin to view analytics for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :index, :affiliate_id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end

      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end
        
        it "should assign the page title" do
          get :index, :affiliate_id => @user.affiliates.first.id
          assigns[:title].should == "Query Logs - "
        end

        it "should allow the affiliate to view his own analytics" do
          get :index, :affiliate_id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end

        it "should not allow the affiliate to view analytics for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :index, :affiliate_id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end

        it "should show most recent populated data if params[:day] is blank" do
          day_being_shown = Date.current
          DailyQueryStat.should_receive(:most_recent_populated_date).and_return(day_being_shown)
          get :index, :affiliate_id => @user.affiliates.first.id, :day => ''
          assigns[:day_being_shown].should == day_being_shown
        end

        context "when rendering the page" do
          render_views
          before do
            AWS::S3::Base.stub!(:establish_connection!).and_return true
          end

          it "should display the affiliate name" do
            get :index, :affiliate_id => @user.affiliates.first.id
            response.should contain(/#{@user.affiliates.first.display_name}/)
          end

          it "should establish an AWS connection" do
            AWS::S3::Base.should_receive(:establish_connection!).once
            get :index, :affiliate_id => @user.affiliates.first.id
          end

          it "should not link to the reports if there's no data" do
            AWS::S3::S3Object.should_not_receive(:url_for)
            get :index, :affiliate_id => @user.affiliates.first.id
          end

          context "when there is affiliate data" do
            before do
              DailyQueryStat.create(:query => 'test', :times => 12, :affiliate => @user.affiliates.first.name, :day => Date.yesterday, :locale => "en")
              @filename = "analytics/reports/#{@user.affiliates.first.name}/#{@user.affiliates.first.name}_top_queries_#{DailyQueryStat.most_recent_populated_date(@user.affiliates.first.name).strftime('%Y%m%d')}.csv"
            end

            it "should link to the report on Amazon using S3/SSL if it exists" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return true
              AWS::S3::S3Object.should_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
              get :index, :affiliate_id => @user.affiliates.first.id
              response.body.should contain(/Download top queries for #{Date.yesterday.to_s}/)
            end

            it "should not link to the report on Amazon if the file is not found" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return false
              AWS::S3::S3Object.should_not_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true)
              get :index, :affiliate_id => @user.affiliates.first.id
              response.body.should_not contain(/Download top queries for #{Date.yesterday.to_s}/)
            end
          end
        end
      end
    end
  end

  describe "#monthly_reports" do
    context "when requesting monthly reports for an affiliate" do
      before do
        @affiliate = affiliates("basic_affiliate")
      end

      context "when not logged in" do
        it "should redirect to the home page" do
          get :monthly_reports, :affiliate_id => @affiliate.id
          response.should redirect_to login_path
        end
      end

      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          @user.affiliates << @affiliate
          UserSession.create(@user)
        end

        it "should allow the admin to view monthly reports for his own affiliate" do
          get :monthly_reports, :affiliate_id => @user.affiliates.first.id
          response.should be_success
        end

        it "should allow the admin to view monthly reports for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :monthly_reports, :affiliate_id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end

      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end
        
        it "should assign the page title" do
          get :monthly_reports, :affiliate_id => @user.affiliates.first.id
          assigns[:title].should == "Monthly Reports - "
        end

        it "should allow the affiliate to view his own monthly reports" do
          get :monthly_reports, :affiliate_id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end

        it "should not allow the affiliate to view monthly reports for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :monthly_reports, :affiliate_id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end

        it "should assign @total_clicks" do
          Click.should_receive(:monthly_totals_for_affiliate).and_return(100)
          get :monthly_reports, :affiliate_id => @user.affiliates.first.id
          assigns[:total_clicks].should == 100
        end

        context "when rendering the page" do
          render_views
          before do
            AWS::S3::Base.stub!(:establish_connection!).and_return true
            @report_date = Date.yesterday
          end

          it "should display the affiliate name" do
            get :monthly_reports, :affiliate_id => @user.affiliates.first.id
            response.should contain(/#{@user.affiliates.first.display_name}/)
          end

          it "should establish an AWS connection" do
            AWS::S3::Base.should_receive(:establish_connection!).once
            get :monthly_reports, :affiliate_id => @user.affiliates.first.id
          end

          context "when displaying the monthly reports" do
            before do
              @filename = "analytics/reports/#{@user.affiliates.first.name}/#{@user.affiliates.first.name}_top_queries_#{@report_date.strftime('%Y%m')}.csv"
            end

            it "should link to the report on Amazon using S3/SSL if the report exists on S3" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return true
              AWS::S3::S3Object.should_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
              get :monthly_reports, :affiliate_id => @user.affiliates.first.id
              response.body.should contain(/Download top queries for #{Date::MONTHNAMES[@report_date.month.to_i]} #{@report_date.year}/)
            end

            it "should not link to the report on Amazon if the file does not exist on S3" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return false
              AWS::S3::S3Object.should_not_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true)
              get :monthly_reports, :affiliate_id => @user.affiliates.first.id
              response.body.should_not contain(/Download top queries for #{Date::MONTHNAMES[@report_date.month.to_i]} #{@report_date.year}/)
            end
          end
        end
      end
    end
  end
end
