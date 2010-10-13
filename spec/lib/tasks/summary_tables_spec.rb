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
      Query.delete_all # it's a MyISAM table with no transactions, so records accrue and need pruning
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

      context "when searches are 'enter keywords', 'cheesewiz', 'cheeseman', 'clusty' ,' ', '1', or 'test'" do
        before do
          @terms= ['enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test']
          @terms.each { |term| Query.create!(@valid_attributes.merge(:query=>term)) }
        end

        it "should ignore them" do
          @rake[@task_name].invoke
          @terms.each { |term| DailyQueryIpStat.find_by_query(term).should be_nil }
        end
      end

      context "when searches are from 192.107.175.226, 74.52.58.146 , 208.110.142.80 , or 66.231.180.169" do
        before do
          @ips= ["192.107.175.226", "74.52.58.146", "208.110.142.80", "66.231.180.169"]
          @ips.each { |ip| Query.create!(@valid_attributes.merge(:ipaddr=>ip)) }
        end

        it "should ignore them" do
          @rake[@task_name].invoke
          @ips.each { |ip| DailyQueryIpStat.find_by_ipaddr(ip).should be_nil }
        end
      end

      context "when searches are not from usasearch.gov affiliate" do
        before do
          Query.create!(@valid_attributes.merge(:affiliate => "dont ignore me", :query=>"do not ignore me"))
        end

        it "should not ignore them" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("do not ignore me").should_not be_nil
        end
      end

      context "when search are not from a known bot" do
        before do
          Query.create!(@valid_attributes.merge(:is_bot => false, :query => 'not a bot'))
        end

        it "should include it in the calculation" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("not a bot").should_not be_nil
        end
      end

      context "when searches are from a marked as being from a bot" do
        before do
          Query.create!(@valid_attributes.merge(:is_bot => true, :query => 'bot'))
        end

        it "should ingore them" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("bot").should be_nil
        end
      end

      context "when searches do not have an is_bot value" do
        before do
          Query.create!(@valid_attributes.merge(:is_bot => nil, :query => 'nil bot'))
        end

        it "should include it in the calculation" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("nil bot").should_not be_nil
        end
      end

      context "when queries are marked as not being contextual" do
        before do
          Query.create!(@valid_attributes.merge(:query => "I'm not contextual!", :is_contextual => false))
        end

        it "should include those queries in the calculations" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("I'm not contextual!").should_not be_nil
        end
      end

      context "when queries are marked as being contextual" do
        before do
          Query.create!(@valid_attributes.merge(:query => "I'm contextual!", :is_contextual => true))
        end

        it "should not be included in the calculation" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_query("I'm contextual!").should be_nil
        end
      end

      context "when there are queries from both the English and the Spanish site with the same IP address" do
        before do
          Query.create!(@valid_attributes)
          Query.create!(@valid_attributes.merge(:locale => 'es'))
        end

        it "should count them as separate IP stats" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_all_by_query("passport").size.should == 2
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

      context "when contextual queries exist along with non-contextual queries" do
        before do
          Query.create!(@valid_attributes.merge(:timestamp => Date.yesterday.to_time))
          Query.create!(@valid_attributes.merge(:timestamp => Date.yesterday.to_time, :is_contextual => true))
        end

        it "should not include the contextual links in the calculations" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_all_by_day(Date.yesterday).size.should == 1
        end
      end
    end

    describe "usasearch:daily_query_ip_stats:compute_affiliate" do
      before do
        @task_name = "usasearch:daily_query_ip_stats:compute_affiliates"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when query data exists for multiple days" do
        before do
          Query.create!(@valid_attributes.merge(:timestamp=>Date.yesterday.to_time, :affiliate => 'affiliate.gov'))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.today.to_time, :affiliate => 'affiliate.gov'))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.tomorrow.to_time, :affiliate => 'affiliate.gov'))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.yesterday.to_time))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.today.to_time))
          Query.create!(@valid_attributes.merge(:timestamp=>Date.tomorrow.to_time))
        end

        it "should populate daily_query_ip_stats from queries table for a given day" do
          @rake[@task_name].invoke(Date.today.to_s(:number))
          DailyQueryIpStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'affiliate.gov']).should_not be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
        end

        it "should default to yesterday" do
          @rake[@task_name].invoke
          DailyQueryIpStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).should_not be_nil
          DailyQueryIpStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryIpStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
        end

        context "when contextual queries exist" do
          before do
            Query.create!(@valid_attributes.merge(:timestamp => Date.yesterday.to_time, :affiliate => 'affiliate.gov', :is_contextual => true))
          end

          it "should not include the contextual queries in the calculations" do
            @rake[@task_name].invoke
            DailyQueryIpStat.find_all_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).size.should == 1
          end
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
        :query => "obama",
        :affiliate => "usasearch.gov",
        :ipaddr => first_ip,
        :timestamp => first_time,
        :locale => I18n.default_locale.to_s
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
          Query.count(:conditions => "query = 'obama'").should == 11
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'obama'")
          total.should == 11
          uips = DailyQueryIpStat.count(:ipaddr, :distinct=>true, :conditions=> "query = 'obama'")
          proportion = uips.to_f / total
          proportion.should > 0.10
        end

        it "should populate daily_query_stats based on distinct IP's from queries & daily_queries_ip_stats tables" do
          @rake[@task_name].invoke
          DailyQueryStat.sum(:times, :conditions=> "query = 'obama'").should == 6
          DailyQueryStat.count(:conditions => "query = 'obama'").should == 6
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
          Query.count(:conditions => "query = 'obama'").should == 9
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'obama'")
          total.should == 9
        end

        it "should not show up in the DailyQueryStat table" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_query('obama').should be_nil
        end
      end

      context "when the proportion of requesting IP's to total requests is 0.10 or less" do
        before do
          first_time = @valid_attributes[:timestamp]
          11.times do
            first_time += 1.day
            Query.create!(@valid_attributes.merge(:timestamp => first_time))
          end

          Query.count(:conditions => "query = 'obama'").should == 11
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          total= DailyQueryIpStat.sum(:times, :conditions=> "query = 'obama'")
          total.should == 11
          uips = DailyQueryIpStat.count(:ipaddr, :distinct=>true, :conditions=> "query = 'obama'")
          proportion = uips.to_f / total
          proportion.should <= 0.10
        end

        it "should not show up in the DailyQueryStat table" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_query('obama').should be_nil
        end
      end

      context "when query and daily ip stats are present for the default site (usasearch.gov) and other affiliates" do
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
          10.times do
            first_time += 1.day
            first_ip.succ!
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time, :affiliate => 'test.gov'))
            Query.create!(@valid_attributes.merge(:ipaddr=>first_ip, :timestamp => first_time + 1.minute, :affiliate => 'test.gov'))
          end
          Query.create!(@valid_attributes.merge(:ipaddr=>"9.8.7.6", :timestamp => Date.yesterday.to_time, :affiliate => 'test.gov'))
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          default_affiliate_total = DailyQueryIpStat.sum(:times, :conditions=> "query = 'obama' AND affiliate = 'usasearch.gov'")
          test_affiliate_total = DailyQueryIpStat.sum(:times, :conditions=> "query = 'obama' AND affiliate = 'test.gov'")
          default_affiliate_total.should == 11
          test_affiliate_total.should == 21
        end

        it "should calculate the sums separately by affiliate" do
          @rake[@task_name].invoke
          DailyQueryStat.find_all_by_affiliate(Affiliate::USAGOV_AFFILIATE_NAME).should_not be_nil
          DailyQueryStat.find_all_by_affiliate('test.gov').should_not be_nil
        end
      end

      context "when query and daily ip stats are present for the English and Spanish locales" do
        before do
          @first_time = @valid_attributes[:timestamp]
          @first_ip = @valid_attributes[:ipaddr]
          6.times do
            @first_time += 1.day
            @first_ip.succ!
            Query.create!(@valid_attributes.merge(:ipaddr => @first_ip, :timestamp => @first_time))
            Query.create!(@valid_attributes.merge(:ipaddr => @first_ip, :timestamp => @first_time + 1.minute))
          end
          Query.create!(@valid_attributes.merge(:ipaddr => "9.8.7.6", :timestamp => Date.yesterday.to_time))
          7.times do
            @first_time += 1.day
            @first_ip.succ!
            Query.create!(@valid_attributes.merge(:ipaddr => @first_ip, :timestamp => @first_time, :locale => 'es'))
            Query.create!(@valid_attributes.merge(:ipaddr => @first_ip, :timestamp => @first_time + 1.minute, :locale => 'es'))
          end
          Query.create!(@valid_attributes.merge(:ipaddr => "9.8.7.6", :timestamp => Date.yesterday.to_time, :locale => 'es'))
          @rake["usasearch:daily_query_ip_stats:populate"].invoke
          english_locale_total = DailyQueryIpStat.sum(:times, :conditions => "query = 'obama' AND locale = 'en'")
          spanish_locale_total = DailyQueryIpStat.sum(:times, :conditions => "query = 'obama' AND locale = 'es'")
          english_locale_total.should == 13
          spanish_locale_total.should == 15
        end

        it "should calculate the sums separately for each locale" do
          @rake[@task_name].invoke
          DailyQueryStat.find_all_by_locale('en').should_not be_nil
          DailyQueryStat.find_all_by_locale('es').should_not be_nil
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

      context "when calculating daily_query_stats for a single day for usasearch.gov and affiliates" do
        before do
          DailyQueryIpStat.delete_all
          DailyQueryStat.delete_all
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '1.2.3.4', :affiliate => 'usasearch.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '2.3.4.5', :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '3.4.5.6', :affiliate => 'another_affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '11.2.3.4', :affiliate => 'usasearch.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '12.3.4.5', :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '13.4.5.6', :affiliate => 'another_affiliate.gov')
        end

        it "should populate daily_query_stats for each affiliate according to the number of ip addresses" do
          @rake[@task_name].invoke(Date.yesterday.to_s(:number))
          DailyQueryStat.all.size.should > 0
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).times.should == 2
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).times.should == 2
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'another_affiliate.gov']).times.should == 2
        end
      end

      context "when calculating daily_query_stats for a single day for usasearch.gov for both spanish and english sites" do
        before do
          DailyQueryIpStat.delete_all
          DailyQueryStat.delete_all
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '1.2.3.4', :affiliate => 'usasearch.gov', :locale => 'en')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '2.3.4.5', :affiliate => 'usasearch.gov', :locale => 'es')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '11.2.3.4', :affiliate => 'usasearch.gov', :locale => 'en')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '12.3.4.5', :affiliate => 'usasearch.gov', :locale => 'es')
        end

        it "should populate daily_query_stats for each locale according to the number of IP addresses" do
          @rake[@task_name].invoke(Date.yesterday.to_s(:number))
          DailyQueryStat.all.size.should > 0
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['locale = ?', 'en']).times.should == 2
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['locale = ?', 'es']).times.should == 2
        end
      end
    end

    describe "usasearch:daily_query_stats:compute_affiliates" do
      before do
        @task_name = "usasearch:daily_query_stats:compute_affiliates"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when query data and DailyQueryIpStats data exists for multiple days" do
        before do
          DailyQueryIpStat.delete_all
          DailyQueryStat.delete_all
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr], :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.today, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!, :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.tomorrow, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!, :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr])
          DailyQueryIpStat.create!(:day => Date.today, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!)
          DailyQueryIpStat.create!(:day => Date.tomorrow, :times => 4, :query => @valid_attributes[:query], :ipaddr => @valid_attributes[:ipaddr].succ!)
        end

        it "should populate daily_query_stats from queries table for a given day" do
          @rake[@task_name].invoke(Date.today.to_s(:number))
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'affiliate.gov']).should_not be_nil
          DailyQueryStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
        end

        it "should default to yesterday" do
          @rake[@task_name].invoke
          DailyQueryStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'affiliate.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).should_not be_nil
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.today, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.tomorrow, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
        end
      end

      context "when calculating daily_query_stats for a single day for usasearch.gov and affiliates" do
        before do
          DailyQueryIpStat.delete_all
          DailyQueryStat.delete_all
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '1.2.3.4', :affiliate => 'usasearch.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '2.3.4.5', :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 11, :query => 'something', :ipaddr => '3.4.5.6', :affiliate => 'another_affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '11.2.3.4', :affiliate => 'usasearch.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '12.3.4.5', :affiliate => 'affiliate.gov')
          DailyQueryIpStat.create!(:day => Date.yesterday, :times => 1, :query => 'something', :ipaddr => '13.4.5.6', :affiliate => 'another_affiliate.gov')
        end

        it "should populate daily_query_stats for each affiliate according to the number of ip addresses" do
          @rake[@task_name].invoke(Date.yesterday.to_s(:number))
          DailyQueryStat.all.size.should > 0
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'usasearch.gov']).should be_nil
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'affiliate.gov']).times.should == 2
          DailyQueryStat.find_by_day(Date.yesterday, :conditions => ['affiliate = ?', 'another_affiliate.gov']).times.should == 2
        end
      end
    end

    describe "usasearch:daily_query_stats:index_most_recent_day_stats_in_solr" do
      before do
        @task_name = "usasearch:daily_query_stats:index_most_recent_day_stats_in_solr"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when daily_query_stats data is available over some date range" do
        before do
          DailyQueryStat.delete_all
          DailyQueryStat.create!(:day => Date.yesterday, :times => 10, :query => "ignore me", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
          @first = DailyQueryStat.create!(:day => Date.today, :times => 20, :query => "index me", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
          @second = DailyQueryStat.create!(:day => Date.today, :times => 20, :query => "index me too", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        end

        it "should call Sunspot.index on the most-recently-added DailyQueryStat models" do
          Sunspot.should_receive(:index).with([@first, @second])
          @rake[@task_name].invoke
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
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME) }
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => 'affiliate.gov') }
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es') }
        end

        it "should calculate moving queries for each day in that range, ignoring affiliates and non-English locales" do
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