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
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024", "o_height" => "120"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2 
      end
      
      context "when the user name is valid, and the user has photos" do
        before do
          flickr.people.should_receive(:findByUsername).with(:username => "USAgency").and_return @user_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS).and_return @first_photos_response
          flickr.people.should_receive(:getPublicPhotos).with(:user_id => "12345", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
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
        @first_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091648", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668705", "server"=>"3264", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:39", "tags"=>"", "views"=>"40", "url_q"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_q.jpg", "height_q"=>"150", "dateupload"=>"1233790899", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_t.jpg", "height_t"=>"75", "secret"=>"b452012751", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3264/3253668705_b452012751_b.jpg", "width_l"=>"1024"}]
        @first_photos_response.stub!(:pages).and_return 2
        @first_photos_response.stub!(:page).and_return 1
        @second_photos_response = [{"lastupdate"=>"1233790918", "url_m"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6.jpg", "width_m"=>"500", "height_l"=>"768", "ispublic"=>1, "latitude"=>0, "width_sq"=>75, "height_m"=>"375", "url_n"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_n.jpg", "width_n"=>"320", "farm"=>4, "title"=>"0203091702", "height_sq"=>75, "height_n"=>240, "license"=>"1", "datetakengranularity"=>"0", "accuracy"=>0, "url_sq"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_s.jpg", "url_z"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_z.jpg", "width_z"=>"640", "iconfarm"=>1, "pathalias"=>"greggersh", "width_q"=>"150", "height_z"=>480, "id"=>"3253668675", "server"=>"3118", "isfamily"=>0, "datetaken"=>"2009-02-04 18:41:37", "tags"=>"", "views"=>"32", "url_q"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_q.jpg", "height_q"=>"150", "dateupload"=>"1233790897", "media"=>"photo", "media_status"=>"ready", "width_s"=>"240", "width_t"=>"100", "url_s"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_m.jpg", "height_s"=>"180", "description"=>"", "longitude"=>0, "context"=>0, "url_t"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_t.jpg", "height_t"=>"75", "secret"=>"5f79044fb6", "owner"=>"35034349064@N01", "isfriend"=>0, "ownername"=>"GregGersh", "iconserver"=>"1", "machine_tags"=>"", "url_l"=>"http://farm4.staticflickr.com/3118/3253668675_5f79044fb6_b.jpg", "width_l"=>"1024"}]
        @second_photos_response.stub!(:pages).and_return 2
        @second_photos_response.stub!(:page).and_return 2
      end

      context "when the group name is valid and the group has photos" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return @group_search_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS).and_return @first_photos_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2).and_return @second_photos_response
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
      
      context "when an error occurs looking up photos" do
        before do
          flickr.groups.should_receive(:search).with(:text => "USAgency").and_return @group_search_response
          flickr.groups.pools.should_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS).and_raise "Some Error"
          flickr.groups.pools.should_not_receive(:getPhotos).with(:group_id => "1058319", :extras => FlickrPhoto::EXTRA_FIELDS, :page => 2)
        end
        
        it "should not blow up" do
          FlickrPhoto.import_photos(@affiliate)
          FlickrPhoto.count.should == 0
        end
      end
    end
  end
end