require 'spec_helper'

describe 'sayt' do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:phrases) { ['lorem ipsum dolor sit amet', 'lorem ipsum sic transit gloria'].freeze }
  let(:phrases_in_json) { phrases.to_json.freeze }
  let(:phrases_with_section_and_label_in_json) do
    phrases.collect { |p| { section: 'default', label: p } }.to_json.freeze
  end

  before do
    SaytController.class_eval {
      def is_mobile_device?;
        false;
      end }

    SaytSuggestion.destroy_all
    phrases.each do |p|
      SaytSuggestion.create!(:phrase => p, :affiliate => affiliate)
    end
  end

  context 'when name and query are present' do
    it 'returns an array of suggestions' do
      get '/sayt', params: { q: 'lorem  \\  ipsum',
                             callback: 'jsonp1234',
                             aid: affiliate.id }
      expect(response.body).to eq(%Q{/**/jsonp1234(#{phrases_in_json})})
    end

    it "returns empty JSONP if nothing matches the 'q' param string" do
      get '/sayt', params: { q: 'who moved my cheese',
                             callback: 'jsonp1276290049647',
                             aid: affiliate.id }
      expect(response.body).to eq('/**/jsonp1276290049647([])')
    end

    it 'does not completely melt down when strange characters are present' do
      expect do
        get '/sayt', params: { q: "foo\\", callback: 'jsonp1276290049647', aid: affiliate.id }
      end.not_to raise_error
      expect do
        get '/sayt', params: { q: "foo's", callback: 'jsonp1276290049647', aid: affiliate.id }
      end.not_to raise_error
    end
  end

  context 'when extras is present' do
    it 'returns jsonp with section and label' do
      get '/sayt', params: { name: affiliate.name,
                             q: 'lorem \\ ipsum',
                             callback: 'jsonp1234',
                             extras: 'true' }
      expect(response.body).to eq(%Q{/**/jsonp1234(#{phrases_with_section_and_label_in_json})})
    end

    context 'when there are boosted contents' do
      before do
        BoostedContent.create!(affiliate_id: affiliate.id,
                               title: 'Lorem Boosted Content 1',
                               description: 'Boosted Content Description',
                               url: 'http://agency.gov/boosted_content1.html',
                               status: 'active',
                               publish_start_on: Date.today)

        BoostedContent.create!(affiliate_id: affiliate.id,
                               title: 'Lorem Boosted Content 2',
                               description: 'Boosted Content Description',
                               url: 'http://agency.gov/boosted_content2.html',
                               status: 'active',
                               publish_start_on: Date.current.tomorrow)

        BoostedContent.create!(affiliate_id: affiliate.id,
                               title: 'Lorem Boosted Content 3 inactive',
                               description: 'Boosted Content Description',
                               url: 'http://agency.gov/boosted_content3.html',
                               status: 'inactive',
                               publish_start_on: Date.today)
      end

      it 'returns results with SaytSuggestions and Boosted Contents' do
        get '/sayt', params: { name: affiliate.name,
                               q: 'lorem',
                               callback: 'jsonp1234',
                               extras: 'true' }
        results = phrases.collect { |p| { section: 'default', label: p } }
        results << { section: 'Recommended Pages', label: 'Lorem Boosted Content 1', data: 'http://agency.gov/boosted_content1.html'}
        expect(response.body).to eq(%Q{/**/jsonp1234(#{results.to_json})})
      end

      it 'does not return SAYT results that do not start with query' do
        get '/sayt', params: { name: affiliate.name,
                               q: 'orem',
                               callback: 'jsonp1234',
                               extras: 'true' }
        expect(response.body).to eq('/**/jsonp1234([])')
      end

      it 'does not return Boosted Contents that do not start with query' do
        get '/sayt', params: { name: affiliate.name,
                               q: 'Boosted',
                               callback: 'jsonp1234',
                               extras: 'true' }
        expect(response.body).to eq('/**/jsonp1234([])')
      end
    end

  end

  context 'when request is from mobile device' do
    before do
      SaytController.class_eval do
        def is_mobile_device?;
          true;
        end
      end
    end

    it 'searches for suggestions' do
      get '/sayt', params: { name: affiliate.name,
                             q: 'lorem \\ ipsum',
                             callback: 'jsonp1234' }
      expect(response.body).to eq(%Q{/**/jsonp1234(#{phrases_in_json})})
    end
  end
end
