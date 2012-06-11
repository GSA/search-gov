require 'spec/spec_helper'

describe FlickrPhoto do
  fixtures :affiliates
  
  before do
    @valid_attributes = {
      :flickr_id => '12345678',
    }
  end
  
  it { should validate_presence_of :flickr_id }
  it { should validate_presence_of :affiliate }
  
  it "should create a new instance given valid attributes" do
    FlickrPhoto.create!(@valid_attributes.merge(:affiliate => affiliates(:basic_affiliate)))
    should validate_uniqueness_of(:flickr_id).scoped_to(:affiliate_id)
  end
  
  describe "#search_for" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      FlickrPhoto.destroy_all
      FlickrPhoto.create(:flickr_id => 1, :affiliate => @affiliate, :title => 'A picture of Barack Obama', :description => 'Barack Obama playing with his dog at the White House.', :tags => 'barackobama,barack obama,dog,white house', :date_taken => Time.now - 3.days)
      FlickrPhoto.create(:flickr_id => 2, :affiliate => @affiliate, :title => 'Barack Obama and Joe Biden in Air Force One', :description => 'President Barack Obama and Vice President Joe Biden boarding Air Force One for a quick trip somewhere.', :tags => "joe biden vice president barack obama", :date_taken => Time.now - 2.days)
      FlickrPhoto.create(:flickr_id => 3, :affiliate => @affiliate, :title => 'Barack and Michelle Obama', :description => 'President Barack Obama and First Lady Michelle Obama attend a state dinner at the White House', :tags => "barack obama,michelle,whitehouse", :date_taken => Time.now - 4.days)
      FlickrPhoto.create(:flickr_id => 4, :affiliate => @affiliate, :title => 'Barack Obama Throws First Pitch', :description => 'President Barack Obama throws out the first pitch at a Washington Nationals baseball game.', :date_taken => Time.now - 5.days)
      FlickrPhoto.create(:flickr_id => 5, :affiliate => @affiliate, :title => "President Obama walks his daughters to school", :description => '', :tags => 'barack obama,sasha,malia')
      FlickrPhoto.create(:flickr_id => 6, :affiliate => @affiliate, :title => 'POTUS gets in car.', :description => 'Barack Obama gets into his super protected car.', :tags => "car,batman", :date_taken => Time.now - 14.days)
      FlickrPhoto.reindex
    end
    
    context "when searching with default page and per_page" do
      before do
        @search = FlickrPhoto.search_for("obama", @affiliate)
      end
      
      it "should default to the first page" do
        @search.results.first_page?.should be_true
      end
      
      it "should return five results" do
        @search.results.size.should == 5
      end
    end
    
    context "when searching with page and per_page parameters" do
      before do
        @search = FlickrPhoto.search_for("obama", @affiliate, 2, 2)
      end
      
      it "should return the proper page" do
        @search.results.first_page?.should be_false
      end
      
      it "should page the results accordingly" do
        @search.results.size.should == 2
      end
    end
    
    context "when a blank search is entered" do
      before do
        @search = FlickrPhoto.search_for("", @affiliate)
      end
      
      it "should return nil" do
        @search.should be_nil
      end
    end
    
    context "when searching on a matching tag" do
      before do
        @search = FlickrPhoto.search_for("batman", @affiliate)
      end
      
      it "should find matching photos" do
        @search.total.should == 1
        @search.results.first.title.should == "POTUS gets in car."
      end
    end
  end
  
  describe "#import_photos" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end
    
    context "when the affiliate has a blank flickr url" do
      it "should do nothing" do
        flickr.people.should_not_receive(:findByUsername)
        flickr.groups.should_not_receive(:search)
        FlickrPhoto.import_photos(@affiliate)
        FlickrPhoto.count.should == 0
      end
    end
    
    context "when the affiliates url is a Flickr photo url (http://www.flickr.com/photos/username)" do
      before do
        @affiliate.flickr_url = "http://www.flickr.com/photos/USAgency"
        @user_response = {"nsid" => '12345', "username" => 'USAgency', "id" => '12345'}
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"soup hotandsoursoup umami", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024", "o_height" => "120"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
        @photo_info = {"dateuploaded"=>"1233790899", "publiceditability"=>{"canaddmeta"=>0, "cancomment"=>1}, "usage"=>{"candownload"=>1, "canshare"=>1, "canblog"=>0, "canprint"=>0}, "farm"=>4, "title"=>"0203091648", "editability"=>{"canaddmeta"=>0, "cancomment"=>0}, "comments"=>"0", "urls"=>[{"type"=>"photopage", "_content"=>"http://www.flickr.com/photos/greggersh/3253668705/"}], "license"=>"1", "safety_level"=>"0", "notes"=>[], "id"=>"3253668705", "server"=>"3264", "views"=>"43", "tags"=>[{"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-54699", "_content"=>"hotandsoursoup", "raw"=>"hot and sour soup"}, {"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-1975", "_content"=>"soup", "raw"=>"soup"}, {"author"=>"35034349064@N01", "machine_tag"=>0, "id"=>"6073-3253668705-195793", "_content"=>"umami", "raw"=>"umami"}], "media"=>"photo", "dates"=>{"posted"=>"1233790899", "lastupdate"=>"1339165784", "takengranularity"=>"0", "taken"=>"2009-02-04 18:41:39"}, "isfavorite"=>0, "description"=>"", "people"=>{"haspeople"=>0}, "secret"=>"b452012751", "visibility"=>{"ispublic"=>1, "isfamily"=>0, "isfriend"=>0}, "rotation"=>0, "owner"=>{"nsid"=>"35034349064@N01", "realname"=>"Greg Gershman", "location"=>"", "username"=>"GregGersh", "iconfarm"=>1, "iconserver"=>"1"}}
      end
      
      context "when the user name is valid, and the user has photos" do
        before do
          flickr.people.should_receive(:findByUsername).with(:username => "USAgency").and_return @user_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS).and_return @first_photos_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668705").once.and_return @photo_info
          flickr.photos.should_not_receive(:getInfo).with(:photo_id => "3253668675")
        end
          
        it "should use the Flickr API to lookup the username and store their photos" do
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 2
          first_photo = FlickrPhoto.first
          first_photo.flickr_id.should == "3253668705"
          first_photo.date_taken.should == Time.parse("2009-02-04 18:41:39 UTC")
          first_photo.date_upload.should == Time.at(1233790899)
          first_photo.is_public.should be_true
          first_photo.is_friend.should be_false
          first_photo.icon_farm.should == 1
          first_photo.icon_server.should == "1"
          first_photo.tags.should == "hot and sour soup,soup,umami"
          last_photo = FlickrPhoto.last
          last_photo.tags.should be_nil
        end
      end
    
      context "when a user name can not be found" do
        before do
          flickr.people.should_receive(:findByUsername).with(:username => "USAgency").and_raise "User not found"
        end
        
        it "should not attempt to look up photos, and exit gracefully" do
          flickr.people.should_not_receive(:getPublicPhotos)
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
      
      context "when an error occurs looking up photos" do
        before do
          flickr.people.should_receive(:findByUsername).with(:username => "USAgency").and_return @user_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS).and_raise "Some Error"
          flickr.people.should_not_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2)
          flickr.photos.should_not_receive(:getInfo)
        end
        
        it "should not blow up" do
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
    end
    
    context "when the affiliates url is a Flickr group url" do
      before do
        @affiliate.flickr_url = "http://www.flickr.com/groups/USAgency"
        @group_search_response = [{"nsid"=>"1058319", "name"=>"USA.gov - Official US Government Photostreams", "eighteenplus"=>0}]
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"soup hotandsoursoup umami", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"soup hotandsoursoup umami", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
      end

      context "when the group name is valid and the group has photos" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return @group_search_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS).and_return @first_photos_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668705").once.and_return @photo_info
          flickr.photos.should_receive(:getInfo).with(:photo_id => "3253668675").once.and_return @photo_info
        end
          
        it "should use the Flickr API to lookup the group id and store their photos" do
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 2
          first_photo = FlickrPhoto.first
          first_photo.flickr_id.should == "3253668705"
          first_photo.date_taken.should == Time.parse("2009-02-04 18:41:39 UTC")
          first_photo.date_upload.should == Time.at(1233790899)
          first_photo.is_public.should be_true
          first_photo.is_friend.should be_false
          first_photo.icon_farm.should == 1
          first_photo.icon_server.should == "1"
        end
      end
    
      context "when a group can not be found" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return []
        end
        
        it "should not attempt to look up photos, and exit gracefully" do
          flickr.groups.pools.should_not_receive(:getPhotos)
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
      
      context "when something unexpected gets returned as a group" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return {}
        end
        
        it "should not blow up" do
          flickr.groups.pools.should_not_receive(:getPhotos)
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
      
      context "when an error occurs looking up photos" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return @group_search_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS).and_raise "Some Error"
          flickr.groups.pools.should_not_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2)
          flickr.photos.should_not_receive(:getInfo)
        end
        
        it "should not blow up" do
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
    end
  end
end