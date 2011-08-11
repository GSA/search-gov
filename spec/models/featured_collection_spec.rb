require 'spec/spec_helper'

describe FeaturedCollection do
  fixtures :affiliates
  it { should validate_presence_of :title }
  it { should have_attached_file :image }
  it { should validate_attachment_content_type(:image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

  SUPPORTED_LOCALES.each do |locale|
    it { should allow_value(locale).for(:locale) }
  end
  it { should_not allow_value("invalid_locale").for(:locale) }

  FeaturedCollection::STATUSES.each do |status|
    it { should allow_value(status).for(:status) }
  end
  it { should_not allow_value("bogus status").for(:locale) }

  it { should belong_to :affiliate }
  it { should have_many(:featured_collection_keywords).dependent(:destroy) }
  it { should have_many(:featured_collection_links).dependent(:destroy) }

  it "should have one or more keywords" do
    featured_collection = FeaturedCollection.create(:title => 'test title', :locale => 'en', :status => 'active')
    featured_collection.errors.full_messages.join.should =~ /One or more keywords are required/
  end

  it "should not allow publish start date before publish end date" do
    featured_collection = FeaturedCollection.create(:title => 'test title',
                                                    :locale => 'en',
                                                    :status => 'active',
                                                    :publish_start_on => '07/01/2012',
                                                    :publish_end_on => '07/01/2011')
    featured_collection.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
  end

  describe "#display_status" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:active_featured_collection) { active_featured_collection = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                                                                         :locale => 'en',
                                                                                                         :status => 'active')
      active_featured_collection.featured_collection_keywords.build(:value => 'test')
      active_featured_collection.save!
      active_featured_collection
    }
    let(:inactive_featured_collection) { inactive_featured_collection = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                                                                             :locale => 'en',
                                                                                                             :status => 'inactive')
      inactive_featured_collection.featured_collection_keywords.build(:value => 'another test')
      inactive_featured_collection.save!
      inactive_featured_collection
    }

    context "when status is active" do
      specify { active_featured_collection.display_status.should == 'Active' }
    end

    context "when status is inactive" do
      specify { inactive_featured_collection.display_status.should == 'Inactive' }
    end
  end

  describe "#update_attributes" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:image) { mock('image') }
    let(:featured_collection) do
      featured_collection = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                                 :locale => 'en',
                                                                 :status => 'active')
      featured_collection.featured_collection_keywords.build(:value => 'test')
      featured_collection.save!
      featured_collection
    end

    context "when there is an existing image" do
      before do
        featured_collection.should_receive(:image?).and_return(true)
        featured_collection.should_receive(:image).at_least(:once).and_return(image)
      end

      context "when marking an existing image for deletion" do
        it "should clear existing image" do
          image.should_receive(:dirty?).and_return(false)
          image.should_receive(:clear)
          featured_collection.update_attributes({ :mark_image_for_deletion => '1'})
        end
      end

      context "when uploading a new image" do
        it "should not clear the existing image" do
          image.should_receive(:dirty?).and_return(true)
          image.should_not_receive(:clear)
          featured_collection.update_attributes({ :title => 'updated'})
        end
      end
    end

    context "when there is no existing image" do
      it "should not clear image" do
        featured_collection.should_receive(:image?).and_return(false)
        image.should_not_receive(:clear)
        featured_collection.update_attributes(:title => 'new title')
      end
    end
  end
end
