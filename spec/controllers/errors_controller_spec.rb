require 'spec/spec_helper'

describe ErrorsController do

  describe "#page_not_found" do
    context "when handling a non affiliate request" do
      before do
        get :page_not_found
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template("layouts/application") }
      it { should render_template("page_not_found") }
    end

    context "when handling an affiliate request" do
      fixtures :affiliates
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        get :page_not_found, :name => affiliate.name
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template("layouts/affiliate") }
      it { should render_template("page_not_found") }
    end

    context "when handling a staged affiliate request" do
      fixtures :affiliates
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        get :page_not_found, :name => affiliate.name, :staged => "1"
      end

      it { should assign_to(:affiliate).with(affiliate) }

      it "should copy staged fields" do
        assigns[:affiliate].affiliate_template_id.should == assigns[:affiliate].staged_affiliate_template_id
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:missing) }
      it { should render_template("layouts/affiliate") }
      it { should render_template("page_not_found") }
    end

    context "when handling a mobile request" do
      before do
        iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
        @regular_user_agent = request.env["HTTP_USER_AGENT"]
        request.env["HTTP_USER_AGENT"] = iphone_user_agent
        get :page_not_found
      end

      it { should respond_with(:missing) }
      it { should render_template("public/simple_404.html") }
    end
  end
end
