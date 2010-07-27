require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "searches/advanced.html.haml" do

  context "visiting the English language (default) page" do
    it "should display text via the I18n in English" do
      render
      response.should contain(/Use the options on this page to create a very specific search./)
    end
  end
  
  context "visiting the Spanish version of the page" do
    before do
      I18n.locale = :es
    end
    
    it "should display text in Spanish" do
      render
      response.should contain(/Use las opciones a continuación para hacer una búsqueda específica./)
    end
    
    it "should display a hidden input field with the locale" do
      render
      response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'locale', 'es')
    end
    
    after do
      I18n.locale = I18n.default_locale
    end
  end 
  
  context "when visiting an affiliate advanced search page" do
    fixtures :affiliates
    
    it "should include a hidden input tag with the affiliate" do
      assigns[:affiliate] = affiliates(:power_affiliate)
      render
      response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'affiliate', affiliates(:power_affiliate).name)
    end
    
    it "should include a hidden input tag with the scope id if a scope id is passed" do
      assigns[:affiliate] = affiliates(:power_affiliate)
      assigns[:scope_id] = 'SomeScope'
      render
      response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'scope_id', 'SomeScope')
    end
  end
end
