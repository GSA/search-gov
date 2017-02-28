require 'spec_helper'

describe BingFormattedQuery do

  context "when -site: in user query" do
    context "when excluded domains present" do
      subject { BingFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it "should override excluded domains in query" do
        subject.query.should == '(government -site:exclude3.gov) language:en'
      end
    end

    context 'when no excluded domains specified' do
      subject { BingFormattedQuery.new('government -site:exclude3.gov') }

      it 'should allow -site search in query' do
        subject.query.should == '(government -site:exclude3.gov) language:en'
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
            subject.query.should == '(government) language:en -site:exclude2.gov -site:exclude1.gov (site:bar.com OR site:foo.com)'
          end
        end

        context "when excluded domains absent" do
          subject { BingFormattedQuery.new('government', included_domains: included_domains) }
          it "should use included domains in query without passing default ScopeID" do
            subject.query.should == '(government) language:en (site:bar.com OR site:foo.com)'
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

      context "when there are some included domains and too many excluded domains" do
        let(:some_domains) { "domain10001".upto("domain10010").collect { |x| "#{x}.gov" } }
        let(:too_many_excluded_domains) { "superlongexcludeddomain20001".upto("superlongexcludeddomain20110").collect { |x| "#{x}.gov" } }
        subject { BingFormattedQuery.new('government', included_domains: some_domains, excluded_domains: too_many_excluded_domains) }

        it "should use all the included domains and as many excluded domains as it can up to the predetermined limit" do
          subject.query.length.should < BingFormattedQuery::QUERY_STRING_ALLOCATION
          subject.query.should == "(government) language:en -site:superlongexcludeddomain20030.gov -site:superlongexcludeddomain20029.gov -site:superlongexcludeddomain20028.gov -site:superlongexcludeddomain20027.gov -site:superlongexcludeddomain20026.gov -site:superlongexcludeddomain20025.gov -site:superlongexcludeddomain20024.gov -site:superlongexcludeddomain20023.gov -site:superlongexcludeddomain20022.gov -site:superlongexcludeddomain20021.gov -site:superlongexcludeddomain20020.gov -site:superlongexcludeddomain20019.gov -site:superlongexcludeddomain20018.gov -site:superlongexcludeddomain20017.gov -site:superlongexcludeddomain20016.gov -site:superlongexcludeddomain20015.gov -site:superlongexcludeddomain20014.gov -site:superlongexcludeddomain20013.gov -site:superlongexcludeddomain20012.gov -site:superlongexcludeddomain20011.gov -site:superlongexcludeddomain20010.gov -site:superlongexcludeddomain20009.gov -site:superlongexcludeddomain20008.gov -site:superlongexcludeddomain20007.gov -site:superlongexcludeddomain20006.gov -site:superlongexcludeddomain20005.gov -site:superlongexcludeddomain20004.gov -site:superlongexcludeddomain20003.gov -site:superlongexcludeddomain20002.gov -site:superlongexcludeddomain20001.gov (site:domain10010.gov OR site:domain10009.gov OR site:domain10008.gov OR site:domain10007.gov OR site:domain10006.gov OR site:domain10005.gov OR site:domain10004.gov OR site:domain10003.gov OR site:domain10002.gov OR site:domain10001.gov)"
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov') }

        it 'should assign matching_site_limits to just the site limits that match included domains' do
          subject.query.should == '(government) language:en (site:foo.com/subdir2 OR site:foo.com/subdir1)'
          subject.matching_site_limits.should == %w(foo.com/subdir1 foo.com/subdir2)
        end
      end

      context "when searcher specifies sitelimit: outside included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, site_limits: 'doesnotexist.gov') }

        it "should query the affiliates normal domains" do
          subject.query.should == '(government) language:en (site:bar.com OR site:foo.com)'
          subject.matching_site_limits.should be_empty
        end
      end
    end
  end

  context "when scope ids are specified" do
    context "when included domains present in Bing search" do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when searcher specifies site: within included domains" do
        subject { BingFormattedQuery.new('government site:answers.foo.com', included_domains: included_domains, scope_ids: %w(PatentClass)) }

        it "should not pass the scope id along with the query" do
          subject.query.should == '(government site:answers.foo.com) language:en'
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { BingFormattedQuery.new('government', included_domains: included_domains, scope_ids: %w(PatentClass), site_limits: 'www.foo.com') }

        it "should set the query with the site limits" do
          subject.query.should == '(government) language:en (site:www.foo.com)'
        end
      end
    end
  end

  context 'when no included domains specified in Bing search' do
    context 'when no other filters specified' do
      subject { BingFormattedQuery.new('government') }

      it "should use just query string and default ScopeID/gov/mil combo" do
        subject.query.should == '(government) language:en (scopeid:usagovall OR site:gov OR site:mil)'
      end
    end

    context "when a scope id is provided" do
      subject { BingFormattedQuery.new('government', scope_ids: %w(PatentClass)) }

      it "should use the query with the scope provided" do
        subject.query.should == '(government) language:en (scopeid:PatentClass)'
      end
    end

    context "when one or more site exclusions is specified" do
      context "when a blank site exclude is passed" do
        subject { BingFormattedQuery.new('government', site_excludes: ' ') }
        it "should not include site exclude in the query string" do
          subject.query.should == '(government) language:en (scopeid:usagovall OR site:gov OR site:mil)'
        end
      end
    end

    context "when -site:, excluded domains, and scope id present" do
      subject { BingFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov), scope_ids: %w(PatentClass)) }

      it "should use the query along with the scope id" do
        subject.query.should == '(government -site:exclude3.gov) language:en (scopeid:PatentClass)'
      end
    end

    context 'language is not supported by Bing' do
      fixtures :languages
      let(:language) { languages(:kl) }
      before do
        I18n.locale = :kl
      end

      it 'does not send a language param to Bing' do
        language.is_bing_supported.should be false
        BingFormattedQuery.new('government').query.should == '(government) (scopeid:usagovall OR site:gov OR site:mil)'
      end

      after do
        I18n.locale = I18n.default_locale
      end

    end
  end

  it 'downcases the query' do
    query =  BingFormattedQuery.new('Egypt').query
    expect(query).to match /egypt/
  end

  context 'when the query includes search operators' do
    let(:query_with_operators) { 'Egypt OR Morocco' }

    it 'preserves the case of search operators' do
      query = BingFormattedQuery.new(query_with_operators).query
      expect(query).to match /egypt OR morocco/
    end
  end
end
