shared_examples 'a search domain object' do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  it { is_expected.to belong_to :affiliate }

  describe '.create' do
    it { is_expected.to validate_presence_of :domain }
    it { is_expected.to validate_presence_of :affiliate }

    %w(foo..gov weird.tldeer some.gov/page.html usda.gov/nal/index.php?info=4&t=1&ts=358 dod.mil/p/mhf?sd=20.0.0 some.mil/?sd=20 bts.gov/x/.).each do |bad|
      it { is_expected.not_to allow_value(bad).for(:domain) }
    end
    %w(foo.gov .mil .info .miami www.bar.gov www.bar.gov/subdir blat.gov/subdir).each do |good|
      it { is_expected.to allow_value(good).for(:domain) }
    end
    specify { expect(affiliate.site_domains.create!(domain: 'usa.gov').site_name).to eq('usa.gov') }
    specify { expect(affiliate.site_domains.create!(domain: 'usa.gov/subdir/').domain).to eq('usa.gov/subdir') }

    context 'when domain starts with /https?/' do
      %w(http://www.USA.gov https://www.usa.gov).each do |domain|
        subject { affiliate.site_domains.create!(domain: domain) }

        its(:domain) { should == 'www.usa.gov' }
        its(:site_name) { should == 'www.usa.gov' }
      end
    end

  end

end
