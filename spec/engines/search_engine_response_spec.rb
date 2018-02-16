require 'spec_helper'

describe SearchEngineResponse do
  let(:search_engine_response) do
    SearchEngineResponse.new do |search_response|
      search_response.total = 10
      search_response.start_record = 11
      search_response.results = %w(a b c)
      search_response.end_record = 20
      search_response.spelling_suggestion = 'spell'
      search_response.tracking_information = 'Ref A: foo bar blat'
    end
  end

  it 'should assign spelling suggestion' do
    expect(search_engine_response.spelling_suggestion).to eq('spell')
  end

  it 'should assign total' do
    expect(search_engine_response.total).to eq(10)
  end

  it 'should assign start record' do
    expect(search_engine_response.start_record).to eq(11)
  end

  it 'should assign end record' do
    expect(search_engine_response.end_record).to eq(20)
  end

  it 'should assign results' do
    expect(search_engine_response.results).to eq(%w(a b c))
  end

  it 'should assign tracking information' do
    expect(search_engine_response.tracking_information).to eq('Ref A: foo bar blat')
  end
end