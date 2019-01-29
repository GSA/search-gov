require 'spec_helper'

describe "shared/_searchresults.html.haml" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = double("WebSearch", has_photos?: false, med_topic: nil, jobs: nil,
                   has_boosted_contents?: false, has_related_searches?: false,
                   has_featured_collections?: false, has_video_news_items?: false,
                   has_news_items?: false, agency: nil, tweets: nil, query: "tax forms", affiliate: @affiliate,
                   page: 1, spelling_suggestion: nil, queried_at_seconds:1271978870,
                   error_message: nil, scope_id: nil, first_page?: true, matching_site_limits: [], module_tag:'BWEB',
                   startrecord: 1, endrecord: 10, total: 20)

    @search_result = {'title' => "some title",
                      'unescapedUrl' => "http://www.foo.com/url",
                      'content' => "This is a sample result",
                      'cacheUrl' => "http://www.cached.com/url"
    }
    @search_results = []
    20.times { @search_results << @search_result }
    allow(@search_results).to receive(:total_pages).and_return 1
    allow(@search).to receive(:results).and_return @search_results

    assign(:search, @search)
  end

  context "when page is displayed" do
    before do
      allow(view).to receive(:search).and_return @search
    end

    context "when featured collections are present" do
      before do
        stub_template "shared/_featured_collections.html.haml" => "featured collections"
        allow(@search).to receive(:has_boosted_contents?).and_return(false)
        allow(@search).to receive(:has_featured_collections?).and_return(true)
        allow(@search).to receive(:matching_site_limit).and_return("someaffiliate.gov")
      end

      it "should show featured collection" do
        render
        expect(rendered).to have_content('featured collections')
      end
    end

    context 'when results are by USASearch' do
      it 'should show the Bing logo' do
        render
        expect(rendered).
          to have_selector("img[src^='/assets/searches/binglogo_en']")
        expect(rendered).
          not_to have_selector("a img[src^='/assets/searches/binglogo_en']")
      end
    end

    context 'when results are by USASearch' do
      before do
        allow(@search).to receive(:module_tag).and_return 'AIDOC'
        allow(view).to receive(:search).and_return @search
      end

      it 'should show the English USASearch results by logo' do
        render
        expect(rendered).
          to have_selector(
            'a[href="https://search.gov"] ' \
            'img[src^="/assets/searches/results_by_usasearch_en"]'
          )
      end

      context 'when the locale is Spanish' do
        before do
          allow(I18n).to receive(:locale).and_return :es
        end

        it 'should show the Spanish USASearch results by logo' do
          render
          expect(rendered).
            to have_selector(
              'a[href="https://search.gov"] ' \
              'img[src^="/assets/searches/results_by_usasearch_es"]'
            )
        end
      end
    end

    context 'when results are by Google' do
      before do
        allow(@search).to receive(:module_tag).and_return 'GWEB'
        allow(view).to receive(:search).and_return @search
      end

      it 'should show the English Google results by logo' do
        render
        expect(rendered).
          to have_selector('img[src^="/assets/searches/googlelogo_en"]')
        expect(rendered).
          not_to have_selector('a img[src^="/assets/searches/googlelogo_en"]')
      end

      context 'when the locale is Spanish' do
        before do
          allow(I18n).to receive(:locale).and_return :es
        end

        it 'should show the Spanish Google results by logo' do
          render
          expect(rendered).
            to have_selector('img[src^="/assets/searches/googlelogo_es"]')
          expect(rendered).
            not_to have_selector('a img[src^="/assets/searches/googlelogo_es"]')
        end
      end
    end

    context "when on anything but the first page" do
      before do
        allow(@search).to receive(:page).and_return 2
        allow(@search).to receive(:first_page?).and_return false
        allow(view).to receive(:search).and_return @search
      end

      context "when boosted contents are present" do
        before do
          expect(@search).not_to receive(:has_boosted_contents?)
        end

        it "should not show boosted contents" do
          render
          expect(rendered).not_to have_selector('boosted_content')
        end
      end

      context "when featured collections are present" do
        before do
          expect(@search).not_to receive(:has_featured_collections?)
        end

        it "should not show featured collections" do
          render
          expect(rendered).not_to have_content('featured collections')
        end
      end
    end
  end
end
