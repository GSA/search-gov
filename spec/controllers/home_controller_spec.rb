require 'spec_helper'

describe HomeController do
  fixtures :affiliates

  describe "#index" do
    before do
      @affiliate = affiliates(:usagov_affiliate)
    end

    it "should assign geoip info" do
      GeoipLookup.stub!(:lookup).and_return OpenStruct.new(:region_name => 'CA')
      get :index
      assigns[:geoip_info].region_name.should == 'CA'
    end

    context "when no locale is specified" do
      before do
        get :index
      end

      it { should assign_to(:search).with_kind_of(WebSearch) }
      it { should assign_to(:affiliate).with(@affiliate) }
      it { should respond_with(:success) }

      specify { I18n.locale.should == I18n.default_locale }
    end

    context "when locale is specified" do
      context "locale=en" do
        it "should set locale to :en" do
          get :index, :locale=> "en"
          I18n.locale.should == :en
        end
      end

      context "locale=es" do
        it "should set locale to :es" do
          get :index, :locale=> "es"
          I18n.locale.should == :es
        end
      end

      context "that is invalid" do
        before do
          get :index, :locale=> "hp:webinspect..file*test"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end

      context "that is malicious" do
        before do
          get :index, :locale=> "\0"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end

      context "that is erroneous" do
        before do
          get :index, :locale=> "fr"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end
    end

    context "when format is xml" do
      before do
        get :index, :locale=> "en", :format => 'xml'
      end

      it { should respond_with :not_acceptable }
    end
  end

  describe "#contact_form" do
    context 'when rendering from mobile device' do
      before do
        iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
        request.env["HTTP_USER_AGENT"] = iphone_user_agent
      end

      it "should display a form in mobile mode" do
        iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
        request.env["HTTP_USER_AGENT"] = iphone_user_agent
        get :contact_form, :m => "true"
        response.should be_success
      end

      context 'when locale is not a string' do
        before { get :contact_form, m: 'true', locale: %w(foo) }

        it { should respond_with(:success) }
      end
    end

    it "should redirect to errors#page_not_found if not in mobile mode" do
      get :contact_form, :m => "false"
      response.should redirect_to(page_not_found_path)
    end

    it "should redirect to errors#page_not_found if no mode is specified" do
      get :contact_form
      response.should redirect_to(page_not_found_path)
    end
  end
end
