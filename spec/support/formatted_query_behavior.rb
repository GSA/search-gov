shared_examples "a formatted query" do
  context "when advanced query parameters are passed" do
    context "when a phrase query is specified" do
      subject { described_class.new(query: 'government', query_quote: 'barack obama') }

      it "should construct a query string that includes the phrase in quotes" do
        subject.query.start_with?('(government "barack obama")').should be_true
      end
    end

    context "when a blank phrase query is specified" do
      subject { described_class.new(query: 'government', query_quote: ' ') }
      it "should not include a phrase query in the url" do
        subject.query.start_with?('(government)')
      end
    end

    context "when OR terms are specified" do
      subject { described_class.new(query: 'government', query_or: 'barack obama') }
      it "should construct a query string that includes the OR terms OR'ed together" do
        subject.query.start_with?('(government (barack OR obama))')
      end
    end

    context "when the OR query is blank" do
      subject { described_class.new(query: 'government', query_or: ' ') }
      it "should not include an OR query parameter in the query string" do
        subject.query.start_with?('(government)')
      end
    end

    context "when negative query terms are specified" do
      subject { described_class.new(query: 'government', query_not: 'barack obama') }
      it "should construct a query string that includes the negative query terms prefixed with '-'" do
        subject.query.start_with?('(government -barack -obama)')
      end
    end

    context "when the negative query is blank" do
      subject { described_class.new(query: 'government', query_not: ' ') }
      it "should not include a negative query parameter in the query string" do
        subject.query.start_with?('(government)')
      end
    end

    context "when a filetype is specified" do
      context "when the filetype specified is not 'All'" do
        subject { described_class.new(query: 'government', file_type: 'pdf') }
        it "should construct a query string that includes a filetype" do
          subject.query.start_with?('(government filetype:pdf)')
        end
      end

      context "when the filetype specified is 'All'" do
        subject { described_class.new(query: 'government', file_type: 'All') }
        it "should construct a query string that does not have a filetype parameter" do
          subject.query.start_with?('(government)')
        end
      end

      context "when a blank filetype is passed in" do
        subject { described_class.new(query: 'government', file_type: ' ') }
        it "should not put filetype parameters in the query string" do
          subject.query.start_with?('(government)')
        end
      end
    end

    context "when multiple or all of the advanced query parameters are specified" do
      subject { described_class.new(query_quote: 'barack obama',
                                    query_or: 'cars stimulus',
                                    query_not: 'clunkers',
                                    file_type: 'pdf',
                                    site_limits: 'whitehouse.gov omb.gov',
                                    site_excludes: 'nasa.gov noaa.gov',
                                    query: 'government') }
      it "should construct a query string that incorporates all of them with the proper spacing" do
        subject.query.start_with?('(government "barack obama" -clunkers (cars OR stimulus) filetype:pdf -site:nasa.gov -site:noaa.gov)')
      end
    end
  end

  context 'when no included domains specified' do
    context 'when searcher specifies site:' do
      subject { described_class.new(query: 'government site:answers.foo.com') }

      it 'should allow site search in query' do
        subject.query.should == '(government site:answers.foo.com)'
      end
    end

    context "when one or more site exclusions is specified" do
      subject { described_class.new(query: 'government', site_excludes: 'whitehouse.gov omb.gov') }

      it "should construct a query string with site exlcusions for each of the sites" do
        subject.query.should == '(government -site:whitehouse.gov -site:omb.gov)'
      end

    end
  end

  context "when -site: in query" do

    context "when excluded domains present" do
      subject { described_class.new(query: 'government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it "should override excluded domains in query" do
        subject.query.should == '(government -site:exclude3.gov)'
      end
    end

    context 'when no excluded domains specified' do
      subject { described_class.new(query: 'government -site:exclude3.gov') }

      it 'should allow -site search in query' do
        subject.query.should == '(government -site:exclude3.gov)'
      end
    end
  end

  context "when included domains present" do
    let(:included_domains) { %w(foo.com bar.com) }

    context "when searcher doesn't specify -site: in query" do
      context "when excluded domains present" do
        subject { described_class.new(query: 'government', included_domains: included_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

        it "should send those excluded domains in query" do
          subject.query.should == '(government) (-site:exclude1.gov AND -site:exclude2.gov) (site:bar.com OR site:foo.com)'
        end
      end

      context "when excluded domains absent" do
        subject { described_class.new(query: 'government', included_domains: included_domains) }
        it "should use included domains in query without passing default ScopeID" do
          subject.query.should == '(government) (site:bar.com OR site:foo.com)'
        end
      end
    end

    context "when there are so many included domains that the overall query exceeds the search engine's limit, generating an error" do
      let(:too_many_domains) { "superlongdomain10001".upto("superlongdomain10175").collect { |x| "#{x}.gov" } }
      subject { described_class.new(query: 'government', included_domains: too_many_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it "should use as many as it can up to the predetermined limit" do
        subject.query.length.should < described_class::QUERY_STRING_ALLOCATION
      end
    end

    context "when scope keywords are specified" do
      subject { described_class.new(query: 'government', included_domains: included_domains, scope_keywords: %w(patents america flying)) }

      it "should limit the query with those keywords" do
        subject.query.should == '(government) (site:bar.com OR site:foo.com) ("patents" OR "america" OR "flying")'
      end
    end

    context "when searcher specifies site: outside included domains" do
      subject { described_class.new(query: 'government site:foobar.com', included_domains: included_domains) }

      it "should remove site: from query" do
        subject.query.should == '(government) (site:bar.com OR site:foo.com)'
      end
    end

    context "when searcher specifies site: within included domains" do
      subject { described_class.new(query: 'government site:answers.foo.com', included_domains: included_domains) }

      it "should override affiliate domains in query" do
        subject.query.should == '(government site:answers.foo.com)'
      end
    end

    context "when searcher specifies sitelimit: within included domains" do
      subject { described_class.new(query: 'government', included_domains: included_domains, site_limits: 'www.foo.com') }

      it "should set the query with the site limits" do
        subject.query.should == '(government) (site:www.foo.com)'
      end
    end

    context "when searcher specifies sitelimit: outside included domains" do
      subject { described_class.new(query: 'government', included_domains: included_domains, site_limits: 'doesnotexist.gov') }

      it "should query the affiliates normal domains" do
        subject.query.should == '(government) (site:bar.com OR site:foo.com)'
      end
    end
  end
end