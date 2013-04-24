require 'spec_helper'

describe SearchEngineResponse do
  let(:search_engine_response) do
    SearchEngineResponse.new do |search_response|
      search_response.total = 10
      search_response.start_record = 11
      search_response.results = %w(a b c)
      search_response.end_record = 20
      search_response.spelling_suggestion = 'spell'
    end
  end

  it 'should assign spelling suggestion' do
    search_engine_response.spelling_suggestion.should == 'spell'
  end

  it 'should assign total' do
    search_engine_response.total.should == 10
  end

  it 'should assign start record' do
    search_engine_response.start_record.should == 11
  end

  it 'should assign end record' do
    search_engine_response.end_record.should == 20
  end

  it 'should assign results' do
    search_engine_response.results.should == %w(a b c)
  end
end