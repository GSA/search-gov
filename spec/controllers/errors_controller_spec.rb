require 'spec_helper'

describe ErrorsController do
  fixtures :affiliates

  describe "#page_not_found" do
    context "when handling a non affiliate request" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
        get :page_not_found
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template('layouts/searches') }
      it { should render_template("page_not_found") }
    end

    context "when handling a Spanish non affiliate request" do
      let(:affiliate) { affiliates(:gobiernousa_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).with('gobiernousa').and_return(affiliate)
        get :page_not_found, :locale => 'es'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template('layouts/searches') }
      it { should render_template("page_not_found") }
    end

    context "when handling an affiliate request" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        get :page_not_found, :name => affiliate.name
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template('layouts/searches') }
      it { should render_template("page_not_found") }
    end

    context 'when handling static asset format' do
      before do
        Affiliate.should_not_receive(:find_by_name)
        get :page_not_found, format: :js
      end

      it { should respond_with(:missing) }
      it { should_not render_template('layouts/searches') }
    end
  end
end
