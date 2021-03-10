require 'spec_helper'

describe FeaturedCollection do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:valid_attributes) do
    { affiliate: affiliate, title: 'my fc', status: 'active', publish_start_on: Date.today }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :affiliate }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :publish_start_on }
    it { is_expected.to have_attached_file :image }
    it { is_expected.to validate_attachment_content_type(:image).
         allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).
         rejecting(nil, %w{ text/plain text/xml application/pdf }) }
    it { is_expected.to validate_attachment_size(:image).in(1..512.kilobytes) }

    FeaturedCollection::STATUSES.each do |status|
      it { is_expected.to allow_value(status).for(:status) }
    end
    it { is_expected.not_to allow_value('bogus status').for(:status) }

    it_behaves_like 'a record that sanitizes attributes', [:title]
  end

  specify { expect(FeaturedCollection.new(status: 'active')).to be_is_active }
  specify { expect(FeaturedCollection.new(status: 'active')).not_to be_is_inactive }
  specify { expect(FeaturedCollection.new(status: 'inactive')).to be_is_inactive }
  specify { expect(FeaturedCollection.new(status: 'inactive')).not_to be_is_active }

  it { is_expected.to belong_to :affiliate }
  it { is_expected.to have_many(:featured_collection_keywords).dependent(:destroy) }
  it do
    is_expected.to have_many(:featured_collection_links).
      dependent(:destroy).inverse_of(:featured_collection)
  end

  it 'squishes title, title_url and image_alt_text' do
    fc = FeaturedCollection.create!({ title: 'Did You   Mean Roes or Rose?',
                                      title_url: ' ',
                                      image_alt_text: '  ',
                                      status: 'active',
                                      publish_start_on: '07/01/2011',
                                      affiliate: @affiliate })
    expect(fc.title).to eq('Did You Mean Roes or Rose?')
    expect(fc.title_url).to be_nil
    expect(fc.image_alt_text).to be_nil
  end

  describe 'title URL should have http(s):// prefix' do
    context 'when the title URL does not start with http(s):// prefix' do
      title_url = 'search.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        specify { expect(FeaturedCollection.create!(title: 'Did You Mean Roes or Rose?',
                                             title_url: "#{prefix}#{title_url}",
                                             status: 'active',
                                             publish_start_on: '07/01/2011',
                                             affiliate: @affiliate).title_url).to eq("http://#{prefix}#{title_url}") }
      end
    end

    context 'when the title URL starts with http(s):// prefix' do
      title_url = 'search.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        specify { expect(FeaturedCollection.create!(title: 'Did You Mean Roes or Rose?',
                                             title_url: "#{prefix}#{title_url}",
                                             status: 'active',
                                             publish_start_on: '07/01/2011',
                                             affiliate: @affiliate).title_url).to eq("#{prefix}#{title_url}") }
      end
    end
  end

  it 'should not allow publish start date before publish end date' do
    featured_collection = FeaturedCollection.create(title: 'test title',
                                                    status: 'active',
                                                    publish_start_on: '07/01/2012',
                                                    publish_end_on: '07/01/2011',
                                                    affiliate: @affiliate)
    expect(featured_collection.errors.full_messages.join).to match(/Publish end date can't be before publish start date/)
  end

  describe 'match_keyword_values_only validation' do
    let(:fc_attributes) do
      {
        title: 'test title',
        status: 'active',
        publish_start_on: '01/01/2015',
        publish_end_on: '02/01/2015',
        match_keyword_values_only: true
      }
    end
    let(:featured_collection) { @affiliate.featured_collections.build(fc_attributes) }

    context 'when no featured_collection_keywords are provided' do
      it 'should not allow match_keyword_values_only to be set to true' do
        expect(featured_collection.save).to be false
        expect(featured_collection.errors.full_messages.join).to match(/requires at least one keyword/)
      end
    end

    context 'when some featured_collection_keywords are provided' do
      it 'should not allow match_keyword_values_only to be set to true' do
        featured_collection = @affiliate.featured_collections.build(fc_attributes)
        featured_collection.featured_collection_keywords.build({ value: 'foo bar' })
        expect(featured_collection.save).to be true
        expect(featured_collection.errors).to be_empty
      end
    end
  end

  describe '#display_status' do
    context 'when status is set to active' do
      subject { FeaturedCollection.new(status: 'active') }
      its(:display_status) { should == 'Active' }
    end

    context 'when status is set to inactive' do
      subject { FeaturedCollection.new(status: 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end

  describe '#update_attributes' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:image) { double('image') }

    let(:featured_collection) do
      affiliate.featured_collections.create!(affiliate: affiliate,
                                             title: 'My awesome featured collection',
                                             status: 'active',
                                             publish_start_on: Date.current,
                                             image_alt_text: 'alt text')

    end

    context 'when there is an existing image' do
      before do
        expect(featured_collection).to receive(:image?).and_return(true)
        expect(featured_collection).to receive(:image).at_least(:once).and_return(image)
        allow(image).to receive(:flush_errors)
        allow(image).to receive(:save)
      end

      context 'when marking an existing image for deletion' do
        it 'should clear existing image' do
          expect(image).to receive(:dirty?).at_least(:once).and_return(false)
          expect(image).to receive(:clear)
          featured_collection.update_attributes( mark_image_for_deletion: '1' )
        end
      end

      context 'when uploading a new image' do
        let(:image) do
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/images/corgi.jpg'), 'image/jpeg')
        end
        let(:new_image) { double('image') }

        it 'should not clear the existing image' do
          allow(image).to receive(:assign).with(new_image).and_return(new_image)
          expect(image).to receive(:dirty?).at_least(:once).and_return(true)
          expect(image).not_to receive(:clear)
          featured_collection.update_attributes( title: 'updated', image: new_image )
        end
      end
    end

    context 'when there is no existing image' do
      it 'should not clear image' do
        expect(featured_collection).to receive(:image?).and_return(false)
        expect(image).not_to receive(:clear)
        featured_collection.update_attributes(title: 'new title')
      end
    end
  end

  describe '.substring_match(query)' do
    context 'with an affiliate' do
      let(:affiliate) { affiliates(:basic_affiliate) }

      context 'when only the parent record has substring match in selected text fields' do
        before do
          affiliate.featured_collections.create!(title: 'My awesome featured collection abc',
                                                 title_url: 'http://www.dotgov.gov/page.html',
                                                 status: 'active',
                                                 publish_start_on: Date.current)
          affiliate.featured_collections.create!(title: 'Another awesome featured collection',
                                                 title_url: 'http://www.dotgov.gov/defg.html',
                                                 status: 'active',
                                                 publish_start_on: Date.current)
        end

        it 'should find the records' do
          %w{abc defg}.each do |substring|
            expect(affiliate.featured_collections.substring_match(substring).size).to eq(1)
          end
          expect(affiliate.featured_collections.substring_match('awesome').size).to eq(2)
        end

        context 'when keywords have substring match in selected fields' do
          before do
            fc = FeaturedCollection.last
            fc.featured_collection_keywords.build(value: 'page2')
            fc.featured_collection_keywords.build(value: 'hello')
            fc.save!
          end

          it 'should find the record just once' do
            %w{page2 llo}.each do |substring|
              expect(affiliate.featured_collections.substring_match(substring).size).to eq(1)
            end
          end
        end
      end

      context 'when at least one has_many association has substring match in selected fields' do
        before do
          fc = affiliate.featured_collections.build(title: 'My awesome featured collection',
                                                    title_url: 'http://www.dotgov.gov/page.html',
                                                    status: 'active',
                                                    publish_start_on: Date.current)
          fc.featured_collection_keywords.build(value: 'word1')
          fc.featured_collection_links.build(title: 'Worldwide Tropical Cyclone Names Part1',
                                             url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                             position: '0')

          fc.save!
        end

        it 'should find the records' do
          %w{word1 cyclone}.each do |substring|
            expect(affiliate.featured_collections.substring_match(substring).size).to eq(1)
          end
        end
      end

      context 'when neither the parent or the child records have a match' do
        before do
          fc = affiliate.featured_collections.build(title: 'My awesome featured collection',
                                                    title_url: 'http://www.dotgov.gov/page.html',
                                                    status: 'active',
                                                    publish_start_on: Date.current)
          fc.featured_collection_keywords.build(value: 'word1')
          fc.featured_collection_links.build(title: 'Worldwide Tropical Cyclone Names Part1',
                                             url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                             position: '0')

          fc.save!
        end

        it 'should not find any records' do
          expect(affiliate.featured_collections.substring_match('sdfsdfsdf').size).to be_zero
        end
      end

    end
  end

  describe '.human_attribute_name' do
    specify { expect(FeaturedCollection.human_attribute_name('publish_start_on')).to eq('Publish start date') }
  end

  describe '#as_json' do
    after { FeaturedCollection.destroy_all }

    context 'when image is present' do
      it 'contains image_url' do
        image = File.new(Rails.root.join('features/support/small.jpg'), 'r')
        fc_attributes = {
          image: image,
          title: 'My awesome featured collection',
          title_url: 'http://www.dotgov.gov/page.html',
          status: 'active',
          publish_start_on: Date.current
        }
        fc = @affiliate.featured_collections.build(fc_attributes)
        fc.featured_collection_links.build(title: 'Worldwide Tropical Cyclone Names Part1',
                                           url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                           position: '0')
        fc.save!

        as_json_hash = fc.as_json

        expect(as_json_hash[:id]).to_not be_nil
        expect(as_json_hash[:title]).to eq('My awesome featured collection')
        expect(as_json_hash[:title_url]).to eq('http://www.dotgov.gov/page.html')
        expect(as_json_hash[:image_url]).to match(/small\.jpg/)

        expected_link_hash = {
          title: 'Worldwide Tropical Cyclone Names Part1',
          url: 'http://www.nhc.noaa.gov/aboutnames.shtml'
        }
        expect(as_json_hash[:links]).to eq([expected_link_hash])
      end
    end
  end

  describe '#dup' do
    subject(:original_instance) do
      FeaturedCollection.create!(affiliate: @affiliate,
                                 publish_start_on: '07/01/2011',
                                 status: 'active',
                                 title: 'BBG title',
                                 image_content_type: 'image/jpeg',
                                 image_file_name: 'test.jpg',
                                 image_file_size: 100,
                                 image_updated_at: DateTime.current)
    end

    include_examples 'dupable',
                     %w(affiliate_id
                        image_content_type
                        image_file_name
                        image_file_size
                        image_updated_at)
  end

  describe '#image' do
    let(:image) { File.open(Rails.root.join('spec/fixtures/images/corgi.jpg')) }
    let(:fc) { FeaturedCollection.create({ image: image }.merge(valid_attributes)) }

    it 'stores the image in s3 with a secure url' do
      expect(fc.image.url).to match /https:\/\/.*\.s3\.amazonaws\.com\/test\/featured_collection\/#{fc.id}\/image\/\d+\/original\/corgi.jpg/
    end

    it 'is available in medium and small' do
      expect(fc.image.exists?(:medium)).to be true
      expect(fc.image.exists?(:small)).to be true
    end
  end
end
