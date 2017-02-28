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
            subject.query.should == 'government -site:exclude2.gov -site:exclude1.gov site:bar.com OR site:foo.com'
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


      context "when there are some included domains and too many excluded domains" do
        let(:some_domains) { "domain10001".upto("domain10010").collect { |x| "#{x}.gov" } }
        let(:too_many_excluded_domains) { "superlongexcludeddomain20001".upto("superlongexcludeddomain20110").collect { |x| "#{x}.gov" } }
        subject { GoogleFormattedQuery.new('government', included_domains: some_domains, excluded_domains: too_many_excluded_domains) }

        it "should use all the included domains and as many excluded domains as it can up to the predetermined limit" do
          subject.query.length.should < GoogleFormattedQuery::QUERY_STRING_ALLOCATION
          subject.query.should == "government -site:superlongexcludeddomain20030.gov -site:superlongexcludeddomain20029.gov -site:superlongexcludeddomain20028.gov -site:superlongexcludeddomain20027.gov -site:superlongexcludeddomain20026.gov -site:superlongexcludeddomain20025.gov -site:superlongexcludeddomain20024.gov -site:superlongexcludeddomain20023.gov -site:superlongexcludeddomain20022.gov -site:superlongexcludeddomain20021.gov -site:superlongexcludeddomain20020.gov -site:superlongexcludeddomain20019.gov -site:superlongexcludeddomain20018.gov -site:superlongexcludeddomain20017.gov -site:superlongexcludeddomain20016.gov -site:superlongexcludeddomain20015.gov -site:superlongexcludeddomain20014.gov -site:superlongexcludeddomain20013.gov -site:superlongexcludeddomain20012.gov -site:superlongexcludeddomain20011.gov -site:superlongexcludeddomain20010.gov -site:superlongexcludeddomain20009.gov -site:superlongexcludeddomain20008.gov -site:superlongexcludeddomain20007.gov -site:superlongexcludeddomain20006.gov -site:superlongexcludeddomain20005.gov -site:superlongexcludeddomain20004.gov -site:superlongexcludeddomain20003.gov -site:superlongexcludeddomain20002.gov -site:superlongexcludeddomain20001.gov site:domain10010.gov OR site:domain10009.gov OR site:domain10008.gov OR site:domain10007.gov OR site:domain10006.gov OR site:domain10005.gov OR site:domain10004.gov OR site:domain10003.gov OR site:domain10002.gov OR site:domain10001.gov"
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

  it 'downcases the query' do
    query =  GoogleFormattedQuery.new('Egypt').query
    expect(query).to match /egypt/
  end

  context 'when the query includes search operators' do
    let(:query_with_operators) { 'Egypt OR Morocco' }

    it 'preserves the case of search operators' do
      query = GoogleFormattedQuery.new(query_with_operators).query
      expect(query).to match /egypt OR morocco/
    end
  end
end
