require 'spec_helper'

describe AffiliateTemplate do
  it { should belong_to :affiliate }
  it { should belong_to :template }

  describe 'validations' do
    it { should validate_presence_of(:affiliate_id) }
    it { should validate_presence_of(:template_id) }
  end

  describe 'schema' do
    it { should have_db_column(:affiliate_id).of_type(:integer).with_options(null: false, index: true) }
    #The template_class column has been deprectated. It will be dropped in a future migration..
    it { should have_db_column(:template_class).of_type(:string).with_options(null: true) }
    #The available column has been deprectated. It will be dropped in a future migration..
    it { should have_db_column(:available).of_type(:boolean).with_options(null: false, default: true) }
    it { should have_db_index([:affiliate_id, :template_class]).unique(true) }
    it { should have_db_index([:affiliate_id, :template_id]).unique(true) }
  end
end
