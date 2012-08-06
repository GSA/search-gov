require "spec/spec_helper"

describe "affiliates/home/_bottom_page_embed_code_text_area.html.haml" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  context "when locale is set to en" do
    before do
      assign(:affiliate, affiliate)
      affiliate.should_receive(:locale).and_return('en')
      render :partial => 'affiliates/home/bottom_page_embed_code_text_area'
    end

    it "displays required scripts" do
      rendered.should have_selector('#embed_code_textarea_en')
      rendered.should contain %[var usasearch_config = { siteHandle:"nps.gov" };]
      rendered.should contain %[var script = document.createElement("script");]
      rendered.should contain %[script.type = "text/javascript";]
      rendered.should contain %[script.src = "http://test.host/javascripts/remote.loader.js";]
      rendered.should contain %[document.getElementsByTagName("head")[0].appendChild(script);]
    end
  end

   context "when locale is set to es" do
    before do
      assign(:affiliate, affiliate)
      affiliate.should_receive(:locale).and_return('es')
      render :partial => 'affiliates/home/bottom_page_embed_code_text_area'
    end

    it "displays required scripts" do
      rendered.should have_selector('#embed_code_textarea_es')
      rendered.should contain %[var usasearch_config = { siteHandle:"nps.gov" };]
      rendered.should contain %[var script = document.createElement("script");]
      rendered.should contain %[script.type = "text/javascript";]
      rendered.should contain %[script.src = "http://test.host/javascripts/remote.loader.js";]
      rendered.should contain %[document.getElementsByTagName("head")[0].appendChild(script);]
    end
  end
end
