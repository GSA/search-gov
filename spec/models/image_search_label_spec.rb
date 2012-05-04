require 'spec/spec_helper'

describe ImageSearchLabel do
  let(:en_affiliate) { Affiliate.create!(:display_name => 'en Affiliate')}
  let(:es_affiliate) { Affiliate.create!(:display_name => 'es Affiliate', :locale => 'es')}

  it { should validate_presence_of :affiliate_id }

  describe "#create" do
    it "should not allow blank name" do
      en_affiliate.image_search_label.name.should == 'Images'
      es_affiliate.image_search_label.name.should == 'Imágenes'
    end

    it "should have active Navigation with position 0" do
      navigation = en_affiliate.image_search_label.navigation
      navigation.position.should == 0
      navigation.should be_is_active
    end
  end

  describe "#save" do
    it "should not allow blank name" do
      image_search_label = en_affiliate.image_search_label
      image_search_label.update_attributes!(:name => '')
      image_search_label.name.should == 'Images'

      image_search_label = es_affiliate.image_search_label
      image_search_label.update_attributes!(:name => '  ')
      image_search_label.name.should == 'Imágenes'
    end
  end
end
