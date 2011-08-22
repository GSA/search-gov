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
  it { should_not allow_value("bogus status").for(:status) }

  specify { FeaturedCollection.new(:status => 'active').should be_is_active }
  specify { FeaturedCollection.new(:status => 'active').should_not be_is_inactive }
  specify { FeaturedCollection.new(:status => 'inactive').should be_is_inactive }
  specify { FeaturedCollection.new(:status => 'inactive').should_not be_is_active }

  FeaturedCollection::LAYOUTS.each do |layout|
    it { should allow_value(layout).for(:layout) }
  end
  it { should_not allow_value("bogus layout").for(:layout) }

  specify { FeaturedCollection.new(:layout => 'one column').should be_has_one_column_layout }
  specify { FeaturedCollection.new(:layout => 'two column').should be_has_two_column_layout }

  it { should belong_to :affiliate }
  it { should have_many(:featured_collection_keywords).dependent(:destroy) }
  it { should have_many(:featured_collection_links).dependent(:destroy) }

  it "should have one or more keywords" do
    featured_collection = FeaturedCollection.create(:title => 'test title', :locale => 'en', :status => 'active', :layout => 'one column')
    featured_collection.errors.full_messages.join.should =~ /One or more keywords are required/
  end

  it "should not allow publish start date before publish end date" do
    featured_collection = FeaturedCollection.create(:title => 'test title',
                                                    :locale => 'en',
                                                    :status => 'active',
                                                    :layout => 'one column',
                                                    :publish_start_on => '07/01/2012',
                                                    :publish_end_on => '07/01/2011')
    featured_collection.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
  end

  describe "#display_status" do
    context "when status is set to active" do
      subject { FeaturedCollection.new(:status => 'active') }
      its(:display_status) { should == 'Active' }
    end

    context "when status is set to inactive" do
      subject { FeaturedCollection.new(:status => 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end

  describe "#update_attributes" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:image) { mock('image') }
    let(:featured_collection) do
      featured_collection = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                                 :locale => 'en',
                                                                 :status => 'active',
                                                                 :layout => 'one column')
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

  describe ".search_for" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when there is an active English featured collection without date range" do
      before do
        @featured_collection = affiliate.featured_collections.build(:title => 'Tropical Hurricane Names',
                                                                    :locale => 'en',
                                                                    :status => 'active',
                                                                    :layout => 'one column')
        @featured_collection.featured_collection_keywords.build(:value => 'typhoon')
        @featured_collection.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part1',
                                                             :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                             :position => '0')
        @featured_collection.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part2',
                                                             :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                             :position => '0')
        @featured_collection.save!

        inactive_featured_collection = affiliate.featured_collections.build(:title => 'Retired Hurricane names',
                                                                            :locale => 'en',
                                                                            :status => 'inactive',
                                                                            :layout => 'one column')
        inactive_featured_collection.featured_collection_keywords.build(:value => 'typhoon')
        inactive_featured_collection.featured_collection_links.build(:title => 'Retired Hurricane Names Since 1954',
                                                                     :url => 'http://www.nhc.noaa.gov/retirednames.shtml',
                                                                     :position => '0')
        inactive_featured_collection.save!

        FeaturedCollection.reindex
      end

      it "should return only active Featured Collections" do
        FeaturedCollection.search_for('tropical', affiliate, :en).results.each do |result|
          result.should be_is_active
        end
      end

      it "should return Featured Collection when searching for query term that exists in the title" do
        FeaturedCollection.search_for('tropical', affiliate, :en).results.first.should == @featured_collection
      end

      it "should return Featured Collection when searching for query term that exists in featured collection keywords" do
        FeaturedCollection.search_for('typhoon', affiliate, :en).results.first.should == @featured_collection
      end

      it "should return Featured Collection when searching for query term that exists in the link title" do
        FeaturedCollection.search_for('cyclone', affiliate, :en).results.first.should == @featured_collection
      end

      it "should highlight matching Featured Collection title" do
        highlighted_title = FeaturedCollection.search_for('tropical', affiliate, :en).hits.first.highlights(:title).first.format
        highlighted_title.should == "<em>Tropical</em> Hurricane Names"
      end

      it "should highlight matching Featured Collection link titles" do
        highlighted_link_titles = FeaturedCollection.search_for('tropical', affiliate, :en).hits.first.highlights(:link_titles).first.format.split(FeaturedCollection::LINK_TITLE_SEPARATOR)
        highlighted_link_titles.should include("Worldwide <em>Tropical</em> Cyclone Names Part1")
        highlighted_link_titles.should include("Worldwide <em>Tropical</em> Cyclone Names Part2")
      end

      it "should not return any result when searching for Spanish Featured Collection" do
        FeaturedCollection.search_for('tropical', affiliate, :es).results.should be_empty
      end
    end

    context "when there is an active English featured collection and current date is within publish date range" do
      before do
        @featured_collection_params = [
          { :title => 'past_publish_start_date',
            :publish_start_on => Date.current.prev_month },
          { :title => 'today',
            :publish_start_on => Date.current,
            :publish_end_on => Date.current },
          { :title => 'within_publish_date_range',
            :publish_start_on => Date.current.prev_month,
            :publish_end_on => Date.current.next_month },
          { :title => 'future_publish_end_date',
            :publish_end_on => Date.current.next_month }
        ]
        @featured_collection_params.each_with_index do |params, index|
          featured_collection = affiliate.featured_collections.build(:title => "Featured collection #{params[:title]}",
                                                                                 :locale => 'en',
                                                                                 :status => 'active',
                                                                                 :layout => 'one column',
                                                                                 :publish_start_on => params[:publish_start_on],
                                                                                 :publish_end_on => params[:publish_end_on])
          featured_collection.featured_collection_keywords.build(:value => "keyword#{index + 1}")
          featured_collection.save!

        end
        FeaturedCollection.reindex
      end

      it "should return featured_collections with past publish start date" do
        FeaturedCollection.search_for('past_publish_start_date', affiliate, :en).results.first.should_not be_blank
      end

      it "should return featured_collections with publish date range today" do
        FeaturedCollection.search_for('today', affiliate, :en).results.first.should_not be_blank
      end

      it "should return featured_collections within publish date range" do
        FeaturedCollection.search_for('within_publish_date_range', affiliate, :en).results.first.should_not be_blank
      end

      it "should return featured_collections with future publish end date" do
        FeaturedCollection.search_for('with_future_publish_end_date', affiliate, :en).results.first.should_not be_blank
      end
    end

    context "when there is an active English featured collection and current date is not within publish date range" do
      before do
        featured_collection_params = [
          { :title => 'past_publish_end_date',
            :publish_end_on => Date.current.yesterday },
          { :title => 'past_publish_date_range',
            :publish_start_on => Date.current.prev_year,
            :publish_end_on => Date.current.yesterday },
          { :title => 'future_publish_date_range',
            :publish_start_on => Date.current.tomorrow,
            :publish_end_on => Date.current.next_month },
          { :title => 'future_publish_start_date',
            :publish_start_on => Date.current.tomorrow }
        ]
        featured_collection_params.each_with_index do |params, index|
          featured_collection = affiliate.featured_collections.build(:title => "Featured collection #{params[:title]}",
                                                                                 :locale => 'en',
                                                                                 :status => 'active',
                                                                                 :layout => 'one column',
                                                                                 :publish_start_on => params[:publish_start_on],
                                                                                 :publish_end_on => params[:publish_end_on])
          featured_collection.featured_collection_keywords.build(:value => "keyword#{index + 1}")
          featured_collection.save!

        end
        FeaturedCollection.reindex
      end

      it "should not return featured_collections with past publish end date" do
        FeaturedCollection.search_for('past_publish_end_date', affiliate, :en).results.should be_empty
      end

      it "should not return featured_collections with past publish date range" do
        FeaturedCollection.search_for('past_publish_date_range', affiliate, :en).results.should be_empty
      end

      it "should not return featured_collections with future publish date range" do
        FeaturedCollection.search_for('future_publish_date_range', affiliate, :en).results.should be_empty
      end

      it "should not return featured_collections with future publish start date" do
        FeaturedCollection.search_for('future_publish_start_date', affiliate, :en).results.should be_empty
      end
    end

    context "when there is an active Spanish featured collection" do
      before do
        @featured_collection = affiliate.featured_collections.build(:title => 'Nombres de huracanes tropicales',
                                                                    :locale => 'es',
                                                                    :status => 'active',
                                                                    :layout => 'one column')
        @featured_collection.featured_collection_keywords.build(:value => 'tifón')
        @featured_collection.featured_collection_links.build(:title => 'Nombres de ciclones tropicales en todo el mundo',
                                                             :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                             :position => '0')
        @featured_collection.save!

        inactive_featured_collection = affiliate.featured_collections.build(:title => 'Retiró los nombres de huracán',
                                                                            :locale => 'en',
                                                                            :status => 'inactive',
                                                                            :layout => 'one column')
        inactive_featured_collection.featured_collection_keywords.build(:value => 'tifón')
        inactive_featured_collection.featured_collection_links.build(:title => 'Se retiró nombres de huracanes desde 1954',
                                                                     :url => 'http://www.nhc.noaa.gov/retirednames.shtml',
                                                                     :position => '0')
        inactive_featured_collection.save!

        inactive_featured_collection = affiliate.featured_collections.build(:title => 'inactive tropicales',
                                                                    :locale => 'es',
                                                                    :status => 'inactive',
                                                                    :layout => 'one column')
        inactive_featured_collection.featured_collection_keywords.build(:value => 'tifón')
        FeaturedCollection.reindex
      end

      it "should return only active Featured Collections" do
        FeaturedCollection.search_for('tropicales', affiliate, :es).results.each do |result|
          result.should be_is_active
        end
      end

      it "should return Featured Collection when searching for query term that exists in the title" do
        FeaturedCollection.search_for('tropicales', affiliate, :es).results.first.should == @featured_collection
      end

      it "should return Featured Collection when searching for query term that exists in featured collection keywords" do
        FeaturedCollection.search_for('tifón', affiliate, :es).results.first.should == @featured_collection
      end

      it "should return Featured Collection when searching for query term that exists in the link title" do
        FeaturedCollection.search_for('ciclones', affiliate, :es).results.first.should == @featured_collection
      end

      it "should not return any result when searching for English Featured Collection" do
        FeaturedCollection.search_for('tropicales', affiliate, :en).results.should be_blank
      end
    end

    context "when .search raise an exception" do
      it "should return nil" do
        FeaturedCollection.should_receive(:search).and_raise("exception")
        FeaturedCollection.search_for('tropicales', affiliate, :en).should be_nil
      end
    end
  end
end
