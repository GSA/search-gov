shared_examples "a search domain object" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  it { should belong_to :affiliate }

  describe ".create" do
    it { should validate_presence_of :domain }
    it { should validate_presence_of :affiliate }

    %w(foo..gov weird.tldeer some.gov/page.html usda.gov/nal/index.php?info=4&t=1&ts=358 dod.mil/p/mhf?sd=20.0.0 some.mil/?sd=20 bts.gov/x/.).each do |bad|
      it { should_not allow_value(bad).for(:domain) }
    end
    %w(foo.gov .mil .info .miami www.bar.gov www.bar.gov/subdir blat.gov/subdir).each do |good|
      it { should allow_value(good).for(:domain) }
    end
    specify { affiliate.site_domains.create!(:domain => 'usa.gov').site_name.should == 'usa.gov' }
    specify { affiliate.site_domains.create!(:domain => 'usa.gov/subdir/').domain.should == 'usa.gov/subdir' }

    context "when domain starts with /https?/ or www" do
      %w(http://USA.gov https://usa.gov https://www.usa.gov).each do |domain|
        subject { affiliate.site_domains.create!(:domain => domain) }

        its(:domain) { should == 'usa.gov' }
        its(:site_name) { should == 'usa.gov' }
      end
    end

  end

end
