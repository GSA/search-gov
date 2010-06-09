require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageSearchesController do

  context "when searching via the API" do
    integrate_views
  
    context "when searching normally" do
      before do
        get :index, :query => 'weather', :format => "json"
        @search = assigns[:search]
      end
  
      it "should set the format to json" do
        response.content_type.should == "application/json"
      end
  
      it "should serialize the results into JSON" do
        response.body.should =~ /total/
        response.body.should =~ /startrecord/
        response.body.should =~ /endrecord/
      end
    end
      
    context "when some error is returned" do
      before do
        get :index, :query => 'a' * 1001, :format => "json"
        @search = assigns[:search]
      end
    
      it "should serialize an error into JSON" do
        response.body.should =~ /error/
        response.body.should =~ /#{I18n.translate :too_long}/
      end
    end
  end
end