require 'spec/spec_helper'

describe ImagesController do
  fixtures :affiliates
  
  describe "#index" do
    before do
      @affiliate = affiliates(:usagov_affiliate)
    end

    context "when no locale is specified" do
      before do
        get :index
      end

      it { should assign_to(:search).with_kind_of(ImageSearch) }
      it { should assign_to(:affiliate).with(@affiliate) }
      it { should respond_with(:success) }

      specify { I18n.locale.should == :en }
    end

    context "when locale is specified" do
      context "locale=en" do
        before do
          get :index, :locale=> "en"
        end

        it { should assign_to(:search).with_kind_of(ImageSearch) }
        it { should assign_to(:affiliate).with(@affiliate) }
        specify { I18n.locale.should == :en }
      end

      context "locale=es" do
        before do
          get :index, :locale=> "es"
        end

        it { should assign_to(:search).with_kind_of(ImageSearch) }
        it { should assign_to(:affiliate).with(affiliates(:gobiernousa_affiliate)) }
        specify { I18n.locale.should == :es }
      end
    end
  end
end
