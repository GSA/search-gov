require 'spec_helper'

describe FlickrProfile do
  fixtures :affiliates, :flickr_profiles, :flickr_photos

  let(:affiliate) { affiliates(:basic_affiliate) }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:affiliate_id) }
  it { should validate_presence_of(:url) }

  context 'when URL is present and valid' do
    let(:flickr_response) { { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' } }
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before { flickr.urls.should_receive(:lookupUser).with(url: url).and_return(flickr_response) }

    it 'detects profile_type and profile_id' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should be_valid
      fp.profile_type.should == 'user'
      fp.profile_id.should be_present
    end
  end

  context 'when profile_type is not identified' do
    let(:url) { 'https://www.flickr.com/invalid/marine_corps/'.freeze }

    it 'should not lookupUser or lookupGroup' do
      flickr.should_not_receive(:urls)

      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
      fp.profile_type.should be_blank
    end
  end

  context 'when Flickr lookupUser fails' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    it 'should not be valid' do
      flickr.urls.should_receive(:lookupUser).
          with(url: url).
          and_raise(FlickRaw::FailedResponse.new('User not found', 1, 'flickr.urls.lookupUser') )
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when Flickr lookupGroup fails' do
    let(:url) { 'https://www.flickr.com/groups/usagov/'.freeze }

    it 'should not be valid' do
      flickr.urls.should_receive(:lookupGroup).
          with(url: url).
          and_raise(FlickRaw::FailedResponse.new('Group not found', 1, 'flickr.urls.lookupGroup') )
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when adding a profile that already exists for the given affiliate' do
    let(:flickr_response) { { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' } }
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before { flickr.urls.stub(:lookupUser).and_return(flickr_response) }

    it 'should not be valid' do
      FlickrProfile.create! affiliate: affiliate, url: url
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  it 'should queue the profile for import after create' do
    flickr_response = { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' }
    url = 'https://www.flickr.com/photos/marine_corps/'.freeze
    flickr.urls.should_receive(:lookupUser).with(url: url).and_return(flickr_response)

    ResqueSpec.reset!
    Resque.should_receive(:enqueue_with_priority).with(:high, FlickrProfileImporter, an_instance_of(Fixnum))

    FlickrProfile.create(url: url, affiliate: affiliate)
  end

  describe '#destroy' do
    it 'destroys flickr photos' do
      fp = flickr_profiles(:user)
      photo_ids = fp.flickr_photos.pluck(:id)
      photo_ids.should be_present

      ElasticFlickrPhoto.should_receive(:delete).with(photo_ids)
      FlickrPhoto.should_receive(:delete_all).with(['id IN (?)', photo_ids])

      fp.destroy
    end
  end

  describe "#import_photos" do
    context "when the profile's url is a Flickr photo url (http://www.flickr.com/photos/username)" do
      let(:user_id) { '40927340@N03'.freeze }
      let(:user_url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }
      let(:flickr_response) { { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' } }

      before do
        flickr.urls.should_receive(:lookupUser).with(url: user_url).and_return(flickr_response)
        @profile = FlickrProfile.create!(url: user_url, affiliate: affiliate)
        @first_photos_response = [{"lastupdate" => "1233790918", "url_m" => "http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m" => "500", "height_l" => "768", "ispublic" => 1, "latitude" => 0, "width_sq" => 75, "height_m" => "375", "url_n" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n" => "320", "farm" => 4, "title" => "0203091648", "height_sq" => 75, "height_n" => 240, "license" => "1", "datetakengranularity" => "0", "accuracy" => 0, "url_sq" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z" => "640", "iconfarm" => 1, "pathalias" => "greggersh", "width_q" => "150", "height_z" => 480, "id" => "3253668705", "server" => "3264", "isfamily" => 0, "datetaken" => "2009-02-04 18:41:39", "tags" => "soup hotandsoursoup umami", "views" => "40", "url_q" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q" => "150", "dateupload" => "1233790899", "media" => "photo", "media_status" => "ready", "width_s" => "240", "width_t" => "100", "url_s" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s" => "180", "description" => "", "longitude" => 0, "context" => 0, "url_t" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t" => "75", "secret" => "b452012751", "owner" => "35034349064@N01", "isfriend" => 0, "ownername" => "GregGersh", "iconserver" => "1", "machine_tags" => "", "url_l" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l" => "1024", "o_height" => "120"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate" => "1233790918", "url_m" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m" => "500", "height_l" => "768", "ispublic" => 1, "latitude" => 0, "width_sq" => 75, "height_m" => "375", "url_n" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n" => "320", "farm" => 4, "title" => "0203091702", "height_sq" => 75, "height_n" => 240, "license" => "1", "datetakengranularity" => "0", "accuracy" => 0, "url_sq" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z" => "640", "iconfarm" => 1, "pathalias" => "greggersh", "width_q" => "150", "height_z" => 480, "id" => "3253668675", "server" => "3118", "isfamily" => 0, "datetaken" => "2009-02-04 18:41:37", "tags" => "", "views" => "32", "url_q" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q" => "150", "dateupload" => "1233790897", "media" => "photo", "media_status" => "ready", "width_s" => "240", "width_t" => "100", "url_s" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s" => "180", "description" => "", "longitude" => 0, "context" => 0, "url_t" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t" => "75", "secret" => "5f79044fb6", "owner" => "35034349064@N01", "isfriend" => 0, "ownername" => "GregGersh", "iconserver" => "1", "machine_tags" => "", "url_l" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l" => "1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
        @photo_info = {"dateuploaded" => "1233790899", "publiceditability" => {"canaddmeta" => 0, "cancomment" => 1}, "usage" => {"candownload" => 1, "canshare" => 1, "canblog" => 0, "canprint" => 0}, "farm" => 4, "title" => "0203091648", "editability" => {"canaddmeta" => 0, "cancomment" => 0}, "comments" => "0", "urls" => [{"type" => "photopage", "_content" => "http://www.flickr.com/photos/greggersh/3253668705/"}], "license" => "1", "safety_level" => "0", "notes" => [], "id" => "3253668705", "server" => "3264", "views" => "43", "tags" => [{"author" => "35034349064@N01", "machine_tag" => 0, "id" => "6073-3253668705-54699", "_content" => "hotandsoursoup", "raw" => "hot and sour soup"}, {"author" => "35034349064@N01", "machine_tag" => 0, "id" => "6073-3253668705-1975", "_content" => "soup", "raw" => "soup"}, {"author" => "35034349064@N01", "machine_tag" => 0, "id" => "6073-3253668705-195793", "_content" => "umami", "raw" => "umami"}], "media" => "photo", "dates" => {"posted" => "1233790899", "lastupdate" => "1339165784", "takengranularity" => "0", "taken" => "2009-02-04 18:41:39"}, "isfavorite" => 0, "description" => "", "people" => {"haspeople" => 0}, "secret" => "b452012751", "visibility" => {"ispublic" => 1, "isfamily" => 0, "isfriend" => 0}, "rotation" => 0, "owner" => {"nsid" => "35034349064@N01", "realname" => "Greg Gershman", "location" => "", "username" => "GregGersh", "iconfarm" => 1, "iconserver" => "1"}}
        @other_photo_info = {"tags" => []}
      end

      context "when the user name is valid, and the user has photos" do
        before do
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => user_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_return @first_photos_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => user_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668705").once.and_return @photo_info
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668675").once.and_return @other_photo_info
        end

        it "should use the Flickr API to lookup the username and store their photos" do
          @profile.import_photos
          @profile.flickr_photos.count.should == 2
          first_photo = @profile.flickr_photos.first
          first_photo.flickr_id.should == "3253668705"
          first_photo.date_taken.should == Time.parse("2009-02-04 18:41:39 UTC")
          first_photo.date_upload.should == Time.at(1233790899)
          first_photo.is_public.should be_true
          first_photo.is_friend.should be_false
          first_photo.icon_farm.should == 1
          first_photo.icon_server.should == "1"
          first_photo.tags.should == "hot and sour soup,soup,umami"
          last_photo = @profile.flickr_photos.last
          last_photo.flickr_id.should == "3253668675"
          last_photo.tags.should be_blank
        end
      end

      context "when an error occurs looking up photos" do
        before do
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => user_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_raise "Some Error"
          flickr.people.should_not_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrProfile::EXTRA_FIELDS, :page => 2)
          flickr.photos.should_not_receive(:getInfo)
        end

        it "should not blow up" do
          @profile.import_photos
          @profile.flickr_photos.count.should == 0
        end
      end
    end

    context "when the affiliates url is a Flickr group url" do
      let(:group_url) { 'https://www.flickr.com/groups/usagov/'.freeze }
      let(:group_id) { '1058319@N21' }
      let(:flickr_response) { { 'id' => group_id, 'groupname' => 'USA.gov - Official U.S. Government Photostreams' } }

      before do
        flickr.urls.should_receive(:lookupGroup).with(url: group_url).and_return(flickr_response)
        @profile = FlickrProfile.create!(url: group_url, affiliate: affiliate)

        @first_photos_response = [{"lastupdate" => "1233790918", "url_m" => "http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m" => "500", "height_l" => "768", "ispublic" => 1, "latitude" => 0, "width_sq" => 75, "height_m" => "375", "url_n" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n" => "320", "farm" => 4, "title" => "0203091648", "height_sq" => 75, "height_n" => 240, "license" => "1", "datetakengranularity" => "0", "accuracy" => 0, "url_sq" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z" => "640", "iconfarm" => 1, "pathalias" => "greggersh", "width_q" => "150", "height_z" => 480, "id" => "3253668705", "server" => "3264", "isfamily" => 0, "datetaken" => "2009-02-04 18:41:39", "tags" => "soup hotandsoursoup umami", "views" => "40", "url_q" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q" => "150", "dateupload" => "1233790899", "media" => "photo", "media_status" => "ready", "width_s" => "240", "width_t" => "100", "url_s" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s" => "180", "description" => "", "longitude" => 0, "context" => 0, "url_t" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t" => "75", "secret" => "b452012751", "owner" => "35034349064@N01", "isfriend" => 0, "ownername" => "GregGersh", "iconserver" => "1", "machine_tags" => "", "url_l" => "http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l" => "1024"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate" => "1233790918", "url_m" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m" => "500", "height_l" => "768", "ispublic" => 1, "latitude" => 0, "width_sq" => 75, "height_m" => "375", "url_n" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n" => "320", "farm" => 4, "title" => "0203091702", "height_sq" => 75, "height_n" => 240, "license" => "1", "datetakengranularity" => "0", "accuracy" => 0, "url_sq" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z" => "640", "iconfarm" => 1, "pathalias" => "greggersh", "width_q" => "150", "height_z" => 480, "id" => "3253668675", "server" => "3118", "isfamily" => 0, "datetaken" => "2009-02-04 18:41:37", "tags" => "soup hotandsoursoup umami", "views" => "32", "url_q" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q" => "150", "dateupload" => "1233790897", "media" => "photo", "media_status" => "ready", "width_s" => "240", "width_t" => "100", "url_s" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s" => "180", "description" => "", "longitude" => 0, "context" => 0, "url_t" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t" => "75", "secret" => "5f79044fb6", "owner" => "35034349064@N01", "isfriend" => 0, "ownername" => "GregGersh", "iconserver" => "1", "machine_tags" => "", "url_l" => "http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l" => "1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
      end

      context "when the group name is valid and the group has photos" do
        before do
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => group_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_return @first_photos_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => group_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668705").once.and_return @photo_info
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668675").once.and_return @photo_info
        end

        it "should use the Flickr API to lookup the group id and store their photos" do
          @profile.import_photos
          @profile.flickr_photos.count.should == 2
          first_photo = @profile.flickr_photos.first
          first_photo.flickr_id.should == "3253668705"
          first_photo.date_taken.should == Time.parse("2009-02-04 18:41:39 UTC")
          first_photo.date_upload.should == Time.at(1233790899)
          first_photo.is_public.should be_true
          first_photo.is_friend.should be_false
          first_photo.icon_farm.should == 1
          first_photo.icon_server.should == "1"
        end
      end

      context "when an error occurs looking up photos" do
        before do
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => group_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_raise "Some Error"
          flickr.groups.pools.should_not_receive(:getPhotos).with(:group_id => group_id, :extras => FlickrProfile::EXTRA_FIELDS, :page => 2)
          flickr.photos.should_not_receive(:getInfo)
        end

        it "should not blow up" do
          @profile.import_photos
          @profile.flickr_photos.count.should == 0
        end
      end
    end
  end
end
