require 'spec_helper'

describe FormAgency do
  it { should validate_presence_of :name }
  it { should validate_presence_of :locale }
  it { should validate_presence_of :display_name }
  it { should have_many(:forms).dependent(:destroy) }
  it { should have_and_belong_to_many(:affiliates) }

  describe '#to_label' do
    it 'should return with [locale] name' do
      fa = FormAgency.create!(:name => 'uscis.gov',
                              :locale => 'en',
                              :display_name => 'U.S. Citizenship and Immigration Services')
      fa.to_label.should == '[en] uscis.gov'
    end
  end
end
