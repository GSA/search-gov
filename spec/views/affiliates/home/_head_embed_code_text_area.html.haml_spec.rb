require "spec/spec_helper"

describe "affiliates/home/_head_embed_code_text_area.html.haml" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  context "when locale is set to en" do
    before do
      assign(:affiliate, affiliate)
      render :partial => 'affiliates/home/head_embed_code_text_area', :locals => { :locale => 'en' }
    end

    it "displays required scripts" do
      rendered.should contain %{var usagov_sayt_url = "http://test.host/sayt?aid=#{affiliate.id}&";}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.bgiframe.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.autocomplete.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/sayt.js" type="text/javascript"></script>}
      rendered.should contain %{<link href="http://test.host/stylesheets/compiled/sayt.css" media="screen" rel="stylesheet" type="text/css" />}
    end
  end

   context "when locale is set to es" do
    before do
      assign(:affiliate, affiliate)
      render :partial => 'affiliates/home/head_embed_code_text_area', :locals => { :locale => 'es' }
    end

    it "displays required scripts" do
      rendered.should contain %{var usagov_sayt_url = "http://test.host/sayt?aid=#{affiliate.id}&";}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.bgiframe.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/jquery/jquery.autocomplete.min.js" type="text/javascript"></script>}
      rendered.should contain %{<script src="http://test.host/javascripts/sayt.js" type="text/javascript"></script>}
      rendered.should contain %{<link href="http://test.host/stylesheets/compiled/sayt.css" media="screen" rel="stylesheet" type="text/css" />}
    end
  end
end