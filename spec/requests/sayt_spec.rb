require 'spec_helper'

describe 'sayt' do
  fixtures :affiliates, :form_agencies

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:phrases) { ['lorem ipsum dolor sit amet', 'lorem ipsum sic transit gloria'].freeze }
  let(:phrases_in_json) { phrases.to_json.freeze }
  let(:phrases_with_section_and_label_in_json) { phrases.collect { |p| { section: 'default', label: p } }.to_json.freeze }

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
    it 'should return an array of suggestions' do
      get '/sayt', :q => 'lorem  \\  ipsum', :callback => 'jsonp1234', :aid => affiliate.id
      response.body.should == %Q{jsonp1234(#{phrases_in_json})}
    end

    it "should return empty JSONP if nothing matches the 'q' param string" do
      get '/sayt', :q => "who moved my cheese", :callback => 'jsonp1276290049647', :aid => affiliate.id
      response.body.should == 'jsonp1276290049647([])'
    end

    it "should not completely melt down when strange characters are present" do
      lambda { get '/sayt', :q => "foo\\", :callback => 'jsonp1276290049647', :aid => affiliate.id }.should_not raise_error
      lambda { get '/sayt', :q => "foo's", :callback => 'jsonp1276290049647', :aid => affiliate.id }.should_not raise_error
    end
  end

  context 'when extras is present' do
    it 'should return jsonp with section and label' do
      get '/sayt', :name => affiliate.name, :q => 'lorem \\ ipsum', :callback => 'jsonp1234', :extras => 'true'
      response.body.should == %Q{jsonp1234(#{phrases_with_section_and_label_in_json})}
    end

    context 'when there are boosted contents and forms' do
      before do
        form_agency = form_agencies(:en_uscis)

        Form.create!(form_agency_id: form_agency.id, number: 'I-100', title: 'Lorem Verified Form') do |f|
          f.file_type = 'pdf'
          f.verified = true
          f.landing_page_url = 'http://agency.gov/forms/i-100.html'
          f.url = 'http://agency.gov/forms/i-100.pdf'
        end
        Form.create!(form_agency_id: form_agency.id, number: 'I-200', title: 'Lorem Not Verified Form') do |f|
          f.file_type = 'pdf'
          f.verified = false
          f.landing_page_url = 'http://agency.gov/forms/i-200.html'
          f.url = 'http://agency.gov/forms/i-200.pdf'
        end
        affiliate.form_agencies = [form_agency]

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
      end

      it 'should return results with SaytSuggestions, Forms and Boosted Contents' do
        get '/sayt', :name => affiliate.name, :q => 'lorem', :callback => 'jsonp1234', :extras => 'true'
        results = phrases.collect { |p| { section: 'default', label: p } }
        results << { section: 'Recommended Forms', label: 'Lorem Verified Form (I-100)', data: 'http://agency.gov/forms/i-100.html'}
        results << { section: 'Recommended Pages', label: 'Lorem Boosted Content 1', data: 'http://agency.gov/boosted_content1.html'}
        response.body.should == %Q{jsonp1234(#{results.to_json})}
      end

      it 'should not return SAYT results that do not start with query' do
        get '/sayt', :name => affiliate.name, :q => 'orem', :callback => 'jsonp1234', :extras => 'true'
        response.body.should == 'jsonp1234([])'
      end

      it 'should not return Forms that do not start with query' do
        get '/sayt', :name => affiliate.name, :q => 'Verified', :callback => 'jsonp1234', :extras => 'true'
        response.body.should == 'jsonp1234([])'
      end

      it 'should not return Boosted Contents that do not start with query' do
        get '/sayt', :name => affiliate.name, :q => 'Boosted', :callback => 'jsonp1234', :extras => 'true'
        response.body.should == 'jsonp1234([])'
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

    it 'should search for suggestions' do
      get '/sayt', :name => affiliate.name, :q => 'lorem \\ ipsum', :callback => 'jsonp1234'
      response.body.should == %Q{jsonp1234(#{phrases_in_json})}
    end
  end
end