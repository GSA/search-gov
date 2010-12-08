require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliatesController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #index" do
    it "should not require affiliate login" do
      get :index
      response.should be_success
    end
  end

  describe "do GET on #edit" do
    it "should require affiliate login for edit" do
      get :edit, :id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for edit" do
        get :edit, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end
  end

  describe "do POST on #update" do
    it "should require affiliate login for update" do
      post :update, :id => affiliates(:power_affiliate).id, :affiliate=> {}
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        @affiliate = user.affiliates.first
      end

      it "should update the Affiliate" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"NEWNAME", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        @affiliate.reload
        @affiliate.name.should == "NEWNAME"
        @affiliate.footer.should == "BAR"
        @affiliate.header.should == "FOO"
        @affiliate.domains.should == "BLAT"
      end

      it "should redirect to affiliates home on success with flash message" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"NEWNAME", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should redirect_to(home_affiliates_path(:said=>@affiliate.id))
        flash[:success].should_not be_nil
      end

      it "should render edit on failure" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should render_template(:edit)
      end
    end
  end

  describe "query search dates" do
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
      end

      it "should assign reasonable defaults for start/end dates" do
        get :analytics, :id => @user.affiliates.first.id
        assigns[:start_date].should == 1.month.ago.to_date
        assigns[:end_date].should == Date.yesterday.to_date
      end

      it "should assign start/end dates from params" do
        get :query_search, :id => @user.affiliates.first.id,
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
          get :analytics, :id => @affiliate.id
          response.should redirect_to new_user_session_path
        end
      end

      context "when logged in as a user that is neither an affiliate or an admin" do
        before do
          @user = users("non_affiliate_admin")
          UserSession.create(@user)
        end

        it "should redirect to the home page" do
          get :analytics, :id => @affiliate.id
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
          get :analytics, :id => @admin_affiliate.id
          response.should be_success
        end

        it "should allow the admin to view analytics for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :analytics, :id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end

      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end

        it "should allow the affiliate to view his own analytics" do
          get :analytics, :id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end

        it "should not allow the affiliate to view analytics for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :analytics, :id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end

        context "when rendering the page" do
          integrate_views
          before do
            AWS::S3::Base.stub!(:establish_connection!).and_return true
          end

          it "should display the affiliate name" do
            get :analytics, :id => @user.affiliates.first.id
            response.should contain(/#{@user.affiliates.first.name}/)
          end

          it "should establish an AWS connection" do
            AWS::S3::Base.should_receive(:establish_connection!).once
            get :analytics, :id => @user.affiliates.first.id
          end

          it "should not link to the reports if there's no data" do
            AWS::S3::S3Object.should_not_receive(:url_for)
            get :analytics, :id => @user.affiliates.first.id
          end

          context "when there is affiliate data" do
            before do
              DailyQueryStat.create(:query => 'test', :times => 12, :affiliate => @user.affiliates.first.name, :day => Date.yesterday, :locale => "en")
              @filename = "reports/#{@user.affiliates.first.name}_top_queries_#{DailyQueryStat.most_recent_populated_date(@user.affiliates.first.name).strftime('%Y%m%d')}.csv"
            end

            it "should link to the report on Amazon using S3/SSL if it exists" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return true
              AWS::S3::S3Object.should_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
              get :analytics, :id => @user.affiliates.first.id
              response.body.should contain(/Download top queries for #{Date.yesterday.to_s}/)
            end

            it "should not link to the report on Amazon if the file is not found" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return false
              AWS::S3::S3Object.should_not_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true)
              get :analytics, :id => @user.affiliates.first.id
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
          get :monthly_reports, :id => @affiliate.id
          response.should redirect_to new_user_session_path
        end
      end

      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          @user.affiliates << @affiliate
          UserSession.create(@user)
        end

        it "should allow the admin to view monthly reports for his own affiliate" do
          get :monthly_reports, :id => @user.affiliates.first.id
          response.should be_success
        end

        it "should allow the admin to view monthly reports for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :monthly_reports, :id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end

      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end

        it "should allow the affiliate to view his own monthly reports" do
          get :monthly_reports, :id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end

        it "should not allow the affiliate to view monthly reports for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :monthly_reports, :id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end

        context "when rendering the page" do
          integrate_views
          before do
            AWS::S3::Base.stub!(:establish_connection!).and_return true
            @report_date = Date.yesterday
          end

          it "should display the affiliate name" do
            get :monthly_reports, :id => @user.affiliates.first.id
            response.should contain(/#{@user.affiliates.first.name}/)
          end

          it "should establish an AWS connection" do
            AWS::S3::Base.should_receive(:establish_connection!).once
            get :monthly_reports, :id => @user.affiliates.first.id
          end

          context "when displaying the monthly reports" do
            before do
              @filename = "reports/#{@user.affiliates.first.name}_top_queries_#{@report_date.strftime('%Y%m')}.csv"
            end

            it "should link to the report on Amazon using S3/SSL if the report exists on S3" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return true
              AWS::S3::S3Object.should_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true).once.and_return ""
              get :monthly_reports, :id => @user.affiliates.first.id
              response.body.should contain(/Download top queries for #{Date::MONTHNAMES[@report_date.month.to_i]} #{@report_date.year}/)
            end

            it "should not link to the report on Amazon if the file does not exist on S3" do
              AWS::S3::S3Object.should_receive(:exists?).with(@filename, AWS_BUCKET_NAME).and_return false
              AWS::S3::S3Object.should_not_receive(:url_for).with(@filename, AWS_BUCKET_NAME, :use_ssl => true)
              get :monthly_reports, :id => @user.affiliates.first.id
              response.body.should_not contain(/Download top queries for #{Date::MONTHNAMES[@report_date.month.to_i]} #{@report_date.year}/)
            end
          end
        end
      end
    end
  end
end
