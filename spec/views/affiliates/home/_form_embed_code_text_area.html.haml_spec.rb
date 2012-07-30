require "spec/spec_helper"

describe "affiliates/home/_form_embed_code_text_area.html.haml" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  context "when locale is set to en" do
    before do
      assign(:affiliate, affiliate)
      affiliate.should_receive(:locale).and_return('en')
      render :partial => 'affiliates/home/form_embed_code_text_area'
    end

    it "displays search form" do
      rendered.should contain %{<form accept-charset="UTF-8" action="http://test.host/search" id="search_form" method="get">}
      rendered.should contain %{<input id="affiliate" name="affiliate" type="hidden" value="#{affiliate.name}" />}
      rendered.should contain %{<input autocomplete="off" class="usagov-search-autocomplete" id="query" name="query" type="text" />}
      rendered.should contain %{<input name="commit" type="submit" value="Search" />}
    end
  end

   context "when locale is set to es" do
    before do
      assign(:affiliate, affiliate)
      affiliate.should_receive(:locale).and_return('es')
      render :partial => 'affiliates/home/form_embed_code_text_area'
    end

    it "displays search form" do
      rendered.should contain %{<form accept-charset="UTF-8" action="http://test.host/search" id="search_form" method="get">}
      rendered.should contain %{<input id="affiliate" name="affiliate" type="hidden" value="#{affiliate.name}" />}
      rendered.should contain %{<input autocomplete="off" class="usagov-search-autocomplete" id="query" name="query" type="text" />}
      rendered.should contain %{<input name="commit" type="submit" value="Search" />}
    end
  end
end