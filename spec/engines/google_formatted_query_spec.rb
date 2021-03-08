require 'spec_helper'

describe GoogleFormattedQuery do

  context 'when -site: in user query' do
    context 'when excluded domains present' do
      subject { GoogleFormattedQuery.new('government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov)) }

      it 'should override excluded domains in query' do
        expect(subject.query).to eq('government -site:exclude3.gov')
      end
    end

    context 'when no excluded domains specified' do
      subject { GoogleFormattedQuery.new('government -site:exclude3.gov') }

      it 'should allow -site search in query' do
        expect(subject.query).to eq('government -site:exclude3.gov')
      end
    end
  end

  describe 'included domains' do

    context 'when included domains present' do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when searcher doesn't specify -site: in query" do
        context 'when excluded domains present' do
          subject { GoogleFormattedQuery.new('government', included_domains: included_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

          it 'should send those excluded domains in query' do
            expect(subject.query).to eq('government -site:exclude2.gov AND -site:exclude1.gov site:bar.com OR site:foo.com')
          end
        end

        context 'when excluded domains absent' do
          subject { GoogleFormattedQuery.new('government', included_domains: included_domains) }
          it 'should use included domains in query without passing default ScopeID' do
            expect(subject.query).to eq('government site:bar.com OR site:foo.com')
          end
        end
      end

      context "when there are so many included domains that the overall query exceeds the search engine's limit, generating an error" do
        let(:too_many_domains) { 'superlongdomain10001'.upto('superlongdomain10175').collect { |x| "#{x}.gov" } }
        subject { GoogleFormattedQuery.new('government', included_domains: too_many_domains, excluded_domains: %w(exclude1.gov exclude2.gov)) }

        it 'should use as many as it can up to the predetermined limit' do
          expect(subject.query.length).to be < GoogleFormattedQuery::QUERY_STRING_ALLOCATION
        end
      end


      context 'when there are some included domains and too many excluded domains' do
        let(:some_domains) { 'domain10001'.upto('domain10010').collect { |x| "#{x}.gov" } }
        let(:too_many_excluded_domains) { 'superlongexcludeddomain20001'.upto('superlongexcludeddomain20110').collect { |x| "#{x}.gov" } }
        subject { GoogleFormattedQuery.new('government', included_domains: some_domains, excluded_domains: too_many_excluded_domains) }

        it 'should use all the included domains and as many excluded domains as it can up to the predetermined limit' do
          expect(subject.query.length).to be < GoogleFormattedQuery::QUERY_STRING_ALLOCATION
          expect(subject.query).to eq('government -site:superlongexcludeddomain20028.gov AND -site:superlongexcludeddomain20027.gov AND -site:superlongexcludeddomain20026.gov AND -site:superlongexcludeddomain20025.gov AND -site:superlongexcludeddomain20024.gov AND -site:superlongexcludeddomain20023.gov AND -site:superlongexcludeddomain20022.gov AND -site:superlongexcludeddomain20021.gov AND -site:superlongexcludeddomain20020.gov AND -site:superlongexcludeddomain20019.gov AND -site:superlongexcludeddomain20018.gov AND -site:superlongexcludeddomain20017.gov AND -site:superlongexcludeddomain20016.gov AND -site:superlongexcludeddomain20015.gov AND -site:superlongexcludeddomain20014.gov AND -site:superlongexcludeddomain20013.gov AND -site:superlongexcludeddomain20012.gov AND -site:superlongexcludeddomain20011.gov AND -site:superlongexcludeddomain20010.gov AND -site:superlongexcludeddomain20009.gov AND -site:superlongexcludeddomain20008.gov AND -site:superlongexcludeddomain20007.gov AND -site:superlongexcludeddomain20006.gov AND -site:superlongexcludeddomain20005.gov AND -site:superlongexcludeddomain20004.gov AND -site:superlongexcludeddomain20003.gov AND -site:superlongexcludeddomain20002.gov AND -site:superlongexcludeddomain20001.gov site:domain10010.gov OR site:domain10009.gov OR site:domain10008.gov OR site:domain10007.gov OR site:domain10006.gov OR site:domain10005.gov OR site:domain10004.gov OR site:domain10003.gov OR site:domain10002.gov OR site:domain10001.gov')
        end
      end

      context 'when searcher specifies sitelimit: within included domains' do
        subject { GoogleFormattedQuery.new('government', included_domains: included_domains, site_limits: 'foo.com/subdir1 foo.com/subdir2 include3.gov') }

        it 'should assign matching_site_limits to just the site limits that match included domains' do
          expect(subject.query).to eq('government site:foo.com/subdir2 OR site:foo.com/subdir1')
          expect(subject.matching_site_limits).to eq(%w(foo.com/subdir1 foo.com/subdir2))
        end
      end

      context 'when searcher specifies sitelimit: outside included domains' do
        subject { GoogleFormattedQuery.new('government', included_domains: included_domains, site_limits: 'doesnotexist.gov') }

        it 'should query the affiliates normal domains' do
          expect(subject.query).to eq('government site:bar.com OR site:foo.com')
          expect(subject.matching_site_limits).to be_empty
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
