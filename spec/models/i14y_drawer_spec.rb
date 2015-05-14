require 'spec_helper'

describe I14yDrawer do
  fixtures :i14y_drawers, :affiliates
  it { should validate_presence_of :affiliate_id }
  it { should validate_presence_of :handle }
  it { should validate_uniqueness_of :handle }
  it { should ensure_length_of(:handle).is_at_least(3).is_at_most(33) }
  it { should belong_to :affiliate }
  ["UPPERCASE", "weird'chars", "spacey name", "hyphens-are-special-in-i14y"].each do |value|
    it { should_not allow_value(value).for(:handle) }
  end
  %w{data.gov some_aff 123}.each do |value|
    it { should allow_value(value).for(:handle) }
  end

  context 'creating a drawer' do
    before do
      Digest::SHA256.stub(:base64digest).and_return "mytoken"
    end

    it 'creates collection in i14y and assigns token' do
      response = Hashie::Mash.new('status' => 200, "developer_message" => "OK", "user_message" => "blah blah")
      I14yCollections.should_receive(:create).with("settoken", "mytoken").and_return response
      i14y_drawer = Affiliate.first.i14y_drawers.create!(handle: "settoken")
      i14y_drawer.token.should eq("mytoken")
    end

    context 'create call to i14y Collection API fails' do
      before do
        I14yCollections.should_receive(:create).and_raise Exception
      end

      it 'should not create the I14yDrawer' do
        Affiliate.first.i14y_drawers.create(handle: "settoken")
        I14yDrawer.exists?(handle: 'settoken').should be_false
      end
    end
  end

  context 'deleting a drawer' do
    it 'deletes collection in i14y' do
      response = Hashie::Mash.new('status' => 200, "developer_message" => "OK", "user_message" => "blah blah")
      I14yCollections.should_receive(:delete).with("one").and_return response
      i14y_drawers(:one).destroy
    end

    context 'delete call to i14y Collection API fails' do
      before do
        I14yCollections.should_receive(:delete).and_raise Exception
      end

      it 'should not delete the I14yDrawer' do
        i14y_drawers(:one).destroy
        I14yDrawer.exists?(handle: 'one').should be_true
      end
    end
  end

  describe "#label" do
    it "should return the handle" do
      i14y_drawers(:one).label.should == i14y_drawers(:one).handle
    end
  end

end
