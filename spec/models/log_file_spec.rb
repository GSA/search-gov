require "#{File.dirname(__FILE__)}/../spec_helper"
describe LogFile do
  fixtures :affiliates

  describe "#transform_to_hive_queries_format(filepath)" do
    before do
      raw_entries = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:26 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
143.81.248.54 - - [08/Oct/2009:02:02:27 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
143.81.248.55 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      @log_entries = raw_entries.split("\n")
      @logfile = "/tmp/somelogfile.log"
      file = File.new(@logfile, "w+")
      @log_entries.each { |log_entry| file.puts(log_entry) }
      file.close
    end

    it "should attempt to parse each line in the file" do
      LogFile.should_receive(:parse_and_emit_line).exactly(@log_entries.size).times
      LogFile.transform_to_hive_queries_format(@logfile)
    end

    context "when there is an error in parsing a log entry in the file" do
      before do
        File.open(@logfile, "w+") { |file| file.puts("nonsense line") }
      end

      it "should emit a warning" do
        RAILS_DEFAULT_LOGGER.should_receive(:warn).once
        LogFile.transform_to_hive_queries_format(@logfile)
      end
    end

    after do
      FileUtils.rm(@logfile)
    end

  end

  describe "#parse_and_emit_line(log_entry)" do
    context "when log entry is well-formed" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a tab-delimited record with all the fields [ipaddr, time_of_day (in GMT), path, response size in bytes, referrer, user agent, query term, normalized query term, affiliate, locale, is_bot, is_contextual]" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery plus&more\tdelinquent delivery plus&more\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when log entry query string begins with affiliate parameter" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?affiliate=NOAA.gov&input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a tab-delimited record with all the fields [ipaddr, time_of_day (in GMT), path, response size in bytes, referrer, user agent, query term, normalized query term, affiliate, locale, is_bot, is_contextual]" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?affiliate=NOAA.gov&input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery\tdelinquent delivery\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when affiliate parameter contains uppercase characters" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?affiliate=NOAA.gov&input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should lowercase the affiliate name" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?affiliate=NOAA.gov&input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery\tdelinquent delivery\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when log entry contains query with a comma" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=city%2Cstate&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should turn the comma into a space in the normalized query" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=city%2Cstate&affiliate=noaa.gov&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tcity,state\tcity state\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when query term contains leading, trailing, or multiple spaces" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=%20car%20%20port%20&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should strip out the leading and trailing spaces and squish multiple spaces from the normalized query" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=%20car%20%20port%20&affiliate=noaa.gov&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\t car  port \tcar port\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when affiliate param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the affiliate set to the USA.gov affiliate name" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery\tdelinquent delivery\tusasearch.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when affiliate is nil (e.g., '&y=12&affiliate=&x=12')" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=foo&affiliate=&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the affiliate set to the USA.gov affiliate name" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=foo&affiliate=&x=44&y=18\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tfoo\tfoo\t#{Affiliate::USAGOV_AFFILIATE_NAME}\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when request contains 'noquery' parameter" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=foo&affiliate=noaa.gov&noquery=&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the affiliate does not exist" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&affiliate=sexytime.com&query=spam&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when query param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when log entry contains lots of URL encoded characters" do
      before do
        @log_entry = <<'EOF'
155.82.73.253 - - [30/Jan/2009:13:49:50 -0600] "GET /search?v%3Asources=firstgov-search-select&sitelimit=www.usace.army.mil&Submit=Go&v%3Aproject=firstgov&query=d%27kc%22z%27gj%27%22%2A%2A5%2A%28%28%28%3B-%2A%60%29&input-form=simple-firstgov HTTP/1.1" 200 60322 "-" "w3af.sourceforge.net" cf29.clusty.com usasearch.gov
EOF
      end

      it "should emit record with the necessary characters unencoded in the query and normalized query fields" do
        LogFile.should_receive(:puts).with("155.82.73.253\t19:49:50\t/search?v%3Asources=firstgov-search-select&sitelimit=www.usace.army.mil&Submit=Go&v%3Aproject=firstgov&query=d%27kc%22z%27gj%27%22%2A%2A5%2A%28%28%28%3B-%2A%60%29&input-form=simple-firstgov\t60322\t\tw3af.sourceforge.net\td'kc\"z'gj'\"**5*(((;-*`)\td'kc\"z'gj'\"**5*(((;-*`)\tusasearch.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when query contains non-Western characters that have been URL encoded" do
      before do
        @log_entry = <<'EOF'
98.233.40.157 - - [08/Oct/2009:02:02:28 -0500] "GET /search?query=%D7%91%D7%94%D7%A6%D7%9C%D7%97%D7%94&locale=en&m=&commit=Search HTTP/1.1" 200 6185 "http://search.usa.gov/" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.127 Safari/533.4"
EOF
      end

      it "should emit a record with UTF-8 encoded characters for the query and normalized query fields" do
        LogFile.should_receive(:puts).with("98.233.40.157\t07:02:28\t/search?query=%D7%91%D7%94%D7%A6%D7%9C%D7%97%D7%94&locale=en&m=&commit=Search\t6185\thttp://search.usa.gov/\tMozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.127 Safari/533.4\tבהצלחה\tבהצלחה\tusasearch.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when locale param is not present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the default locale" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tobama\tobama\tusasearch.gov\t#{I18n.default_locale.to_s}\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when English local param is present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=en HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the English locale specified" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=en\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tobama\tobama\tusasearch.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when Spanish local param is present" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the Spanish locale specified" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tobama\tobama\tusasearch.gov\tes\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the User Agent is blank" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with no agent (i.e., nothing between the tab delimiters)" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\t\tobama\tobama\tusasearch.gov\tes\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the user agent is not a bot" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with is_bot set to 0 (false)" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tobama\tobama\tusasearch.gov\tes\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the user agent matches a known bot user agent" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with is_bot set to 1 (true)" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=obama&locale=es\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)\tobama\tobama\tusasearch.gov\tes\t1\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the line is in the Apache common format, instead of the expected combined format" do
      before do
        @log_entry = <<'EOF'
209.112.135.192 - - [31/May/2010:00:02:05 -0400] "GET /search?affiliate=noaa.gov&v%3Aproject=firstgov&query=alaska HTTP/1.1" 200 15035
EOF
      end

      it "should parse the log line, but not set the user agent, and have is_bot set to 0 (false)" do
        LogFile.should_receive(:puts).with("209.112.135.192\t04:02:05\t/search?affiliate=noaa.gov&v%3Aproject=firstgov&query=alaska\t15035\t\t\talaska\talaska\tnoaa.gov\ten\t0\t0")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the query includes a parameter where linked=1" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18&linked=1 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the is_contextual flag to 1 (true)" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18&linked=1\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery plus&more\tdelinquent delivery plus&more\tnoaa.gov\ten\t0\t1")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the query contains a parameter where linked is present but doesn't equal '1'" do
      before do
        @log_entry = <<'EOF'
143.81.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18&linked=2 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should emit a record with the is_contextual flag to 1 (true)" do
        LogFile.should_receive(:puts).with("143.81.248.53\t07:02:28\t/search?query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18&linked=2\t165\thttp://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18\tMozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)\tdelinquent delivery plus&more\tdelinquent delivery plus&more\tnoaa.gov\ten\t0\t1")
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the query comes from a blocked Class C network" do
      before do
        LogfileBlockedClassC.create!(:classc => "1.2.248")
        @log_entry = <<'EOF'
1.2.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the query comes from a blocked IP address" do
      before do
        LogfileBlockedIp.create!(:ip => "99.98.97.1")
        @log_entry = <<'EOF'
99.98.97.1 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery%20plus%26more&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the query term is on the block list" do
      before do
        LogfileBlockedQuery.create!(:query => "verboten term")
        @log_entry = <<'EOF'
199.98.97.1 - - [08/Oct/2009:02:02:28 -0500] "GET /search?input-form=simple-firstgov&v%3Aproject=firstgov&query=verboten+term&affiliate=noaa.gov&x=44&y=18 HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end

    context "when the entire query string matches some regular expression" do
      before do
        LogfileBlockedRegexp.create!(:regexp => "q(uery)=space&sitelimit=science\.")
        @log_entry = <<'EOF'
91.72.248.53 - - [08/Oct/2009:02:02:28 -0500] "GET /search?v%253aproject=firstgov&query=space&sitelimit=science.networkingsocial.info/&input-form=advanced-firstgov& HTTP/1.1" 200 165 36 "http://usasearch.gov/search?input-form=simple-firstgov&v%3Aproject=firstgov&query=delinquent+delivery&affiliate=noaa.gov&x=44&y=18" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" cf28.clusty.com usasearch.gov
EOF
      end

      it "should ignore the record" do
        LogFile.should_not_receive(:puts)
        LogFile.parse_and_emit_line(@log_entry)
      end
    end
  end
end
