require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/application.html.haml" do
  before do
    @english_webtrends_tag = 'webtrends_english'
    @spanish_webtrends_tag = 'webtrends_spanish'
  end

  def render_page
    render "home/index.html.haml", :layout=> "application"
  end

  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render_page
      response.body.should contain(@english_webtrends_tag)
    end

    it "should define the SAYT url" do
      render_page
      response.body.should contain(/var usagov_sayt_url =/)
    end
  end

  context "when locale is set to English" do
    before do
      request.params[:locale] = 'en'
    end

    it "should show the English version of the webtrends javascript" do
      render_page
      response.body.should contain(@english_webtrends_tag)
    end
  end

  context "when locale is set to Spanish" do
    before do
      request.params[:locale] = "es"
    end

    it "should show the Spanish version of the webtrends javascript" do
      render_page
      response.body.should contain(@spanish_webtrends_tag)
    end
  end
end
