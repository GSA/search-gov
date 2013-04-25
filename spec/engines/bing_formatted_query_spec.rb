require 'spec_helper'

describe BingFormattedQuery do

  context "when -site: in user query" do
    context "when excluded domains present" do
      subject { BingFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it "should override excluded domains in query" do
        subject.query.should == '(government -site:exclude3.gov)'
      end
    end

    context 'when no excluded domains specified' do
      subject { BingFormattedQuery.new('government -site:exclude3.gov') }

      it 'should allow -site search in query' do
        subject.query.should == '(government -site:exclude3.gov)'
      end
    end
  end

  describe 'included domains' do

    context "when included domains present" do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when searcher doesn't specify -site: in query" do
        context "when excluded domains present" do
          subject { BingFormattedQuery.new('government', included_domains: included_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

          it "should send those excluded domains in query" do
            subject.query.should == '(government) (-site:exclude1.gov AND -site:exclude2.gov) (site:bar.com OR site:foo.com)'
          end
        end

        context "when excluded domains absent" do
          subject { BingFormattedQuery.new('government', included_domains: included_domains) }
          it "should use included domains in query without passing default ScopeID" do
            subject.query.should == '(government) (site:bar.com OR site:foo.com)'
          end
        end
      end

      context "when there are so many included domains that the overall query exceeds the search engine's limit, generating an error" do
        let(:too_many_domains) { "superlongdomain10001".upto("superlongdomain10175").collect { |x| "#{x}.gov" } }
        subject { BingFormattedQuery.new('government', included_domains: too_many_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

        it "should use as many as it can up to the predetermined limit" do
          subject.query.length.should < BingFormattedQuery::QUERY_STRING_ALLOCATION
        end
      end

      context "when scope keywords are specified" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, scope_keywords: %w(patents america flying)) }

        it "should limit the query with those keywords" do
          subject.query.should == '(government) (site:bar.com OR site:foo.com) ("patents" OR "america" OR "flying")'
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov') }

        it 'should assign matching_site_limits to just the site limits that match included domains' do
          subject.query.should == '(government) (site:foo.com/subdir2 OR site:foo.com/subdir1)'
          subject.matching_site_limits.should == %w(foo.com/subdir1 foo.com/subdir2)
        end
      end

      context "when searcher specifies sitelimit: outside included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, site_limits: 'doesnotexist.gov') }

        it "should query the affiliates normal domains" do
          subject.query.should == '(government) (site:bar.com OR site:foo.com)'
          subject.matching_site_limits.should be_empty
        end
      end
    end
  end

  context "when scope ids are specified" do
    context "when included domains present in Bing search" do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when scope keywords are specified" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, scope_ids: %w(PatentClass), scope_keywords: %w(patents america flying)) }

        it "should limit the query with the scope ids and keywords" do
          subject.query.should == '(government) (scopeid:PatentClass OR site:bar.com OR site:foo.com) ("patents" OR "america" OR "flying")'
        end
      end

      context "when searcher specifies site: within included domains" do
        subject { BingFormattedQuery.new('government site:answers.foo.com', included_domains: included_domains, scope_ids: %w(PatentClass)) }

        it "should not pass the scope id along with the query" do
          subject.query.should == '(government site:answers.foo.com)'
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, scope_ids: %w(PatentClass), site_limits: 'www.foo.com') }

        it "should set the query with the site limits" do
          subject.query.should == '(government) (site:www.foo.com)'
        end
      end
    end
  end

  context 'when no included domains specified in Bing search' do
    context 'when no other filters specified' do
      subject { BingFormattedQuery.new('government') }

      it "should use just query string and default ScopeID/gov/mil combo" do
        subject.query.should == '(government) (scopeid:usagovall OR site:gov OR site:mil)'
      end
    end

    context "when a scope id is provided" do
      subject { BingFormattedQuery.new('government', scope_ids: %w(PatentClass)) }

      it "should use the query with the scope provided" do
        subject.query.should == '(government) (scopeid:PatentClass)'
      end
    end

    context "when one or more site exclusions is specified" do
      context "when a blank site exclude is passed" do
        subject { BingFormattedQuery.new('government', site_excludes: ' ') }
        it "should not include site exclude in the query string" do
          subject.query.should == '(government) (scopeid:usagovall OR site:gov OR site:mil)'
        end
      end
    end

    context "when -site:, excluded domains, and scope id present" do
      subject { BingFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov), scope_ids: %w(PatentClass)) }

      it "should use the query along with the scope id" do
        subject.query.should == '(government -site:exclude3.gov) (scopeid:PatentClass)'
      end
    end
  end
end