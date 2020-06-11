# frozen_string_literal: true

describe ResultsHelper do
  describe '#search_data' do
    let(:search) do
      double('search',
             affiliate: affiliates(:basic_affiliate),
             query: 'rutabaga')
    end

    subject { search_data(search, 'i14y') }

    it 'adds data attributes to #search needed for click tracking' do
      expected_output = {
        data: {
          affiliate: 'nps.gov',
          vertical: 'i14y',
          query: 'rutabaga'
        }
      }

      expect(subject).to eq expected_output
    end
  end

  describe '#link_to_result_title' do
    subject { link_to_result_title('test title', 'https://test.gov', '2', 'BOOS') }

    it 'makes a link with the added data-click attribute' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,'\
                        '&quot;module_code&quot;:&quot;BOOS&quot;}"'\
                        ' href="https://test.gov">test title</a>'

      expect(subject).to eq expected_output
    end
  end
end
