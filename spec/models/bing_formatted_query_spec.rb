require 'spec_helper'

describe BingFormattedQuery do
  it_behaves_like "a formatted query"

  context "when scope ids are specified" do
    context "when included domains present in Bing search" do
      let(:included_domains) { %w(foo.com bar.com) }

      context "when scope keywords are specified" do
        subject { BingFormattedQuery.new(query: 'government', included_domains: included_domains, scope_ids: %w(PatentClass), scope_keywords: %w(patents america flying)) }

        it "should limit the query with the scope ids and keywords" do
          subject.query.should == '(government) (scopeid:PatentClass OR site:bar.com OR site:foo.com) ("patents" OR "america" OR "flying")'
        end
      end

      context "when searcher specifies site: outside included domains" do
        subject { BingFormattedQuery.new(query: 'government site:blat.gov', included_domains: included_domains, scope_ids: %w(PatentClass OtherClass)) }

        it "should use the query along with the scope id" do
          subject.query.should == '(government) (scopeid:PatentClass OR scopeid:OtherClass OR site:bar.com OR site:foo.com)'
        end
      end

      context "when searcher specifies site: within included domains" do
        subject { BingFormattedQuery.new(query: 'government site:answers.foo.com', included_domains: included_domains, scope_ids: %w(PatentClass)) }

        it "should not pass the scope id along with the query" do
          subject.query.should == '(government site:answers.foo.com)'
        end
      end

      context "when searcher specifies sitelimit: within included domains" do
        subject { BingFormattedQuery.new(query: 'government', included_domains: included_domains, scope_ids: %w(PatentClass), site_limits: 'www.foo.com') }

        it "should set the query with the site limits" do
          subject.query.should == '(government) (site:www.foo.com)'
        end
      end
    end
  end

  context 'when no included domains specified in Bing search' do
    context 'when no other filters specified' do
      subject { BingFormattedQuery.new(query: 'government') }

      it "should use just query string and default ScopeID/gov/mil combo" do
        subject.query.should == '(government) (scopeid:usagovall OR site:gov OR site:mil)'
      end
    end

    context "when a scope id is provided" do
      subject { BingFormattedQuery.new(query: 'government', scope_ids: %w(PatentClass)) }

      it "should use the query with the scope provided" do
        subject.query.should == '(government) (scopeid:PatentClass)'
      end
    end

    context "when one or more site exclusions is specified" do
      context "when a blank site exclude is passed" do
        subject { BingFormattedQuery.new(query: 'government', site_excludes: ' ') }
        it "should not include site exclude in the query string" do
          subject.query.should == '(government) (scopeid:usagovall OR site:gov OR site:mil)'
        end
      end
    end

    context "when -site:, excluded domains, and scope id present" do
      subject { BingFormattedQuery.new(query: 'government -site:exclude3.gov', excluded_domains: %w(exclude1.gov exclude2.gov), scope_ids: %w(PatentClass)) }

      it "should use the query along with the scope id" do
        subject.query.should == '(government -site:exclude3.gov) (scopeid:PatentClass)'
      end
    end
  end
end