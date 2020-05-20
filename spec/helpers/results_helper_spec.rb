# frozen_string_literal: true

describe ResultsHelper do
  describe '#search_data' do
    let(:search) do
      double('search',
             affiliate: affiliates(:basic_affiliate),
             query: 'rutabaga',
             queried_at_seconds: "1588714504")
    end
    let(:search_vertical) { 'i14y' }

    it 'adds data attributes to #search needed for click tracking' do
      output = search_data(search, search_vertical)
      expected_output = {
        data: {
          a: 'nps.gov',
          v: 'i14y',
          q: 'rutabaga'
        }
      }
      expect(output).to eq expected_output
    end
  end

  describe '#link_to_result_title' do
    it 'makes a link with the added data-click attribute' do
      output = link_to_result_title('test title', 'https://test.gov', '2', 'BOOS')
      expected_output = '<a data-click="{&quot;p&quot;:&quot;2&quot;,'\
                        '&quot;s&quot;:&quot;BOOS&quot;}"'\
                        ' href="https://test.gov">test title</a>'
      expect(output).to eq expected_output
    end
  end
end
