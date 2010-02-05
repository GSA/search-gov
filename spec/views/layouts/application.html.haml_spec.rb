require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/application.html.haml" do
  before do
    @webtrends_tag = 'var _tag=new WebTrends();'
    @english_webtrends_tag = 'webtrends_english'
    @spanish_webtrends_tag = 'webtrends_spanish'
  end

  def render_page
    render "home/index.html.haml", :layout=> "application"
  end
  
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render_page
      response.should contain(@english_webtrends_tag)
    end
  end
  
  context "when locale is set to English" do
    before do
      request.params[:locale] = 'en'
    end
    
    it "should show the English version of the webtrends javascript" do
      render_page
      response.should contain(@english_webtrends_tag)
    end  
  end
  
  context "when locale is set to Spanish" do
    before do
      request.params[:locale] = "es"
    end
    
    it "should show the Spanish version of the webtrends javascript" do
      render_page
      response.should contain(@spanish_webtrends_tag)
    end
  end
  
end
