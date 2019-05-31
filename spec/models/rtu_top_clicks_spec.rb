require 'spec_helper'

describe RtuTopClicks do
  let(:rtu_top_clicks) { RtuTopClicks.new('some ES query body', true) }

  shared_context 'when statistics are available' do
    let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_urls.json")) }

    before do
      allow(ES::ELK.client_reader).to receive(:search).and_return json_response
    end
  end

  describe 'computing top N stats' do
    include_context 'when statistics are available'

    it 'should return an array of [url, count] sorted by desc url count' do
      expect(rtu_top_clicks.top_n).to eq(
        [['http://appropriations.house.gov/subcommittees/subcommittee/?IssueID=34776', 10],
         ['http://assembly.ca.gov/legislativebranch', 9],
         ['http://cs.cpsc.gov/ConceptDemo/SearchCPSC.aspx', 8],
         ['http://livertox.nih.gov/AloeVera.htm', 7],
         ['https://search.usa.gov/search?affiliate=usagov&m=true&query=%2Bhigher+ratingfor+prostate+cancer+jan2014+feb2014+site%3Ava.gov', 6],
         ['http://www.americaslibrary.gov/aa/twain/aa_twain_huckfinn_1.html', 5],
         ['http://www.dol.gov/ebsa/faqs/faq_911_2.html', 4],
         ['http://www.dot.ca.gov/', 3],
         ['http://www.fbi.gov/stats-services/publications/law-enforcement-bulletin/february2011/february-2011-leb.pdf', 2],
         ['http://www.marines.mil/Portals/59/Publications/FMFRP%2012-18%20%20Mao%20Tse-tung%20on%20Guerrilla%20Warfare.pdf', 1]]
      )
    end

    context 'when stats unavailable' do
      before do
        allow(ES::ELK.client_reader).to receive(:search).and_raise StandardError
      end

      it 'should return an empty array' do
        expect(rtu_top_clicks.top_n).to eq([])
      end
    end
  end

  describe '#top_n_to_percentage' do
    subject(:top_n_to_percentage) do
      rtu_top_clicks.top_n_to_percentage(50)
    end

    include_context 'when statistics are available'

    it 'returns the top N percent of all clicks' do
      expect(top_n_to_percentage).to eq ([
        ['http://appropriations.house.gov/subcommittees/subcommittee/?IssueID=34776', 10],
        ['http://assembly.ca.gov/legislativebranch', 9],
        ['http://cs.cpsc.gov/ConceptDemo/SearchCPSC.aspx', 8],
        ['http://livertox.nih.gov/AloeVera.htm', 7],
      ])
    end

    context 'when the result set is small' do
      before do
        allow(rtu_top_clicks).to receive(:top_n).
          and_return([['http://foo.gov/',5]])
      end

      it { is_expected.to eq [['http://foo.gov/',5]] }
    end
  end
end
