require 'spec/spec_helper'

describe FlickrProfile do
  fixtures :affiliates
  
  before do
    @affiliate = affiliates(:basic_affiliate)
    @user_response = {"nsid" => '12345', "username" => 'USAgency', "id" => '12345'}
    @group_search_response = [{"nsid"=>"1058319", "name"=>"USA.gov - Official US Government Photostreams", "eighteenplus"=>0}]
  end
  
  it { should validate_presence_of :url }
  it { should validate_presence_of :profile_type }
  it { should validate_presence_of :profile_id }
  it { should validate_presence_of :affiliate }
  it { should belong_to :affiliate }
  
  it "should require the url to be a valid Flickr user or group" do
    profile = FlickrProfile.create(:url => 'USAgency')
    profile.errors.collect{|error| error.last }.include?("The URL you provided does not appear to be a valid Flickr user or Flickr group.  Please provide a URL for a valid Flickr user or Flickr group.").should be_true
  end
    
  context "when the profile id and type are provided at create time" do
    it "should not lookup the user profile information using the Flickr API if specified on create" do
      profile = FlickrProfile.new(:url => 'http://flickr.com/photos/USAgency', :affiliate => @affiliate, :profile_type => 'user', :profile_id => '12345')
      flickr.people.should_not_receive(:findByUsername)
      profile.save!
    end
  end
  
  context "when no profile id or type is provided" do
    context "when the profile URL is a user URL" do
      before do
        @profile = FlickrProfile.new(:url => 'http://flickr.com/photos/USAgency', :affiliate => @affiliate)
      end
    
      it "should lookup the user profile information using the Flickr API on create" do
        flickr.people.should_receive(:findByUsername).with(:username => 'USAgency').and_return @user_response
        @profile.save!
        @profile.profile_type.should == "user"
        @profile.profile_id.should == "12345"
      end
      
      context "when there is an error looking up the user" do
        before do
          flickr.people.stub!(:findByUsername).and_raise "Some Exception"
        end
        
        it "should not create the profile" do
          profile = FlickrProfile.create(:url => "http://flickr.com/photos/USAgency", :affiliate => @affiliate)
          profile.errors.should_not be_empty
          profile.id.should be_nil
          profile.errors.first.should == [:base, "We could not find the Flickr user that you specified.  Please modify the URL and try again."]
        end
      end
    end
  
    context "when the profile URL is a group URL" do
      before do
        @profile = FlickrProfile.new(:url => 'http://flickr.com/groups/USAgency', :affiliate => @affiliate)
      end
  
      it "should lookup the group profile information using the Flickr API on create" do
        flickr.groups.should_receive(:search).with(:text => "USAgency").and_return @group_search_response
        @profile.save!
        @profile.profile_type.should == "group"
        @profile.profile_id.should == "1058319"
      end
      
      context "when the url can not be found via the Flickr API" do
        before do
          flickr.stub!(:search).and_raise "Some Exception"
        end
        
        it "should not create the profile" do
          profile = FlickrProfile.create(:url => "http://flickr.com/groups/USAgency", :affiliate => @affiliate)
          profile.errors.should_not be_empty
          profile.id.should be_nil
          profile.errors.first.should == [:base, "We could not find the Flickr group that you specified.  Please modify the URL and try again."]
        end
      end
    end
  
    context "when the profile URL is neither a user nor a group" do
      before do
        @profile = FlickrProfile.new(:url => 'http://flickr.com/blargh/USAgency', :affiliate => @affiliate)
      end
    
      it "should fail" do
        @profile.save
        @profile.errors.should_not be_empty
      end
    end
  end
    
  describe "#import_photos" do
    before do
    end
    
    context "when the profile's url is a Flickr photo url (http://www.flickr.com/photos/username)" do
      before do
        @profile = FlickrProfile.create!(:url => 'http://flickr.com/photos/USAAgency', :profile_type => 'user', :profile_id => '12345', :affiliate => @affiliate)
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"soup hotandsoursoup umami", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024", "o_height" => "120"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
        @photo_info = {"dateuploaded"=>"1233790899", "publiceditability"=>{"canaddmeta"=>0, "cancomment"=>1}, "usage"=>{"candownload"=>1, "canshare"=>1, "canblog"=>0, "canprint"=>0}, "farm"=>4, "title"=>"0203091648", "editability"=>{"canaddmeta"=>0, "cancomment"=>0}, "comments"=>"0", "urls"=>[{"type"=>"photopage", "_content"=>"http://www.flickr.com/photos/greggersh/3253668705/"}], "license"=>"1", "safety_level"=>"0", "notes"=>[], "id"=>"3253668705", "server"=>"3264", "views"=>"43", "tags"=>[{"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-54699", "_content"=>"hotandsoursoup", "raw"=>"hot and sour soup"}, {"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-1975", "_content"=>"soup", "raw"=>"soup"}, {"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-195793", "_content"=>"umami", "raw"=>"umami"}], "media"=>"photo", "dates"=>{"posted"=>"1233790899", "lastupdate"=>"1339165784", "takengranularity"=>"0", "taken"=>"2009-02-04 18:41:39"}, "isfavorite"=>0, "description"=>"", "people"=>{"haspeople"=>0}, "secret"=>"b452012751", "visibility"=>{"ispublic"=>1, "isfamily"=>0, "isfriend"=>0}, "rotation"=>0, "owner"=>{"nsid"=>"35034349064@N01", "realname"=>"Greg Gershman", "location"=>"", "username"=>"GregGersh", "iconfarm"=>1, "iconserver"=>"1"}}
        @other_photo_info = {"tags"=>[] }
      end
      
      context "when the user name is valid, and the user has photos" do
        before do
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_return @first_photos_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrProfile::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
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
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_raise "Some Error"
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
      before do
        @profile = FlickrProfile.create!(:url => "http://www.flickr.com/groups/USAgency", :profile_type => 'group', :profile_id => '1058319', :affiliate => @affiliate)
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"soup hotandsoursoup umami", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"soup hotandsoursoup umami", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
      end

      context "when the group name is valid and the group has photos" do
        before do
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_return @first_photos_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrProfile::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
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
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrProfile::EXTRA_FIELDS, :page => 1).and_raise "Some Error"
          flickr.groups.pools.should_not_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrProfile::EXTRA_FIELDS, :page => 2)
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
