require 'spec_helper'

describe HomeController do
  fixtures :affiliates

  describe "#index" do
    before do
      @affiliate = affiliates(:usagov_affiliate)
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

end
