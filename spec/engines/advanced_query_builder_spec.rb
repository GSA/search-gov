require 'spec_helper'

describe AdvancedQueryBuilder do
  context 'when included domains specified' do
    let(:included_domains) { %w(foo.com bar.com) }

    context 'when one or more site exclusions is specified' do
      subject { described_class.new(included_domains, query: 'government', site_excludes: 'whitehouse.gov omb.gov') }

      it 'should construct a query string with site exlcusions for each of the sites, ignoring the included domains' do
        expect(subject.build).to eq('government -site:whitehouse.gov -site:omb.gov')
      end

    end

    context 'when searcher specifies site: outside included domains' do
      subject { described_class.new(included_domains, query: 'government site:foobar.com') }

      it 'should remove site: from query' do
        expect(subject.build).to eq('government')
      end
    end

    context 'when searcher specifies site: within included domains' do
      subject { described_class.new(included_domains, query: 'government site:answers.foo.com site:bar.com') }

      it 'should override affiliate domains in query' do
        expect(subject.build).to eq('government site:answers.foo.com site:bar.com')
      end
    end
  end

  context 'when a phrase query is specified' do
    subject { described_class.new([], query: 'government', query_quote: 'barack obama') }

    it 'should construct a query string that includes the phrase in quotes' do
      expect(subject.build).to eq('government "barack obama"')
    end
  end

  context 'when OR terms are specified' do
    subject { described_class.new([], query: 'government', query_or: 'barack obama') }
    it "should construct a query string that includes the OR terms OR'ed together" do
      expect(subject.build).to eq('government (barack OR obama)')
    end
  end

  context 'when negative query terms are specified' do
    subject { described_class.new([], query: 'government', query_not: 'barack obama') }
    it "should construct a query string that includes the negative query terms prefixed with '-'" do
      expect(subject.build).to eq('government -barack -obama')
    end
  end

  context 'when a filetype is specified' do
    context "when the filetype specified is not 'All'" do
      subject { described_class.new([], query: 'government', file_type: 'pdf') }
      it 'should construct a query string that includes a filetype' do
        expect(subject.build).to eq('government filetype:pdf')
      end
    end

    context "when the filetype specified is 'All'" do
      subject { described_class.new([], query: 'government', file_type: 'All') }
      it 'should construct a query string that does not have a filetype parameter' do
        expect(subject.build).to eq('government')
      end
    end

  end

  context 'when multiple or all of the advanced query parameters are specified' do
    subject { described_class.new([], query_quote: 'barack obama',
                                       query_or: 'cars stimulus',
                                       query_not: 'clunkers',
                                       file_type: 'pdf',
                                       site_excludes: 'nasa.gov noaa.gov',
                                       query: 'government site:.gov') }
    it 'should construct a query string that incorporates all of them' do
      expect(subject.build).to eq('government site:.gov "barack obama" -clunkers (cars OR stimulus) filetype:pdf -site:nasa.gov -site:noaa.gov')
    end
  end

  context 'when no included domains specified' do
    context 'when searcher specifies site:' do
      subject { described_class.new([], query: 'government site:answers.foo.com') }

      it 'should allow site search in query' do
        expect(subject.build).to eq('government site:answers.foo.com')
      end
    end

    context 'when one or more site exclusions is specified' do
      subject { described_class.new([], query: 'government', site_excludes: 'whitehouse.gov omb.gov') }

      it 'should construct a query string with site exlcusions for each of the sites' do
        expect(subject.build).to eq('government -site:whitehouse.gov -site:omb.gov')
      end

    end
  end


end