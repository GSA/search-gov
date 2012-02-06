require 'spec/spec_helper'

describe HomeController do

  describe "#index" do
    let(:affiliate) { mock_model(Affiliate) }

    context "when no locale is specified" do
      before do
        Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
        get :index
      end

      it { should assign_to(:search).with_kind_of(WebSearch) }
      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }

      specify { I18n.locale.should == I18n.default_locale }

      it "should assign a local server hash indicating which datacenter served the request" do
        assigns[:rails_server_location_in_html_comment_for_opsview].should be_instance_of(String)
      end
    end

    context "when locale is specified" do
      context "locale=en" do
        it "should set locale to :en" do
          Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
          get :index, :locale=> "en"
          I18n.locale.should == :en
        end
      end

      context "locale=es" do
        it "should set locale to :es" do
          Affiliate.should_receive(:find_by_name).with('gobiernousa').and_return(affiliate)
          get :index, :locale=> "es"
          I18n.locale.should == :es
        end
      end

      context "that is invalid" do
        before do
          Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
          get :index, :locale=> "hp:webinspect..file*test"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end

      context "that is malicious" do
        before do
          Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
          get :index, :locale=> "\0"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end

      context "that is erroneous" do
        before do
          Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
          get :index, :locale=> "fr"
        end
        it "should set locale to :en" do
          I18n.locale.should == :en
        end
      end
    end
  end

  describe "#contact_form" do
    it "should display a form in mobile mode" do
      iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
      request.env["HTTP_USER_AGENT"] = iphone_user_agent
      get :contact_form, :m => "true"
      response.should be_success
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
