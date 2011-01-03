require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do
  fixtures :affiliates, :misspellings

  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_options = {:query => 'government', :page => 3, :affiliate => @affiliate}
  end

  describe "#run" do

    context "when JSON cannot be parsed for some reason" do
      before do
        JSON.should_receive(:parse).once.and_raise(JSON::ParserError)
        @search = Search.new(@valid_options)
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should log a warning" do
        RAILS_DEFAULT_LOGGER.should_receive(:warn)
        @search.run
      end
    end

    context "when a SocketError occurs" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise SocketError
      end

      it "should return false when searching" do
        @search.run.should be_false
      end
    end

    context "when Bing gives us the hand" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ECONNREFUSED
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing kicks us to the curb" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ECONNRESET
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing takes waaaaaaaaay to long to respond" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Timeout::Error
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing stops talking in mid-sentence" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise EOFError
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing is unreachable" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ENETUNREACH
      end

      it "should return false when searching" do
        @search.run.should be_false
      end
    end

    context "when enable highlighting is set to true" do
      it "should pass the enable highlighting parameter to Bing as an option" do
        uriresult = URI::parse("http://localhost:3000")
        search = Search.new(@valid_options.merge(:enable_highlighting => true))
        URI.should_receive(:parse).with(/EnableHighlighting/).and_return(uriresult)
        search.run
      end
    end

    context "when enable highlighting is set to false" do
      it "should not pass enable highlighting parameter to Bing as an option" do
        uriresult = URI::parse("http://localhost:3000")
        search = Search.new(@valid_options.merge(:enable_highlighting => false))
        URI.should_receive(:parse).with(/Options=&/).and_return(uriresult)
        search.run
      end
    end

    context "when non-English locale is specified" do
      before do
        I18n.locale = :es
      end

      it "should pass a language filter to Bing" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options)
        URI.should_receive(:parse).with(/%20language%3Aes/).and_return(uriresult)
        search.run
      end

      it "should not search for Spotlights or GovForms, but should search for FAQs" do
        search = Search.new(@valid_options.merge(:affiliate => nil))
        Spotlight.should_not_receive(:search_for)
        GovForm.should_not_receive(:search_for)
        Faq.should_receive(:search_for).with(@valid_options[:query], I18n.locale.to_s)
        search.run
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when affiliate has domains specified and user does not specify site: in search" do
      before do
        @affiliate = Affiliate.new(:domains => %w(   foo.com bar.com   ).join("\r\n"))
        @uriresult = URI::parse("http://localhost:3000/")
        @default_scope = /\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/
      end

      it "should use affiliate domains in query to Bing without passing ScopeID" do
        search = Search.new(@valid_options.merge(:affiliate => @affiliate))
        URI.should_receive(:parse).with(/query=\(government\)%20\(site%3Afoo\.com%20OR%20site%3Abar\.com\)$/).and_return(@uriresult)
        search.run
      end

      context "when the domains are separated by only '\\n'" do
        before do
          @affiliate.domains = %w(  foo.com bar.com  ).join("\n")
          @affiliate.save
        end

        it "should split the domains the same way" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate))
URI.should_receive(:parse).with(/query=\(government\)%20\(site%3Afoo\.com%20OR%20site%3Abar\.com\)$/).and_return(@uriresult)
        search.run
        end
      end

      context "when a scope id parameter is passed" do
        it "should use the scope id with the default scope and ignore any domains if the scope id is valid" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :scope_id => 'PatentClass'))
          URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3APatentClass\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end

        it "should use the affiliate's domains if the scope id is not on the list of valid scopes" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :scope_id => 'InvalidScope'))
          URI.should_receive(:parse).with(/query=\(government\)%20\(site%3Afoo\.com%20OR%20site%3Abar\.com\)$/).and_return(@uriresult)
          search.run
        end

        it "should use the affiliates domains if the scope id is empty" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :scope_id => ''))
          URI.should_receive(:parse).with(/query=\(government\)%20\(site%3Afoo\.com%20OR%20site%3Abar\.com\)$/).and_return(@uriresult)
          search.run
        end
      end
    end

    context "when affiliate has domains specified but user specifies site: in search" do
      before do
        @affiliate = Affiliate.new(:domains => %w(   foo.com bar.com   ).join("\n"))
        @uriresult = URI::parse("http://localhost:3000/")
        @default_scope = /\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/
      end

      it "should override affiliate domains in query to Bing and use ScopeID/gov/mil combo" do
        search = Search.new(@valid_options.merge(:affiliate => @affiliate, :query=>"government site:blat.gov"))
        URI.should_receive(:parse).with(/query=\(government%20site%3Ablat\.gov\)%20#{@default_scope}$/).and_return(@uriresult)
        search.run
      end

      context "and the affiliate specifies a scope id" do
        it "should use the scope id with the default scope if the scope is valid" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :query=>"government site:blat.gov", :scope_id => 'PatentClass'))
          URI.should_receive(:parse).with(/query=\(government%20site%3Ablat\.gov\)%20\(scopeid%3APatentClass\)%20#{@default_scope}$/).and_return @uriresult
          search.run
        end

        it "should use the default scope if the scope is invalid" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :query=>"government site:blat.gov", :scope_id => 'InvalidScope'))
          URI.should_receive(:parse).with(/query=\(government%20site%3Ablat\.gov\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end

        it "should use the default scope if the scope is empty" do
          search = Search.new(@valid_options.merge(:affiliate => @affiliate, :query=>"government site:blat.gov", :scope_id => ''))
          URI.should_receive(:parse).with(/query=\(government%20site%3Ablat\.gov\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end
      end
    end

    context "when affiliate has no domains specified" do
      before do
        @uriresult = URI::parse("http://localhost:3000/")
        @default_scope = /\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/
      end

      it "should use just query string and ScopeID/gov/mil combo" do
        search = Search.new(@valid_options.merge(:affiliate => Affiliate.new))
        URI.should_receive(:parse).with(/query=\(government\)%20#{@default_scope}$/).and_return(@uriresult)
        search.run
      end

      context "when a scope id is provided" do
        it "should use the scope id with the default scope if the scope id provided is valid" do
          search = Search.new(@valid_options.merge(:affiliate => Affiliate.new, :scope_id => 'PatentClass'))
          URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3APatentClass\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end

        it "should ignore the scope id if it's not on the list of valid scopes" do
          search = Search.new(@valid_options.merge(:affiliate => Affiliate.new, :scope_id => 'InvalidScope'))
          URI.should_receive(:parse).with(/query=\(government\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end

        it "should ignore the scope id if it's empty" do
          search = Search.new(@valid_options.merge(:affiliate => Affiliate.new, :scope_id => ''))
          URI.should_receive(:parse).with(/query=\(government\)%20#{@default_scope}$/).and_return(@uriresult)
          search.run
        end
      end
    end

    context "when affiliate is nil" do
      before do
        @search = Search.new(@valid_options.merge(:affiliate => nil))
      end

      it "should use just query string and ScopeID/gov/mil combo" do
        uriresult = URI::parse("http://localhost:3000/")
        URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)$/).and_return(uriresult)
        @search.run
      end

      it "should search for FAQs" do
        Faq.should_receive(:search_for).with('government', I18n.default_locale.to_s)
        @search.run
      end

      it "should search for GovForms" do
        GovForm.should_receive(:search_for).with('government')
        @search.run
      end

      context "when a scope id is specified" do
        it "should ignore the scope id" do
          uriresult = URI::parse("http://localhost:3000/")
          @search = Search.new(@valid_options.merge(:affiliate => nil, :scope_id => 'PatentClass'))
          URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)$/).and_return(uriresult)
          @search.run
        end
      end
    end

    context "when affiliate is not nil" do
      it "should not search for FAQs" do
        search = Search.new(@valid_options)
        Faq.should_not_receive(:search_for)
        search.run
      end

      it "should not search for GovForms" do
        search = Search.new(@valid_options)
        GovForm.should_not_receive(:search_for)
        search.run
      end
    end

    context "when page offset is specified" do
      it "should specify the offset in the query to Bing" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:page => 7))
        URI.should_receive(:parse).with(/web\.offset=70/).and_return(uriresult)
        search.run
      end
    end

    context "when advanced query parameters are passed" do
      before do
        @uriresult = URI::parse('http://localhost:3000')
      end

      context "when query is limited to search only in titles" do
        it "should construct a query string with the intitle: limits on the query parameter" do
          search = Search.new(@valid_options.merge(:query_limit => "intitle:"))
          URI.should_receive(:parse).with(/query=\(intitle%3Agovernment\)/).and_return(@uriresult)
          search.run
        end

        context "when more than one query term is specified" do
          it "should construct a query string with intitle: limits before each query term" do
            search = Search.new(@valid_options.merge(:query => 'barack obama', :query_limit => 'intitle:'))
            URI.should_receive(:parse).with(/query=\(intitle%3Abarack%20intitle%3Aobama\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when query limit is blank" do
          it "should not use the query limit in the query string" do
            search = Search.new(@valid_options.merge(:query_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a phrase query is specified" do
        it "should construct a query string that includes the phrase in quotes" do
          search = Search.new(@valid_options.merge(:query_quote => 'barack obama'))
          URI.should_receive(:parse).with(/%22barack%20obama%22/).and_return(@uriresult)
          search.run
        end

        context "when the phrase query limit is set to intitle:" do
          it "should construct a query string with the intitle: limit on the phrase query" do
            search = Search.new(@valid_options.merge(:query_quote => 'barack obama', :query_quote_limit => 'intitle:'))
            URI.should_receive(:parse).with(/%20intitle%3A%22barack%20obama%22/).and_return(@uriresult)
            search.run
          end
        end

        context "and it is blank" do
          it "should not include a phrase query in the url" do
            search = Search.new(@valid_options.merge(:query_quote => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the phrase query is blank and the phrase query limit is blank" do
          it "should not include anything relating to phrase query in the query string" do
            search = Search.new(@valid_options.merge(:query_quote => '', :query_quote_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when OR terms are specified" do
        it "should construct a query string that includes the OR terms OR'ed together" do
          search = Search.new(@valid_options.merge(:query_or => 'barack obama'))
          URI.should_receive(:parse).with(/barack%20OR%20obama/).and_return(@uriresult)
          search.run
        end

        context "when the OR query limit is set to intitle:" do
          it "should construct a query string that includes the OR terms with intitle prefix" do
            search = Search.new(@valid_options.merge(:query_or => 'barack obama', :query_or_limit => 'intitle:'))
            URI.should_receive(:parse).with(/intitle%3Abarack%20OR%20intitle%3Aobama/).and_return(@uriresult)
            search.run
          end
        end

        context "when the OR query is blank" do
          it "should not include an OR query parameter in the query string" do
            search = Search.new(@valid_options.merge(:query_or => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the OR query is blank and the OR query limit is blank" do
          it "should not include anything relating to OR query in the query string" do
            search = Search.new(@valid_options.merge(:query_or => '', :query_or_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when negative query terms are specified" do
        it "should construct a query string that includes the negative query terms prefixed with '-'" do
          search = Search.new(@valid_options.merge(:query_not => 'barack obama'))
          URI.should_receive(:parse).with(/-barack%20-obama/).and_return(@uriresult)
          search.run
        end

        context "when the negative query limit is set to intitle:" do
          it "should construct a query string that includes the negative terms with intitle prefix" do
            search = Search.new(@valid_options.merge(:query_not => 'barack obama', :query_not_limit => 'intitle:'))
            URI.should_receive(:parse).with(/-intitle%3Abarack%20-intitle%3Aobama/).and_return(@uriresult)
            search.run
          end
        end

        context "when the negative query is blank" do
          it "should not include a negative query parameter in the query string" do
            search = Search.new(@valid_options.merge(:query_not => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the negative query is blank and the negative query limit are blank" do
          it "should not include anything relating to negative query in the query string" do
            search = Search.new(@valid_options.merge(:query_not => '', :query_not_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a filetype is specified" do
        it "should construct a query string that includes a filetype" do
          search = Search.new(@valid_options.merge(:file_type => 'pdf'))
          URI.should_receive(:parse).with(/filetype%3Apdf/).and_return(@uriresult)
          search.run
        end

        context "when the filetype specified is 'All'" do
          it "should construct a query string that does not have a filetype parameter" do
            search = Search.new(@valid_options.merge(:file_type => 'All'))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when a blank filetype is passed in" do
          it "should not put filetype parameters in the query string" do
            search = Search.new(@valid_options.merge(:file_type => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when one or more site limits are specified" do
        it "should construct a query string with site limits for each of the sites" do
          search = Search.new(@valid_options.merge(:site_limits => 'whitehouse.gov omb.gov'))
          URI.should_receive(:parse).with(/site%3Awhitehouse.gov%20OR%20site%3Aomb.gov/).and_return(@uriresult)
          search.run
        end

        context "when a blank site limit is passed" do
          it "should not include site limit in the query string" do
            search = Search.new(@valid_options.merge(:site_limits => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when one or more site exclusions is specified" do
        it "should construct a query string with site exlcusions for each of the sites" do
          search = Search.new(@valid_options.merge(:site_excludes => "whitehouse.gov omb.gov"))
          URI.should_receive(:parse).with(/-site%3Awhitehouse.gov%20-site%3Aomb.gov/).and_return(@uriresult)
          search.run
        end

        context "when a blank site exclude is passed" do
          it "should not include site exclude in the query string" do
            search = Search.new(@valid_options.merge(:site_excludes => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a fedstates parameter is specified" do
        it "should set the scope if with the fedstates parameter" do
          search = Search.new(@valid_options.merge(:fedstates => 'MD'))
          URI.should_receive(:parse).with(/\(scopeid%3AusagovMD\)/).and_return(@uriresult)
          search.run
        end

        context "when the fedstates parameter specified is 'all'" do
          it "should use the 'usagovall' scopeid with .gov and .mil sites included" do
            search = Search.new(@valid_options.merge(:fedstates => 'all'))
            URI.should_receive(:parse).with(/\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when fedstates parameter is blank" do
          it "should use the 'usagovall' scope id with .gov and .mil sites included" do
            search = Search.new(@valid_options.merge(:fedstates => ''))
            URI.should_receive(:parse).with(/\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a results per page number is specified" do
        it "should construct a query string with the appropriate per page variable set" do
          search = Search.new(@valid_options.merge(:results_per_page => 20))
          URI.should_receive(:parse).with(/web\.count=20/).and_return(@uriresult)
          search.run
        end

        it "should not set a per page value above 50" do
          search = Search.new(@valid_options.merge(:results_per_page => 100))
          URI.should_receive(:parse).with(/web\.count=50/).and_return(@uriresult)
          search.run
        end

        context "when the results_per_page variable passed is blank" do
          it "should set the per-page parameter to the default value, defined by the DEFAULT_PER_PAGE variable" do
            search = Search.new(@valid_options)
            URI.should_receive(:parse).with(/web\.count=10/).and_return(@uriresult)
            search.run
          end
        end

        context "when the results_per_page variable that is passed is a string" do
          it "should convert the string to an integer and not fail" do
            search = Search.new(@valid_options.merge(:results_per_page => "30"))
            URI.should_receive(:parse).with(/web\.count=30/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when multiple or all of the advanced query parameters are specified" do
        it "should construct a query string that incorporates all of them with the proper spacing" do
          search = Search.new(@valid_options.merge(:query_limit => 'intitle:',
                                                   :query_quote => 'barack obama',
                                                   :query_quote_limit => '',
                                                   :query_or => 'cars stimulus',
                                                   :query_or_limit => '',
                                                   :query_not => 'clunkers',
                                                   :query_not_limit => 'intitle:',
                                                   :file_type => 'pdf',
                                                   :site_limits => 'whitehouse.gov omb.gov',
                                                   :site_excludes => 'nasa.gov noaa.gov'))
          URI.should_receive(:parse).with(/query=\(intitle%3Agovernment%20%22barack%20obama%22%20cars%20OR%20stimulus%20-intitle%3Aclunkers%20filetype%3Apdf%20site%3Awhitehouse.gov%20OR%20site%3Aomb.gov%20-site%3Anasa.gov%20-site%3Anoaa.gov\)/).and_return(@uriresult)
          search.run
        end
      end

      context "when a valid filter parameter is set" do
        it "should set the Adult parameter in the query sent to Bing" do
          search = Search.new(@valid_options.merge(:filter => 'off'))
          URI.should_receive(:parse).with(/Adult=off/).and_return(@uriresult)
          search.run
        end

        context "when the filter parameter is blank" do
          it "should set the Adult parameter to the default value ('strict')" do
            search = Search.new(@valid_options.merge(:filter => ''))
            URI.should_receive(:parse).with(/Adult=#{Search::DEFAULT_FILTER_SETTING}/).and_return(@uriresult)
            search.run
          end
        end

        context "when the filter parameter is nil" do
          it "should set the Adult parameter to the default value" do
            search = Search.new(@valid_options)
            URI.should_receive(:parse).with(/Adult=#{Search::DEFAULT_FILTER_SETTING}/).and_return(@uriresult)
            search.run
          end
        end

        context "when the filter parameter is not in the list of valid filter values" do
          it "should set the Adult parameter to the default value" do
            search = Search.new(@valid_options.merge(:filter => 'invalid'))
            URI.should_receive(:parse).with(/Adult=#{Search::DEFAULT_FILTER_SETTING}/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a filter parameter is not set" do
        it "should set the Adult parameter to the default value ('strict')" do
          search = Search.new(@valid_options)
          URI.should_receive(:parse).with(/Adult=strict/).and_return(@uriresult)
          search.run
        end
      end

    end

    context "when performing an uppercase search that has a downcased related topic" do
      before do
        CalaisRelatedSearch.create!(:term=> "whatever", :related_terms => "ridiculous government grants | big government | democracy")
        CalaisRelatedSearch.reindex
        @search = Search.new(:query=>"Democracy")
        @search.run
      end

      it "should not have the matching related topic in the array of strings" do
        @search.related_search.should == ["big government", "ridiculous government grants", "whatever"]
      end
    end

    context "when performing a search that has a uppercased related topic" do
      before do
        CalaisRelatedSearch.create!(:term=> "whatever", :related_terms => "Fred Espenak | big government | democracy")
        CalaisRelatedSearch.reindex
        @search = Search.new(:query=>"Fred Espenak")
        @search.run
      end

      it "should not have the matching related topic in the array of strings" do
        @search.related_search.should == ["big government", "democracy", "whatever"]
      end
    end

    context "when performing an affiliate search that has related topics" do
      before do
        CalaisRelatedSearch.create!(:term => "pivot term", :related_terms => "government grants | big government | democracy", :affiliate => @valid_options[:affiliate])
        CalaisRelatedSearch.reindex
      end

      it "should have a related searches array of strings including the pivot term" do
        search = Search.new(@valid_options)
        search.run
        search.related_search.should == ["big government" , "democracy","government grants", "pivot term"]
      end

      context "when there are also related topics for the default affiliate" do
        before do
          @affiliate = @valid_options[:affiliate]
          CalaisRelatedSearch.create!(:term => "pivot term", :related_terms => "government health care | small government | fascism")
          CalaisRelatedSearch.reindex
        end

        context "when the affiliate has affiliate related topics enabled" do
          before do
            @affiliate.related_topics_setting = 'affiliate_enabled'
            @affiliate.save
          end

          it "should return the affiliate related topics" do
            search = Search.new(@valid_options)
            search.run
            search.related_search.should == ["big government" , "democracy", "government grants", "pivot term"]
          end
        end

        context "when the affiliate has global related topics enabled" do
          before do
            @affiliate.related_topics_setting = 'global_enabled'
            @affiliate.save
          end

          it "should return the global related topics" do
            search = Search.new(@valid_options)
            search.run
            search.related_search.should == ["fascism", "government health care", "pivot term", "small government"]
          end
        end

        context "when the affiliate has related topics disabled" do
          before do
            @affiliate.related_topics_setting = 'disabled'
            @affiliate.save
          end

          it "should return the affiliate related topics" do
            search = Search.new(@valid_options)
            search.run
            search.related_search.should == []
          end
        end
      end
    end

    context "when performing an affiliate search that does not have related topics while the default affiliate does" do
      before do
        CalaisRelatedSearch.create!(:term=> @valid_options[:query], :related_terms => "government grants | big government | democracy")
        CalaisRelatedSearch.reindex
        @search = Search.new(@valid_options)
        @search.run
      end

      it "should not fall back to the result for the default affiliate" do
        @search.related_search.size.should == 0
      end
    end

    context "when the query contains an '&' character" do
      it "should pass a url-escaped query string to Bing" do
        @uriresult = URI::parse('http://localhost:3000')
        query = "Pros & Cons Physician Assisted Suicide"
        search = Search.new(@valid_options.merge(:query => query))
        URI.should_receive(:parse).with(/Pros%20%26%20Cons%20Physician%20Assisted%20Suicide/).and_return(@uriresult)
        search.run
      end
    end

    context "when the query ends in OR" do
      before do
        CalaisRelatedSearch.create!(:term=> "portland or", :related_terms => %w{ portland or | oregon | rain })
        CalaisRelatedSearch.reindex
        @search = Search.new(:query => "Portland OR")
        @search.run
      end

      it "should still work (i.e., downcase the query so Solr does not treat it as a Boolean OR)" do
        @search.related_search.size.should == 3
      end
    end

    context "when searching with really long queries" do
      before do
        @search = Search.new(@valid_options.merge(:query => "X"*10000))
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end

      it "should set error message" do
        @search.run
        @search.error_message.should_not be_nil
      end
    end

    context "when searching with nonsense queries" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'kjdfgkljdhfgkldjshfglkjdsfhg'))
      end

      it "should return true when searching" do
        @search.run.should be_true
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end
    end

    context "when results contain listing missing a title" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'Nas & Kelis'))
        json = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_two_search_results_one_missing_title.json")
        parsed = JSON.parse(json)
        JSON.stub!(:parse).and_return parsed
      end

      it "should ignore that result" do
        @search.run
        @search.results.size.should == 1
      end
    end

    context "when results contain listing missing a description" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'data'))
        json = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_search_results_with_some_missing_descriptions.json")
        parsed = JSON.parse(json)
        JSON.stub!(:parse).and_return parsed
      end

      it "should use a blank description" do
        @search.run
        @search.results.size.should == 10
        @search.results.each do |result|
          result['content'].should == ""
        end
      end
    end

    context "when searching for misspelled terms" do
      before do
        @search = Search.new(@valid_options.merge(:query => "o'bama"))
        @search.run
      end

      it "should have spelling suggestions" do
        @search.spelling_suggestion.should == "obama"
      end
    end

    context "when suggestions for misspelled terms contain scopeid or parenthesis" do
      before do
        @search = Search.new(@valid_options.merge(:query => '(electro coagulation) site:uspto.gov'))
        json = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_search_results_with_spelling_suggestions.json")
        parsed = JSON.parse(json)
        JSON.stub!(:parse).and_return parsed
        @search.run
      end

      it "should strip them all out, leaving site: terms in the suggestion" do
        @search.spelling_suggestion.should == "electrocoagulation site:uspto.gov"
      end
    end

    context "spotlight searches" do
      fixtures :spotlights
      context "when a spotlight is set up for something relevant to the search term" do
        before do
          @spotty = spotlights(:time)
        end

        it "should assign the Spotlight" do
          @search = Search.new(@valid_options.merge(:query => 'walk time', :affiliate=> nil))
          Spotlight.should_receive(:search_for).with('walk time').and_return(@spotty)
          @search.run
          @search.spotlight.should == @spotty
        end
      end

      context "when no relevant spotlight exists for the search term" do
        it "should assign a nil Spotlight" do
          @search = Search.new(@valid_options.merge(:query => 'nothing here', :affiliate=> nil))
          Spotlight.should_receive(:search_for).with('nothing here').and_return(nil)
          @search.run
          @search.spotlight.should be_nil
        end
      end
    end

    context "recent recalls (last month)" do
      before do
        @date_filter_hash= {:start_date=>1.month.ago.to_date, :end_date=>Date.today}
      end

      context "when search term does not contain recall or recalls" do
        it "should not look for recalls" do
          search = Search.new(@valid_options.merge(:query => 'foo bar'))
          Recall.should_not_receive(:search_for)
          search.run
        end
      end

      context "when search phrase is just the word recall(s)" do
        it "should not look for recalls" do
          search = Search.new(@valid_options.merge(:query => 'recall'))
          Recall.should_not_receive(:search_for)
          search.run
        end
      end

      context "when search phrase contains recall" do
        it "should strip off the recall word before searching" do
          search = Search.new(@valid_options.merge(:query => 'foo bar recall'))
          Recall.should_receive(:search_for).with('foo bar', @date_filter_hash)
          search.run
        end
      end

      context "when search phrase contains recalls" do
        it "should strip off the recalls word before searching" do
          search = Search.new(@valid_options.merge(:query => 'recalls of pepper'))
          Recall.should_receive(:search_for).with('of pepper', @date_filter_hash)
          search.run
        end
      end

      context "when no relevant recall exists for the search term" do
        it "should assign nil to recalls" do
          search = Search.new(@valid_options.merge(:query => 'nothing here recall'))
          Recall.should_receive(:search_for).with('nothing here', @date_filter_hash).and_return(nil)
          search.run
          search.recalls.should be_nil
        end
      end

      context "when search phrase stripped of 'recall' is an unparseable query string" do
        it "should catch an rsolr error and assign nil to recalls" do
          search = Search.new(@valid_options.merge(:query => 'sheetrock OR recall'))
          Recall.should_receive(:search_for).with('sheetrock OR', @date_filter_hash).and_raise(RSolr::RequestError)
          search.run
          search.recalls.should be_nil
        end
      end
    end

    context "weather searches" do
      before do
        Location.create(:zip_code => 21209, :state => 'MD', :city => 'Baltimore', :population => 20000, :lat => 39.0459, :lng => -76.7896)
        Location.create(:zip_code => 21215, :state => 'MD', :city => 'Baltimore', :population => 19000, :lat => 39.0345, :lng => -76.9890)
        Location.create(:zip_code => 10003, :state => 'NY', :city => 'Baltimore', :population => 100, :lat => 45.4567, :lng => -144.0303)
      end

      context "when the query does not contain the term 'weather'" do
        it "should not create a weather spotlight" do
          WeatherSpotlight.should_not_receive(:new)
          search = Search.new(:query => 'obama')
          search.run
          search.weather_spotlight.should be_nil
        end
      end

      context "when the query is 'weather'" do
        it "should not create a weather spotlight" do
          WeatherSpotlight.should_not_receive(:new)
          search = Search.new(:query => 'weather')
          search.run
          search.weather_spotlight.should be_nil
        end

        context "when the query is capitlized" do
          it "should not create a weather spotlight" do
            WeatherSpotlight.should_not_receive(:new)
            search = Search.new(:query => 'Weather')
            search.run
            search.weather_spotlight.should be_nil
          end
        end
      end

      context "when the query is 'forecast'" do
        it "should not create a weather spotlight" do
          WeatherSpotlight.should_not_receive(:new)
          search = Search.new(:query => 'forecast')
          search.run
          search.weather_spotlight.should be_nil
        end

        context "when the query is capitlized" do
          it "should not create a weather spotlight" do
            WeatherSpotlight.should_not_receive(:new)
            search = Search.new(:query => 'FORECASE')
            search.run
            search.weather_spotlight.should be_nil
          end
        end
      end

      context "when the query contains the term 'weather' with additional information" do
        it "should create a weather spotlight" do
          WeatherSpotlight.should_receive(:new).with('21209').and_return true
          search = Search.new(:query => 'weather 21209')
          search.run
          search.weather_spotlight.should_not be_nil
        end
      end

      context "when the query contains the term 'forecast' with additional information" do
        it "should create a weather spotlight" do
          WeatherSpotlight.should_receive(:new).with('baltimore').and_return true
          search = Search.new(:query => 'baltimore forecast')
          search.run
          search.weather_spotlight.should_not be_nil
        end
      end

      context "when the terms queried are not a valid location" do
        it "should create a search with no weather spotlight" do
          WeatherSpotlight.should_receive(:new).with('21208').and_raise(RuntimeError.new('Location Not Found: 21208'))
          search = Search.new(:query => 'weather 21208')
          search.run
          search.should_not be_nil
          search.weather_spotlight.should be_nil
        end
      end

      context "when the request to Weather.gov times out" do
        it "should catch the timeout exception, complete the search without a weather spotlight" do
          WeatherSpotlight.should_receive(:new).with('21209').and_raise Errno::ETIMEDOUT
          search = Search.new(:query => 'weather 21209')
          search.run
          search.should_not be_nil
          search.weather_spotlight.should be_nil
        end
      end

      context "when the search is for an affiliate" do
        it "should not search for weather spotlights" do
          WeatherSpotlight.should_not_receive(:new)
          search = Search.new(@valid_options.merge(:query => 'weather 21209'))
          search.run
          search.should_not be_nil
          search.weather_spotlight.should be_nil
        end
      end
    end

    context "when paginating" do
      default_page = 0

      it "should default to page 0 if no valid page number was specified" do
        options_without_page = @valid_options.reject { |k, v| k == :page }
        Search.new(options_without_page).page.should == default_page
        Search.new(@valid_options.merge(:page => '')).page.should == default_page
        Search.new(@valid_options.merge(:page => 'string')).page.should == default_page
      end

      it "should set the page number" do
        search = Search.new(@valid_options.merge(:page => 2))
        search.page.should == 2
      end

      it "should use the underlying engine's results per page" do
        search = Search.new(@valid_options)
        search.run
        search.results.size.should == Search::DEFAULT_PER_PAGE
      end

      it "should set startrecord/endrecord" do
        page = 7
        search = Search.new(@valid_options.merge(:page => page))
        search.run
        search.startrecord.should == Search::DEFAULT_PER_PAGE * page + 1
        search.endrecord.should == search.startrecord + search.results.size - 1
      end
    end
  end

  describe "when new" do
    it "should have a settable query" do
      search = Search.new(@valid_options)
      search.query.should == 'government'
    end

    it "should have a settable affiliate" do
      search = Search.new(@valid_options)
      search.affiliate.should == @affiliate
    end

    it "should not require a query or affiliate" do
      lambda { Search.new }.should_not raise_error(ArgumentError)
    end
  end

  describe "#suggestions(affiliate_id, sanitized_query, num_suggestions)" do
    before do
      phrase = "aaaazy"
      popularity = 10
      16.times { SaytSuggestion.create!(:phrase => phrase.succ!, :popularity => (popularity = popularity.succ)) }
    end

    it "should default to returning 15 suggestions" do
      Search.suggestions(nil, "aaa").size.should == 15
    end

    it "should accept an override for number of suggestions to return" do
      Search.suggestions(nil, "aaa", 6).size.should == 6
    end

    it "should run the words in the query phrase against the misspellings list" do
      SaytSuggestion.create!(:phrase => "obama president")
      Search.suggestions(nil, "ubama pres").first.phrase.should == "obama president"
    end

    context "when no suggestions exist for the query" do
      it "should return an empty array" do
        Search.suggestions(nil, "nothing to see here").should == []
      end
    end

    it "should use affiliate_id to find suggestions" do
      SaytSuggestion.should_receive(:like).with(370, "xyz", 5)
      Search.suggestions(370, "xyz", 5)
    end
  end

  describe "#hits(response)" do
    context "when Bing reports a total > 0 but gives no results whatsoever" do
      before do
        @search = Search.new
        @response = mock("response")
        web = mock("web")
        @response.stub!(:web).and_return(web)
        web.stub!(:results).and_return(nil)
        web.stub!(:total).and_return(4000)
      end

      it "should return zero for the number of hits" do
        @search.send(:hits, @response).should == 0
      end
    end
  end

  describe "#as_json" do
    context "when converting search response to json" do
      before do
        @search = Search.new(:query => 'obama')
        @search.run
        allow_message_expectations_on_nil
      end

      it "should generate a JSON representation of total, start and end records, spelling suggestions, related searches and search results" do
        @search.spelling_suggestion.should_receive(:to_json).and_return ""
        @search.related_search.should_receive(:to_json).and_return ""
        @search.results.should_receive(:to_json).and_return ""
        json = @search.to_json
        json.should contain(/total/)
        json.should contain(/startrecord/)
        json.should contain(/endrecord/)
      end

      context "when an error occurs" do
        before do
          @search.error_message = "Some error"
        end

        it "should output an error if an error is detected" do
          json = @search.to_json
          json.should contain(/"error":"Some error"/)
        end
      end
    end
  end

  describe "caching in #perform(query_string, offset, enable_highlighting)" do
    before do
      @redis = Search.send(:class_variable_get,:@@redis)
      @search = Search.new
      @search.results_per_page = 99
    end

    it "should attempt to get the results from the Redis cache" do
      @redis.should_receive(:get).with("foo:10:99:true")
      @search.send(:perform, "foo", 10, true)
    end

    context "when no results in cache" do
      it "should store newly fetched results in cache with appropriate expiry" do
        @redis.should_receive(:setex).with("foobar:10:99:true", Search::BING_CACHE_DURATION_IN_SECONDS, an_instance_of(String))
        @search.send(:perform, "foobar", 10, true)
      end
    end
  end
end
