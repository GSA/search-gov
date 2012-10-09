require 'spec_helper'

describe SaytController do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:phrases) { ['lorem ipsum dolor sit amet', 'lorem ipsum sic transit gloria'].freeze }
  let(:phrases_in_json) { phrases.map{|phrase| {:data => nil, :label => phrase, :section => 'default'}}.to_json.freeze }

  before do
    SaytController.class_eval { def is_mobile_device?; false; end }

    phrases.each do |p|
      SaytSuggestion.create!(:phrase => p, :affiliate => affiliate)
    end
  end

  it 'should sanitize query' do
    SaytSuggestion.should_receive(:fetch_by_affiliate_id).
        with(affiliate.id, 'foo bar', 10).
        and_return([])
    get '/sayt', :q => 'foo  \\  bar', :callback => 'jsonp1276290049647', :aid => affiliate.id
  end

  it 'should return blank if no params present' do
    get '/sayt'
    response.body.should == ''
  end

  it 'should return blank if sanitized query is blank' do
    get '/sayt', :q => '  \\  '
    response.body.should == ''
  end

  context 'if name and query params are present' do
    it 'should search for 10 suggestions' do
      SaytSuggestion.should_receive(:fetch_by_affiliate_id).
          with(affiliate.id, 'foo bar', 10).
          and_return([])
      get '/sayt', :name => affiliate.name, :q => 'foo \\ bar', :callback => 'jsonp1234'
    end

    it 'should return jsonp with matching results' do
      get '/sayt', :name => affiliate.name, :q => '  lorem  \\ ipsum  ', :callback => 'jsonp1234'
      response.body.should == %Q{jsonp1234(#{phrases_in_json})}
    end

    context 'when request is from mobile device' do
      before { SaytController.class_eval { def is_mobile_device?; true; end } }

      it 'should search for 6 suggestions' do
        SaytSuggestion.should_receive(:fetch_by_affiliate_id).
            with(affiliate.id, 'foo bar', 6).
            and_return([])
        get '/sayt', :name => affiliate.name, :q => 'foo \\ bar', :callback => 'jsonp1234'
      end
    end
  end

  context 'if aid and query params are present' do
    it 'should search for 10 suggestions' do
      SaytSuggestion.should_receive(:fetch_by_affiliate_id).
          with(affiliate.id, 'foo bar', 10).
          and_return([])
      get '/sayt', :aid => affiliate.id, :q => 'foo \\ bar', :callback => 'jsonp1234'
    end

    it 'should return jsonp with matching results' do
      get '/sayt', :aid => affiliate.id, :q => ' lorem \\ ipsum ', :callback => 'jsonp1234'
      response.body.should == %Q{jsonp1234(#{phrases_in_json})}
    end

    context 'when request is from mobile device' do
      before { SaytController.class_eval { def is_mobile_device?; true; end } }

      it 'should search for 6 suggestions' do
        SaytSuggestion.should_receive(:fetch_by_affiliate_id).
            with(affiliate.id, 'foo bar', 6).
            and_return([])
        get '/sayt', :aid => affiliate.id, :q => 'foo \\ bar', :callback => 'jsonp1234'
      end
    end
  end

  it 'should return empty JSONP if name and aid params are not present' do
    get '/sayt', :q => 'lorem', :callback => 'jsonp1276290049647'
    response.body.should == 'jsonp1276290049647([])'
  end

  it "should return empty JSONP if nothing matches the 'q' param string" do
    get '/sayt', :q=>"who moved my cheese", :callback => 'jsonp1276290049647', :aid => affiliate.id
    response.body.should == 'jsonp1276290049647([])'
  end

  it "should not completely melt down when strange characters are present" do
    lambda { get '/sayt', :q=>"foo\\", :callback => 'jsonp1276290049647', :aid => affiliate.id }.should_not raise_error
    lambda { get '/sayt', :q=>"foo's", :callback => 'jsonp1276290049647', :aid => affiliate.id }.should_not raise_error
  end
end