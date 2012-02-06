require 'spec/spec_helper'

describe ImagesController do
  describe "#index" do
    let(:affiliate) { mock_model(Affiliate) }

    context "when no locale is specified" do
      before do
        Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
        get :index
      end

      it { should assign_to(:search).with_kind_of(ImageSearch) }
      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }

      specify { I18n.locale.should == :en }
    end

    context "when locale is specified" do
      context "locale=en" do
        before do
          Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
          get :index, :locale=> "en"
        end

        it { should assign_to(:search).with_kind_of(ImageSearch) }
        it { should assign_to(:affiliate).with(affiliate) }
        specify { I18n.locale.should == :en }
      end

      context "locale=es" do
        before do
          Affiliate.should_receive(:find_by_name).with('gobiernousa').and_return(affiliate)
          get :index, :locale=> "es"
        end

        it { should assign_to(:search).with_kind_of(ImageSearch) }
        it { should assign_to(:affiliate).with(affiliate) }
        specify { I18n.locale.should == :es }
      end
    end
  end
end
