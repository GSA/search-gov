require "#{File.dirname(__FILE__)}/../spec_helper"
describe LogFile do
  fixtures :log_files

  should_validate_presence_of :name
  should_validate_uniqueness_of :name

  describe "#process(logfilename)" do
    it "should check to see if the file has already been processed" do
      filename = "/tmp/foo"
      File.open(filename, "w+") {|file| file.write("hello")}
      LogFile.should_receive(:find_by_name).with("foo").and_return(true)
      LogFile.process(filename)
      FileUtils.rm filename
    end

    context "when the log file has not already been processed" do
      before do
        raw_entries = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:26 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
143.81.248.54 - - [08/Oct/2009:02:02:27 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
143.81.248.55 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @log_entries = raw_entries.split("\n")
        @logfile = "/tmp/2009-09-18-cf26.log"
        file = File.new(@logfile, "w+")
        @log_entries.each {|log_entry| file.puts(log_entry) }
        file.close
      end

      it "should open the file with the given parameter name" do
        File.should_receive(:open).with(@logfile)
        LogFile.process(@logfile)
      end

      it "should parse each line in the file" do
        LogFile.should_receive(:parse_line).exactly(@log_entries.size).times
        LogFile.process(@logfile)
      end

      it "should mark the file as processed" do
        LogFile.should_receive(:create!).with(:name=>"2009-09-18-cf26.log")
        LogFile.process(@logfile)
      end

      context "when there is an error in parsing a log entry in the file" do
        before do
          file = File.open(@logfile, "w+") {|file| file.puts("nonsense line")}
        end

        it "should skip the line and proceed" do
          LogFile.process(@logfile)
        end
      end

      after do
        FileUtils.rm(@logfile)
      end
    end

    context "when file has already been processed" do
      before do
        @logfile = "some log file"
        LogFile.create(:name => @logfile)
      end

      it "should not load log entries from file" do
        LogFile.should_not_receive(:parse_line)
        LogFile.process(@logfile)
      end
    end

  end

  describe "#parse_line(log_entry)" do
    context "when log entry is well-formed" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with the necessary parameters" do
        Query.should_receive(:create!).with(:query=>"delinquent delivery plus&more",
                                            :affiliate => "acqnet.gov_far_current",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when log entry query string begins with affiliate parameter" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?affiliate=parseme&input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with the necessary parameters" do
        Query.should_receive(:create!).with(:query=>"delinquent delivery",
                                            :affiliate => "parseme",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when log entry contains query with apostrophe" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=car%27s&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with the apostrophe in the query" do
        Query.should_receive(:create!).with(:query=>"car's",
                                            :affiliate => "acqnet.gov_far_current",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when log entry contains leading or traling spaces" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=%20car%20&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with the leading and trailing spaces trimmed" do
        Query.should_receive(:create!).with(:query=>"car",
                                            :affiliate => "acqnet.gov_far_current",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when query is nil (e.g., '&y=12&query=&x=12')" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      it "should create a Query record with a blank string for the query" do
        Query.should_receive(:create!).with(:query => "",
                                            :affiliate => "acqnet.gov_far_current",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when affiliate is nil (e.g., '&y=12&affiliate=&x=12')" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=foo&affiliate=&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      it "should create a Query record with affiliate=usasearch.gov for the query" do
        Query.should_receive(:create!).with(:query => "foo",
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when request contains 'noquery' parameter" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=foo&affiliate=acqnet.gov_far_current&noquery=&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      it "should not create a Query record" do
        Query.should_not_receive(:create!)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when query param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&affiliate=acqnet.gov_far_current&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should not create a Query record" do
        Query.should_not_receive(:create!)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when affiliate param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with affiliate = usasearch.gov" do
        Query.should_receive(:create!).with(:query => "delinquent delivery",
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => "143.81.248.53",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when log entry contains lots of URL encoded characters" do
      before do
        @log_entry = <<'EOF'
155.82.73.253 - - [30/Jan/2009:13:49:50 -0600] "GET /search?v%3Asources=firstgov-search-select&sitelimit=www.usace.army.mil&Submit=Go&v%3Aproject=firstgov&query=d%27kc%22z%27gj%27%22%2A%2A5%2A%28%28%28%3B-%2A%60%29&input-form=simple-firstgov HTTP/1.1" 200 60322 "-" "w3af.sourceforge.net" cf29.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("30/Jan/2009 13:49:50 -0600").utc
      end

      it "should create a Query record with the necessary parameters" do
        Query.should_receive(:create!).with(:query=>"d'kc\"z'gj'\"**5*(((;-*`)",
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => "155.82.73.253",
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "w3af.sourceforge.net",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end
    
    context "when locale param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF        
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      
      it "should create a Query record with the default locale" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => I18n.default_locale.to_s,
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end
    
    context "when English local param is present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=en HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with the English locale identifier" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => 'en',
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end
      
    context "when Spanish local param is present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      
      it "should create a Query record with the Spanish locale identifier" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => 'es',
                                            :agent => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end

    context "when the User Agent is blank" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end
      
      it "should create a Query record with the Spanish locale identifier" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => 'es',
                                            :agent => '',
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end
    
    context "when the user agent is not a bot" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with is_bot set to false" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => 'es',
                                            :agent => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
                                            :is_bot => false)
        LogFile.parse_line(@log_entry)
      end
    end
    
    context "when the user agent matches a known bot user agent" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=acqnet.gov_far_current&x=44&y=18" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" cf28.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("08/Oct/2009 02:02:28 -0500").utc
      end

      it "should create a Query record with is_bot set to true" do
        Query.should_receive(:create!).with(:query => 'obama',
                                            :affiliate => "usasearch.gov",
                                            :ipaddr => '143.81.248.53',
                                            :timestamp => @timestamp_utc,
                                            :locale => 'es',
                                            :agent => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
                                            :is_bot => true)
        LogFile.parse_line(@log_entry)
      end
    end
  end

  describe "#process_clicks(logfilename)" do
    before do
      raw_entries = <<'EOF'
      98.233.40.157 - - [15/Jan/2010:12:25:42 -0500] "GET /javascript/firstgov/dw_scrollObj.js HTTP/1.1" 200 3246 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com -
      98.233.40.157 - - [15/Jan/2010:12:25:42 -0500] "GET /javascript/firstgov/dw_hoverscroll.js HTTP/1.1" 200 4406 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com -
      98.233.40.157 - - [15/Jan/2010:12:25:42 -0500] "GET /javascript/firstgov/dw_slidebar.js HTTP/1.1" 200 4664 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com -
      98.233.40.157 - - [15/Jan/2010:12:25:42 -0500] "GET /javascript/firstgov/dw_scroll_aux.js HTTP/1.1" 200 5056 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com -
      98.233.40.157 - - [15/Jan/2010:12:25:42 -0500] "GET /javascript/firstgov/dw_event.js HTTP/1.1" 200 1240 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com -
      98.233.40.157 - - [15/Jan/2010:12:25:39 -0500] "GET /search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0 HTTP/1.1" 200 22379 "http://usasearch.gov/" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
      98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.gov%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444& HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
      @log_entries = raw_entries.split("\n")
      @logfile = "/tmp/2010-01-20-cf26.log"
      file = File.new(@logfile, "w+")
      @log_entries.each {|log_entry| file.puts(log_entry) }
      file.close
    end
    
    it "should open the file with the given parameter name" do
      File.should_receive(:open).with(@logfile)
      LogFile.process_clicks(@logfile)
    end

    it "should parse each line in the file" do
      LogFile.should_receive(:parse_line_for_click).exactly(@log_entries.size).times
      LogFile.process_clicks(@logfile)
    end
    
    context "when there is an error in parsing a log entry in the file" do
      before do
        file = File.open(@logfile, "w+") {|file| file.puts("nonsense line")}
      end

      it "should skip the line and proceed" do
        LogFile.process_clicks(@logfile)
      end
    end

    after do
      FileUtils.rm(@logfile)
    end
  end

  describe "#parse_line_for_click(log_entry)" do
    context "when log entry is well-formed" do
      before do
        @log_entry = <<'EOF'
            98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444& HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end

      it "should create a Click record with the necessary parameters" do
        Click.should_receive(:create!).with(:query=> "amalgam",
                                            :queried_at => @timestamp_utc,
                                            :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                            :serp_position => 0,
                                            :source => 'firstgov-msn',
                                            :project => 'firstgov',
                                            :affiliate => 'usasearch.gov',
                                            :host => 'www.cdc.com',
                                            :tld => 'com')
        LogFile.parse_line_for_click(@log_entry)
      end
    end
    
    context "when affiliate is set in request URL and not in referrer URL" do
      before do
        @log_entry =<<'EOF'
        98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444&affiliate=test.affiliate.gov HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end
      
      it "should create a Click record with affiliate set to the affiliate value from the request (test.affiliate.gov)" do
        Click.should_receive(:create!).with(:query=> "amalgam",
                                            :queried_at => @timestamp_utc,
                                            :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                            :serp_position => 0,
                                            :source => 'firstgov-msn',
                                            :project => 'firstgov',
                                            :affiliate => 'test.affiliate.gov',
                                            :host => 'www.cdc.com',
                                            :tld => 'com')
        LogFile.parse_line_for_click(@log_entry)
      end
    end
    
    context "when affiliate is set in the referrer URL and not in request URL" do
      before do
        @log_entry =<<'EOF'
        98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444 HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&affiliate=test.affiliate.gov&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end

      it "should create a Click record with affiliate set to the affiliate value (test.affiliate.gov)" do
        Click.should_receive(:create!).with(:query=> "amalgam",
                                            :queried_at => @timestamp_utc,
                                            :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                            :serp_position => 0,
                                            :source => 'firstgov-msn',
                                            :project => 'firstgov',
                                            :affiliate => 'test.affiliate.gov',
                                            :host => 'www.cdc.com',
                                            :tld => 'com')
          LogFile.parse_line_for_click(@log_entry)
      end
    end

    context "when affiliate is not set in either the request URL or the referrer URL" do
      before do
        @log_entry =<<'EOF'
        98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444 HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end

      it "should create a Click record with affiliate set to the 'usasearch.gov'" do
        Click.should_receive(:create!).with(:query=> "amalgam",
                                            :queried_at => @timestamp_utc,
                                            :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                            :serp_position => 0,
                                            :source => 'firstgov-msn',
                                            :project => 'firstgov',
                                            :affiliate => 'usasearch.gov',
                                            :host => 'www.cdc.com',
                                            :tld => 'com')
          LogFile.parse_line_for_click(@log_entry)
      end
    end
    
    context "when affiliate is set in the referrer URL and in request URL" do
      before do
        @log_entry =<<'EOF'
        98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444&affiliate=request.affiliate.gov HTTP/1.1" 302 269 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Asources=firstgov-search-select&v%3Aproject=firstgov&query=amalgam&affiliate=referrer.affiliate.gov&x=0&y=0" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end

      it "should create a Click record with affiliate set to the value in the request URL" do
        Click.should_receive(:create!).with(:query=> "amalgam",
                                            :queried_at => @timestamp_utc,
                                            :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                            :serp_position => 0,
                                            :source => 'firstgov-msn',
                                            :project => 'firstgov',
                                            :affiliate => 'request.affiliate.gov',
                                            :host => 'www.cdc.com',
                                            :tld => 'com')
          LogFile.parse_line_for_click(@log_entry)
      end
    end

    
    context "when referrer is blank" do
      before do
        @log_entry = <<'EOF'
        98.233.40.157 - - [15/Jan/2010:12:25:46 -0500] "GET /search?v%3aproject=firstgov&v%3afile=viv_1148%4026%3aPbExcn&v%3astate=root%7croot&opener=full-window&url=http%3a%2f%2fwww.cdc.com%2fOralHealth%2fpublications%2ffactsheets%2famalgam.htm&rid=Ndoc6&v%3aframe=redirect&rsource=firstgov-msn&v%3astate=%28root%29%7croot&rrank=0&h=f53cb84476a16a540e4d31f7fff81444& HTTP/1.1" 302 269 "-" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Chrome/4.0.249.49 Safari/532.5" cf26.clusty.com usasearch.gov
EOF
        @timestamp_utc = Time.parse("15/Jan/2010 12:25:46 -0500").utc
      end
      
      it "should create a Click record with a null query" do
         Click.should_receive(:create!).with(:query => nil,
                                             :queried_at => @timestamp_utc,
                                             :url => 'http://www.cdc.com/OralHealth/publications/factsheets/amalgam.htm',
                                             :serp_position => 0,
                                             :source => 'firstgov-msn',
                                             :project => 'firstgov',
                                             :affiliate => 'usasearch.gov',
                                             :host => 'www.cdc.com',
                                             :tld => 'com')
        LogFile.parse_line_for_click(@log_entry)
      end
    end
  end
end