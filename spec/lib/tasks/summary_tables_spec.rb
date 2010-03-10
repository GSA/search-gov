require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "summary_tables rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/summary_tables"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_query_ip_stats" do
    before do
      Query.delete_all  # it's a MyISAM table with no transactions, so records accrue and need pruning
      @first_time = Time.parse("1/1/2009 12:00pm")
      @first_ip = "123.456.7.1"
      @valid_attributes = {
        :query => "passport",
        :affiliate => "usasearch.gov",
        :ipaddr => @first_ip,
        :timestamp => @first_time,
        :locale => I18n.default_locale.to_s
      }

      Query.create!(@valid_attributes)
    end

    describe "usasearch:daily_query_ip_stats:populate" do
      before do
        @task_name = "usasearch:daily_query_ip_stats:populate"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should populate daily_query_ip_stats from queries table" do
        @rake[@task_name].invoke
        DailyQueryIpStat.count.should == 1
      end

      context "when query terms are uppercase" do
        before do
          Query.create!(@valid_attributes.merge(:query=>"UPPERCASE"))
        end

        it "should lowercase query terms" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("UPPERCASE").query.should == "uppercase"
        end
      end

      context "when the same IP searches on the same term twice in the same day" do
        before do
          Query.create!(@valid_attributes)
        end

        it "should have one record with a count of 2" do
          @rake[@task_name].invoke
          all = DailyQueryIpStat.all
          all.size.should == 1
          all.first.times.should == 2
        end
      end

      context "when searches are 'enter keywords', 'cheesewiz' ,'clusty' ,' ', '1', or 'test'" do
        before do
          @terms= ['enter keywords', 'cheesewiz', 'clusty', ' ', '1', 'test']
          @terms.each {|term| Query.create!(@valid_attributes.merge(:query=>term))}
        end

        it "should ignore them" do
          @rake[@task_name].invoke
          @terms.each {|term| DailyQueryIpStat.find_by_query(term).should be_nil}
        end
      end

      context "when searches are from 192.107.175.226, 74.52.58.146 , 208.110.142.80 , or 66.231.180.169" do
        before do
          @ips= ["192.107.175.226", "74.52.58.146", "208.110.142.80", "66.231.180.169"]
          @ips.each {|ip| Query.create!(@valid_attributes.merge(:ipaddr=>ip))}
        end

        it "should ignore them" do
          @rake[@task_name].invoke
          @ips.each {|ip| DailyQueryIpStat.find_by_ipaddr(ip).should be_nil}
        end
      end

      context "when searches are not from usasearch.gov affiliate" do
        before do
          Query.create!(@valid_attributes.merge(:affiliate => "ignore me", :query=>"ignore me"))
        end

        it "should ignore them" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("ignore me").should be_nil
        end
      end
    end

    describe "usasearch:daily_query_ip_stats:compute" do
      before do
        @task_name = "usasearch:daily_query_ip_stats:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when query data exists for multiple days" do
        before do
          Query.create!(@valid_attributes.merge(:timestamp=>Date.yesterday.to_time))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.today.to_time))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.tomorrow.to_time))
        end

        it "should populate daily_query_ip_stats from queries table for a given day" do
          @rake[@task_name].invoke(Date.today.to_s(:number))
          DailyQueryIpStat.find_by_day(Date.yesterday).should be_nil
          DailyQueryIpStat.find_by_day(Date.today).should_not be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow).should be_nil
        end

        it "should default to yesterday" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_day(Date.yesterday).should_not be_nil
          DailyQueryIpStat.find_by_day(Date.today).should be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow).should be_nil
        end
      end
    end
  end

  describe "usasearch:daily_query_stats" do
    before do
      Query.delete_all
      first_time = Time.parse("1/1/2009 12:00pm")
      first_ip = "123.456.7.1"
      @valid_attributes = {
        :query => "some search term",
        :affiliate => "usasearch.gov",
        :ipaddr => first_ip,
        :timestamp => first_time,
        :locale => I18n.default_locale
      }
    end

    describe "usasearch:daily_query_stats:populate" do
      before do
        @task_name = "usasearch:daily_query_stats:populate"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when sum of all historical queries for a term is more than 10 and the proportion of requesting IP's to total requests is greater than 0.10" do
        before do
          first_time = @valid_attributes[:timestamp]
          first_ip = @valid_attributes[:ipaddr]
          5.times do
            first_time += 1.day
            first_ip.succ!
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time))
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time + 1.minute))
          end

          Query.create!(@valid_attributes.merge(:ipaddr=>"9.8.7.6", :timestamp => Date.yesterday.to_time))
          Query.count(:conditions => "query = 'some search term'").should == 11
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'some search term'")
          total.should == 11
          uips = DailyQueryIpStat.count(:ipaddr, :distinct=>true, :conditions=> "query = 'some search term'")
          proportion = uips.to_f / total
          proportion.should > 0.10
        end

        it "should populate daily_query_stats based on distinct IP's from queries & daily_queries_ip_stats tables" do
          @rake[@task_name].invoke
          DailyQueryStat.sum(:times, :conditions=> "query = 'some search term'").should == 6
          DailyQueryStat.count(:conditions => "query = 'some search term'").should == 6
        end
      end

      context "when the sum of all historical queries for a term is 10 or fewer" do
        before do
          first_time = @valid_attributes[:timestamp]
          first_ip = @valid_attributes[:ipaddr]
          4.times do
            first_time += 1.day
            first_ip.succ!
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time))
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time + 1.minute))
          end

          Query.create!(@valid_attributes.merge(:ipaddr=>"9.8.7.6", :timestamp => Date.yesterday.to_time))
          Query.count(:conditions => "query = 'some search term'").should == 9
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'some search term'")
          total.should == 9
        end

        it "should not show up in the DailyQueryStat table" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_query('some search term').should be_nil
        end
      end

      context "when the proportion of requesting IP's to total requests is 0.10 or less" do
        before do
          first_time = @valid_attributes[:timestamp]
          11.times do
            first_time += 1.day
            Query.create!(@valid_attributes.merge(:timestamp => first_time))
          end

          Query.count(:conditions => "query = 'some search term'").should == 11
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'some search term'")
          total.should == 11
          uips = DailyQueryIpStat.count(:ipaddr, :distinct=>true, :conditions=> "query = 'some search term'")
          proportion = uips.to_f / total
          proportion.should <= 0.10
        end

        it "should not show up in the DailyQueryStat table" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_query('some search term').should be_nil
        end
      end
    end

    describe "usasearch:daily_query_stats:compute" do
      before do
        @task_name = "usasearch:daily_query_stats:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when query data and DailyQueryIpStats data exists for multiple days" do
        before do
          DailyQueryIpStat.delete_all
          DailyQueryStat.delete_all
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr])
          DailyQueryIpStat.create!(:day => Date.today, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!)
          DailyQueryIpStat.create!(:day => Date.tomorrow, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!)
        end

        it "should populate daily_query_stats from queries table for a given day" do
          @rake[@task_name].invoke(Date.today.to_s(:number))
          DailyQueryStat.find_by_day(Date.yesterday).should be_nil
          DailyQueryStat.find_by_day(Date.today).should_not be_nil
          DailyQueryStat.find_by_day(Date.tomorrow).should be_nil
        end

        it "should default to yesterday" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_day(Date.today).should be_nil
          DailyQueryStat.find_by_day(Date.tomorrow).should be_nil
          DailyQueryStat.find_by_day(Date.yesterday).should_not be_nil
        end
      end
    end
  end

  describe "usasearch:moving_queries" do
    describe "usasearch:moving_queries:populate" do
      before do
        @task_name = "usasearch:moving_queries:populate"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when daily_query_stats data is available over some date range" do
        before do
          DailyQueryStat.delete_all
          Date.yesterday.upto(Date.tomorrow) {|day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever") }
        end

        it "should calculate moving queries for each day in that range" do
          MovingQuery.should_receive(:compute_for).with(Date.yesterday.to_s(:number))
          MovingQuery.should_receive(:compute_for).with(Date.today.to_s(:number))
          MovingQuery.should_receive(:compute_for).with(Date.tomorrow.to_s(:number))
          @rake[@task_name].invoke
        end
      end
    end

    describe "usasearch:moving_queries:compute" do
      before do
        @task_name = "usasearch:moving_queries:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when no target date is passed in" do
        it "should default to calculating yesterday's moving queries" do
          MovingQuery.should_receive(:compute_for).once.with(Date.yesterday.to_s(:number))
          @rake[@task_name].invoke
        end
      end

      context "when target date is passed in" do
        it "should calculate moving queries for that date" do
          MovingQuery.should_receive(:compute_for).once.with(Date.today.to_s(:number))
          @rake[@task_name].invoke(Date.today.to_s(:number))
        end
      end
    end
  end
end