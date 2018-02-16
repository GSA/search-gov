require 'spec_helper'

describe I14yDrawerHelper do
  fixtures :i14y_drawers

  describe "i14y_drawer_data_row(i14y_drawer)" do
    let(:i14y_drawer) { i14y_drawers(:one) }
    context 'stats are present' do
      context 'documents exist' do
        before do
          allow(i14y_drawer).to receive(:stats).and_return Hashie::Mash.new('document_total' => 1, 'last_document_sent' => "2015-06-12T16:59:50+00:00")
        end

        it "displays all fields" do
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("one")
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("first drawer")
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("1")
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content(time_ago_in_words(Time.parse("2015-06-12T16:59:50+00:00")))
        end
      end
      context 'documents do not exist' do
        before do
          allow(i14y_drawer).to receive(:stats).and_return Hashie::Mash.new('document_total' => 0, 'last_document_sent' => nil)
        end

        it "displays all but last sent" do
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("one")
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("first drawer")
          expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("0")
        end
      end
    end
    context 'stats are present' do
      before do
        allow(i14y_drawer).to receive(:stats)
      end

      it "displays handle and description" do
        expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("one")
        expect(helper.i14y_drawer_data_row(i14y_drawer)).to have_content("first drawer")
      end

    end
  end

  describe '#deletion_confirmation' do
    subject(:deletion_confirmation) { helper.deletion_confirmation(drawer) }
    let(:confirmation_for_one_affiliate) do
      "Removing this drawer from this site will delete it from the system. Are you sure you want to delete it?"
    end

    context 'when the drawer has one owner' do
      let(:drawer) { I14yDrawer.new }
      before { allow(drawer).to receive_message_chain(:affiliates, :count).and_return(1) }

      it { is_expected.to eq confirmation_for_one_affiliate }
    end

    context 'when the drawer is shared among affiliates' do
      let(:drawer) { I14yDrawer.new }
      let(:confirmation_for_shared_drawer) do
        "Are you sure you want to remove this drawer from this site?"
      end

      before { allow(drawer).to receive_message_chain(:affiliates, :count).and_return(5) }

      it { is_expected.to eq confirmation_for_shared_drawer }
    end
  end
end
