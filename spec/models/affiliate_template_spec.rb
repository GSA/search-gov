require 'spec_helper'

describe AffiliateTemplate do
  it { is_expected.to belong_to :affiliate }
  it { is_expected.to belong_to :template }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:affiliate_id) }
    it { is_expected.to validate_presence_of(:template_id) }
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:affiliate_id).of_type(:integer).with_options(null: false) }
    #The template_class column has been deprectated. It will be dropped in a future migration..
    it { is_expected.to have_db_column(:template_class).of_type(:string).with_options(null: true) }
    #The available column has been deprectated. It will be dropped in a future migration..
    it { is_expected.to have_db_column(:available).of_type(:boolean).with_options(null: false, default: true) }
    it { is_expected.to have_db_index([:affiliate_id, :template_class]).unique(true) }
    it { is_expected.to have_db_index([:affiliate_id, :template_id]).unique(true) }
  end
end
