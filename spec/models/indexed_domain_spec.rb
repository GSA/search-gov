require 'spec/spec_helper'

describe IndexedDomain do
  fixtures :indexed_domains, :affiliates
  before do
    @valid_attributes = {
      :domain => 'foobar.gov',
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end

  it { should validate_presence_of :domain }
  it { should validate_presence_of :affiliate_id }
  it { should belong_to :affiliate }
  it { should have_many :indexed_documents }
  it { should have_many :common_substrings }
  it { should validate_uniqueness_of(:domain).scoped_to(:affiliate_id) }

  it "should create a new instance given valid attributes" do
    IndexedDomain.create!(@valid_attributes)
  end

  describe "#label" do
    it "should return the domain" do
      indexed_domains(:sample).label.should == indexed_domains(:sample).domain
    end
  end

  describe "#self.detect_templates" do
    it "should enqueue with low priority an IndexedDomainTemplateDetector for each IndexedDomain" do
      Resque.should_receive(:enqueue_with_priority).with(:low, IndexedDomainTemplateDetector, indexed_domains(:sample).id)
      Resque.should_receive(:enqueue_with_priority).with(:low, IndexedDomainTemplateDetector, indexed_domains(:another).id)
      IndexedDomain.detect_templates
    end
  end

end