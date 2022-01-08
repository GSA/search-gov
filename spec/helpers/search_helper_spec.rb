require 'spec_helper'
require 'ostruct'

describe SearchHelper do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe '#display_bing_result_extname_prefix' do
    before do
      @urls_that_need_a_box = []
      %w{http ftp}.each do |protocol|
        ['www.irs.gov', 'www2.offthemap.nasa.gov'].each do |host|
          ['', ':8080'].each do |port|
            %w{doc.pdf README.TXT readme.txt ~root/Resume.doc showme.pdf showme.pdf?include=all some/longer/path.pdf}.each do |path|
              @urls_that_need_a_box << "#{protocol}://#{host}#{port}/#{path}"
            end
          end
        end
      end
      @urls_that_dont_need_a_box = @urls_that_need_a_box.collect { |url| url.gsub('.pdf', '.html').gsub('.PDF', '.HTM').gsub('.doc', '.html').gsub('.TXT', '.HTML').gsub('.txt', '.html') }
      @urls_that_dont_need_a_box << ':'
      @urls_that_dont_need_a_box << 'https://www.usa.gov/'
      @urls_that_dont_need_a_box << 'https://www.usa.gov/faq'
      @urls_that_dont_need_a_box << 'https://www.usa.gov/faq?q=meaning+of+life'
    end

    it 'returns an empty string for most types of URLs' do
      @urls_that_dont_need_a_box.each do |url|
        expect(helper.display_web_result_extname_prefix({ 'unescapedUrl' => url })).to eq('')
      end
    end

    it 'returns [TYP] span for some URLs' do
      @urls_that_need_a_box.each do |url|
        path_extname = url.gsub(/.*\//, '').gsub(/\?.*/, '').gsub(/[a-zA-Z0-9_]+\./, '').upcase
        prefix = "<span class=\"uext_type\">[#{path_extname.upcase}]</span> "
        expect(helper.display_web_result_extname_prefix({ 'unescapedUrl' => url })).to eq(prefix)
      end
    end
  end

  describe '#display_result_description' do
    it 'is html safe' do
      description = <<~DESCRIPTION
        loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html truncate me if you want
      DESCRIPTION

      search = { 'content' => description }
      result = helper.display_result_description(search)
      expect(result).to be_html_safe
      expect(result).to eq("<strong>loren</strong> &amp; david's excellent™ html \"examples\" on the &lt;i&gt;tag&lt;/i&gt; and &lt;b&gt; too. <strong>loren</strong> &amp; david's excellent™ html \"examples\" on the &lt;i&gt;tag&lt;/i&gt; and &lt;b&gt; too. <strong>lo</strong> ...")
    end

    it 'truncates long descriptions' do
      description = <<~DESCRIPTION
        The Vietnam War Memorial National Mall Washington, D.C. 2:27 P.M. EDT THE PRESIDENT:  Good afternoon, everybody.
        Chuck, thank you for your words and your friendship and your life of service.
        Veterans of the Vietnam War, families, friends, distinguished guests. I know it is hot.
      DESCRIPTION
      truncated_description = helper.display_result_description({ 'content' => description })
      expect(truncated_description).to match(/and \.\.\.$/)
      expect(truncated_description.length).to be <= 153
    end
  end

  describe '#translate_bing_highlights' do
    let(:body_with_regex_special_character) { "\uE000[Mil\uE001 .gov" }

    specify { expect(helper.translate_bing_highlights(body_with_regex_special_character)).to eq('<strong>[Mil</strong> .gov') }
  end

  describe '#link_to_other_web_results(template, query)' do
    let(:html_template) { 'The above results are from Wherever. <a href="http://www.gov.gov/search?query={QUERY}">Try your search again</a> to see results from Another Place.' }
    let(:query) { "Bill & Ted's (B&T) Excellent Ädventure!" }

    it 'renders HTML with interpolated and encoded query string' do
      link = helper.link_to_other_web_results(html_template, query)
      expect(link).to have_link('Try your search again',
                                href: 'http://www.gov.gov/search?query=Bill%20%26%20Ted%27s%20%28B%26T%29%20Excellent%20%C3%84dventure%21')
    end
  end
end
