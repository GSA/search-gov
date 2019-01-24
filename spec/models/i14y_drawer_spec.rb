require 'spec_helper'

describe I14yDrawer do
  fixtures :i14y_drawers, :affiliates, :i14y_memberships

  let(:drawer) { i14y_drawers(:one) }

  it { is_expected.to validate_presence_of :handle }
  it { is_expected.to validate_uniqueness_of :handle }
  it { is_expected.to validate_length_of(:handle).is_at_least(3).is_at_most(33) }
  it { is_expected.to have_many(:i14y_memberships).dependent(:destroy) }
  it { is_expected.to have_many(:affiliates).through :i14y_memberships }
  ["UPPERCASE", "weird'chars", "spacey name", "hyphens-are-special-in-i14y",
   "periods.are.bad", "hiding\nnaughti.ness"].each do |value|
    it { is_expected.not_to allow_value(value).for(:handle) }
  end
  %w{datagov123 some_aff 123}.each do |value|
    it { is_expected.to allow_value(value).for(:handle) }
  end

  context 'creating a drawer' do
    before do
      allow(SecureRandom).to receive(:hex).with(16).and_return "0123456789abcdef"
    end

    it 'creates collection in i14y and assigns token' do
      response = Hashie::Mash.new('status' => 200, "developer_message" => "OK", "user_message" => "blah blah")
      expect(I14yCollections).to receive(:create).with("settoken", "0123456789abcdef").and_return response
      i14y_drawer = Affiliate.first.i14y_drawers.create!(handle: "settoken")
      expect(i14y_drawer.token).to eq("0123456789abcdef")
    end

    context 'create call to i14y Collection API fails' do
      before do
        expect(I14yCollections).to receive(:create).and_raise StandardError
      end

      it 'should not create the I14yDrawer' do
        Affiliate.first.i14y_drawers.create(handle: "settoken")
        expect(I14yDrawer.exists?(handle: 'settoken')).to be false
      end
    end
  end

  context 'deleting a drawer' do
    it 'deletes collection in i14y' do
      response = Hashie::Mash.new('status' => 200, "developer_message" => "OK", "user_message" => "blah blah")
      expect(I14yCollections).to receive(:delete).with("one").and_return response
      i14y_drawers(:one).destroy
    end

    context 'delete call to i14y Collection API fails' do
      before do
        expect(I14yCollections).to receive(:delete).and_raise StandardError
      end

      it 'should not delete the I14yDrawer' do
        i14y_drawers(:one).destroy
        expect(I14yDrawer.exists?(handle: 'one')).to be true
      end
    end
  end

  describe "#label" do
    it "should return the handle" do
      expect(i14y_drawers(:one).label).to eq(i14y_drawers(:one).handle)
    end
  end

  describe '#stats' do
    subject(:stats) { drawer.stats }

    let(:collection)  do
      Hashie::Mash.new(created_at: '2015-06-12T16:59:50.687+00:00',
                       updated_at: '2015-06-12T16:59:50.687+00:00',
                       token: '6bffe2fe778ba131f28c93377e0630a8',
                       id: 'one',
                       document_total: 1,
                       last_document_sent: '2015-06-12T16:59:50+00:00')
    end

    context 'when stats are available' do
      let(:response) do
        Hashie::Mash.new(status: 200,
                         developer_message: 'OK',
                         collection: collection)
      end

      before do
        expect(I14yCollections).to receive(:get).with('one').and_return response
      end

      it 'gets the collection from I14y endpoint and returns the collection info' do
        expect(drawer.stats).to eq(collection)
      end
    end

    context 'when something goes wrong' do
      before do
        allow(I14yCollections).to receive(:get).with('one').
          and_raise StandardError.new('fail')
      end

      it 'returns nil' do
        expect(drawer.stats).to eq nil
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).
          with(/Trouble fetching statistics for the one drawer/)
        drawer.stats
      end
    end
  end

  describe '#i14y_connection' do
    let(:drawer) { I14yDrawer.new(handle: 'handle', token: 'foobarbaz') }
    let(:i14y_connection) { double(Faraday::Connection) }

    it 'establishes a connection based on the drawer handle & token' do
      expect(I14y).to receive(:establish_connection!).with(user: 'handle', password: 'foobarbaz')
      drawer.i14y_connection
    end

    it 'memoizes the connection' do
      expect(I14y).to receive(:establish_connection!).once.
        with(user: 'handle', password: 'foobarbaz').
        and_return(i14y_connection)
      2.times { drawer.i14y_connection }
    end
  end
end
