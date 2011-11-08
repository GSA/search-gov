require "spec/spec_helper"

describe "affiliates/home/_embed_code_text_area.html.haml" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  context "when locale is set to en" do
    before do
      assign(:affiliate, affiliate)
      render :partial => 'affiliates/home/embed_code_text_area', :locals => { :locale => 'en' }
    end

    it "displays required scripts" do
      rendered.should contain %{var usagov_sayt_url = "http://test.host/sayt?aid=#{affiliate.id}&";}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.bgiframe.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.autocomplete.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/sayt.js" type="text/javascript"></script>}
      rendered.should contain %{<link href="http://test.host/stylesheets/compiled/sayt.css" media="screen" rel="stylesheet" type="text/css" />}
    end

    it "displays search form" do
      rendered.should contain %{<form accept-charset="UTF-8" action="http://test.host/search" method="get">}
      rendered.should contain %{<input id="affiliate" name="affiliate" type="hidden" value="#{affiliate.name}" />}
      rendered.should contain %{<input id="locale" name="locale" type="hidden" value="en" />}
      rendered.should contain %{<input autocomplete="off" class="usagov-search-autocomplete" id="query" name="query" type="text" />}
      rendered.should contain %{<input name="commit" type="submit" value="Search" />}
    end
  end

   context "when locale is set to es" do
    before do
      assign(:affiliate, affiliate)
      render :partial => 'affiliates/home/embed_code_text_area', :locals => { :locale => 'es' }
    end

    it "displays required scripts" do
      rendered.should contain %{var usagov_sayt_url = "http://test.host/sayt?aid=#{affiliate.id}&";}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.bgiframe.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.autocomplete.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/sayt.js" type="text/javascript"></script>}
      rendered.should contain %{<link href="http://test.host/stylesheets/compiled/sayt.css" media="screen" rel="stylesheet" type="text/css" />}
    end

    it "displays search form" do
      rendered.should contain %{<form accept-charset="UTF-8" action="http://test.host/search" method="get">}
      rendered.should contain %{<input id="affiliate" name="affiliate" type="hidden" value="#{affiliate.name}" />}
      rendered.should contain %{<input id="locale" name="locale" type="hidden" value="es" />}
      rendered.should contain %{<input autocomplete="off" class="usagov-search-autocomplete" id="query" name="query" type="text" />}
      rendered.should contain %{<input name="commit" type="submit" value="Search" />}
    end
  end
end