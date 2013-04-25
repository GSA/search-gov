require 'spec_helper'

describe GoogleFormattedQuery do

  context "when -site: in user query" do
    context "when excluded domains present" do
      subject { GoogleFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it "should override excluded domains in query" do
        subject.query.should == 'government -site:exclude3.gov'
      end
    end

    context 'when no excluded domains specified' do
      subject { GoogleFormattedQuery.new('government -site:exclude3.gov') }

      it 'should allow -site search in query' do
        subject.query.should == 'government -site:exclude3.gov'
      end
    end
  end

  describe 'included domains' do

    context "when included domains present" do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when searcher doesn't specify -site: in query" do
        context "when excluded domains present" do
          subject { GoogleFormattedQuery.new('government', included_domains: included_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

          it "should send those excluded domains in query" do
            subject.query.should == 'government site:bar.com OR site:foo.com -site:exclude1.gov AND -site:exclude2.gov'
          end
        end

        context "when excluded domains absent" do
          subject { GoogleFormattedQuery.new('government', included_domains: included_domains) }
          it "should use included domains in query without passing default ScopeID" do
            subject.query.should == 'government site:bar.com OR site:foo.com'
          end
        end
      end

      context "when there are so many included domains that the overall query exceeds the search engine's limit, generating an error" do
        let(:too_many_domains) { "superlongdomain10001".upto("superlongdomain10175").collect { |x| "#{x}.gov" } }
        subject { GoogleFormattedQuery.new('government', included_domains: too_many_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

        it "should use as many as it can up to the predetermined limit" do
          subject.query.length.should < GoogleFormattedQuery::QUERY_STRING_ALLOCATION
        end
      end

      context "when scope keywords are specified" do
        subject { GoogleFormattedQuery.new('government', included_domains: included_domains, scope_keywords: %w(patents america flying)) }

        it "should limit the query with those keywords" do
          subject.query.should == 'government site:bar.com OR site:foo.com "patents" | "america" | "flying"'
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { GoogleFormattedQuery.new('government', included_domains: included_domains, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov') }

        it 'should assign matching_site_limits to just the site limits that match included domains' do
          subject.query.should == 'government site:foo.com/subdir2 OR site:foo.com/subdir1'
          subject.matching_site_limits.should == %w(foo.com/subdir1 foo.com/subdir2)
        end
      end

      context "when searcher specifies sitelimit: outside included domains" do
        subject { GoogleFormattedQuery.new('government', included_domains: included_domains, site_limits: 'doesnotexist.gov') }

        it "should query the affiliates normal domains" do
          subject.query.should == 'government site:bar.com OR site:foo.com'
          subject.matching_site_limits.should be_empty
        end
      end
    end
  end
end