require 'spec/spec_helper'

describe WidgetsController do
  fixtures :affiliates
  before do
  end

  describe "#trending_searches" do
    context "when affiliate id is not specified do" do
      let(:affiliate) { mock_model(Affiliate, :name => 'usagov', :top_searches_label => 'USA.gov Search Trends')}
      let(:active_top_searches) { mock('active top searches') }

      before do
        Affiliate.should_receive(:find_by_name).with('usagov').and_return(affiliate)
        affiliate.should_receive(:active_top_searches).and_return(active_top_searches)
      end

      context "when format=html" do
        before do
          get :trending_searches, :widget_source => 'usa.gov'
        end

        it { should assign_to(:active_top_searches).with(active_top_searches) }
        it { should assign_to(:widget_source).with('usa.gov') }
        it { should respond_with_content_type :html }
        it { should respond_with :success }
      end

      context "when format=xml and widget_source is blank" do
        before do
          get :trending_searches, :format => 'xml'
        end

        it { should assign_to(:active_top_searches).with(active_top_searches) }
        it { should assign_to(:widget_source).with('xml') }
        it { should respond_with_content_type :xml }
        it { should respond_with :success }
      end

      context "when format=xml and widget source is not blank" do
        before do
          get :trending_searches, :format => 'xml', :widget_source => 'agency'
        end

        it { should assign_to(:active_top_searches).with(active_top_searches) }
        it { should assign_to(:widget_source).with('agency') }
        it { should respond_with_content_type :xml }
        it { should respond_with :success }
      end

      context "when format=json" do
        before do
          get :trending_searches, :format => 'json'
        end

        it { should respond_with :not_acceptable }
      end
    end

    context "when an affiliate id is specified" do
      context "the affiliate exists" do
        let(:affiliate) { affiliates(:basic_affiliate) }
        let(:active_top_searches) { mock('active top searches') }

        before do
          Affiliate.should_receive(:find_by_id).with(affiliate.id).and_return(affiliate)
          affiliate.should_receive(:active_top_searches).and_return active_top_searches
          get :trending_searches, :aid => affiliate.id
        end

        it { should assign_to(:active_top_searches).with(active_top_searches) }
      end

      context "the affiliate does not exist" do
        context "format=html" do
          before do
            Affiliate.should_receive(:find_by_id).with('101').and_return nil
            get :trending_searches, :aid => '101'
          end

          it { should respond_with(:not_found) }
          it { should respond_with_content_type :html }
          its(:response) { should contain('affiliate not found') }
        end

        context "format=xml" do
          before do
            Affiliate.should_receive(:find_by_id).with('101').and_return nil
            get :trending_searches, :aid => '101', :format => 'xml'
          end

          it { should respond_with(:not_found) }
          it { should respond_with_content_type :xml }
          its(:response) { should contain('affiliate not found') }
        end

        context "when format=json" do
          before do
            Affiliate.should_receive(:find_by_id).with('101').and_return nil
            get :trending_searches, :aid => '101', :format => 'json'
          end

          it { should respond_with :not_acceptable }
        end
      end
    end
  end
end
