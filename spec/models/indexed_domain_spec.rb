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
  it { should validate_uniqueness_of(:domain).scoped_to(:affiliate_id) }

  it "should create a new instance given valid attributes" do
    IndexedDomain.create!(@valid_attributes)
  end

end