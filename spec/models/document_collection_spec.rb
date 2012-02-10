require 'spec/spec_helper'

describe DocumentCollection do
  fixtures :affiliates, :document_collections, :url_prefixes

  before do
    @valid_attributes = {
      :name => 'My Collection',
      :affiliate => affiliates(:power_affiliate)
    }
  end

  describe "Creating new instance" do
    it { should belong_to :affiliate }
    it { should have_many(:url_prefixes).dependent(:destroy) }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).scoped_to(:affiliate_id) }
  end

end