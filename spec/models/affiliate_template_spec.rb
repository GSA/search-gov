require 'spec_helper'

describe AffiliateTemplate do
  fixtures :affiliate_templates, :affiliates

  before { subject.stub(:valid_template_subclass?).and_return(true) }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:template_class) }

  describe 'schema' do
    it { should have_db_column(:affiliate_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:template_class).of_type(:string).with_options(null: false) }
    it { should have_db_column(:available).of_type(:boolean).with_options(null: false, default: true) }
    it { should have_db_index([:affiliate_id, :template_class]).unique(true) }
  end

  describe ".hidden" do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template_classic) { affiliate_templates(:usagov_classic) }
    let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link) }

    it "returns an array of the non-active templates as virtual attributes" do
      expect(affiliate.affiliate_templates.hidden.count).to eq 3
    end
  end

  describe "#human_readable_name" do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "returns the human readable name of the Template Class" do
      expect(affiliate.affiliate_template.human_readable_name).to eq "Classic"
    end
  end
end
