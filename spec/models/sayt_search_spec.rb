require 'spec_helper'

describe SaytSearch do
  fixtures :affiliates, :form_agencies
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:es_affiliate) { affiliates(:gobiernousa_affiliate) }
  let(:affiliate_id) { affiliates(:usagov_affiliate).id }

  let(:sayt_suggestions) do
    sayt_suggestion1 = mock_model(SaytSuggestion, :phrase => 'foo1')
    sayt_suggestion2 = mock_model(SaytSuggestion, :phrase => 'foo2')
    [sayt_suggestion1, sayt_suggestion2]
  end

  context 'when affiliate_id and query are present' do
    let(:query) { 'foo' }
    let(:search_params) { { affiliate_id: affiliate.id, query: query, number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    let(:forms) do
      form1 = mock_model(Form,
                         number: 'I-100',
                         title: 'Foo Verified Form',
                         landing_page_url: 'http://www.agency.gov/form1.html')
      form2 = mock_model(Form,
                         number: 'I-200',
                         title: 'Foo Another Verified Form',
                         landing_page_url: 'http://www.agency.gov/form2.html')
      [form1, form2]
    end

    let(:boosted_contents) do
      boosted_content1 = mock_model(BoostedContent,
                                    title: 'Foo Boosted Content 1',
                                    url: 'http://www.agency.gov/boosted_content1.html')
      boosted_content2 = mock_model(BoostedContent,
                                    title: 'Foo Boosted Content 2',
                                    url: 'http://www.agency.gov/boosted_content2.html')
      [boosted_content1, boosted_content2]
    end

    it 'should correct query misspelling' do
      search_params[:query] = 'chold'

      Misspelling.should_receive(:correct).with('chold').and_return('child')
      Form.should_receive(:sayt_for).with(affiliate_id, 'child', 2).and_return([])
      BoostedContent.should_receive(:sayt_for).with(affiliate_id, 'child', 2).and_return([])
      SaytSuggestion.should_receive(:fetch_by_affiliate_id).with(affiliate_id, 'child', 10).and_return([])

      search.results.should == []
    end

    it 'should return an array of hash' do
      Form.should_receive(:sayt_for).with(affiliate_id, 'foo', 2).and_return(forms)
      BoostedContent.should_receive(:sayt_for).with(affiliate_id, 'foo', 2).and_return(boosted_contents)
      SaytSuggestion.should_receive(:fetch_by_affiliate_id).with(affiliate_id, 'foo', 6).and_return(sayt_suggestions)

      search.results.should == [{ section: 'default', label: 'foo1' },
                                { section: 'default', label: 'foo2' },
                                { section: 'Recommended Forms', label: 'Foo Verified Form (I-100)', data: 'http://www.agency.gov/form1.html' },
                                { section: 'Recommended Forms', label: 'Foo Another Verified Form (I-200)', data: 'http://www.agency.gov/form2.html' },
                                { section: 'Recommended Pages', label: 'Foo Boosted Content 1', data: 'http://www.agency.gov/boosted_content1.html' },
                                { section: 'Recommended Pages', label: 'Foo Boosted Content 2', data: 'http://www.agency.gov/boosted_content2.html' }]
    end
  end

  context 'when affiliate_id is not present' do
    let(:search_params) { { query: 'foo', number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      Form.should_not_receive(:sayt_for)
      BoostedContent.should_not_receive(:sayt_for)
      SaytSuggestion.should_not_receive(:fetch_by_affiliate_id)

      search.results.should == []
    end
  end

  context 'when query is not present' do
    let(:search_params) { { affiliate_id: affiliate_id, number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      Form.should_not_receive(:sayt_for)
      BoostedContent.should_not_receive(:sayt_for)
      SaytSuggestion.should_not_receive(:fetch_by_affiliate_id)

      search.results.should == []
    end
  end

  context 'when extras is false' do
    let(:search_params) { { affiliate_id: affiliate_id, query: 'foo', number_of_results: 10, extras: false } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      Form.should_not_receive(:sayt_for)
      BoostedContent.should_not_receive(:sayt_for)
      SaytSuggestion.should_receive(:fetch_by_affiliate_id).and_return(sayt_suggestions)

      search.results.should == %w(foo1 foo2)
    end
  end
end
