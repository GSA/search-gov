require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/application.html.haml" do
  def render_page
    render "home/index.html.haml", :layout=> "application"
  end

  before do
    assigns[:active_top_searches] = []
  end

  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render_page
      response.body.should have_tag("script[src=/javascripts/webtrends_english.js][type=text/javascript]")
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
      response.body.should have_tag("script[src=/javascripts/webtrends_english.js][type=text/javascript]")
    end
  end

  context "when locale is set to Spanish" do
    before do
      request.params[:locale] = "es"
    end

    it "should show the Spanish version of the webtrends javascript" do
      render_page
      response.body.should have_tag("script[src=/javascripts/webtrends_spanish.js][type=text/javascript]")
    end
  end
end
