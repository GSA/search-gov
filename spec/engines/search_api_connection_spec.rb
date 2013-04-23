require 'spec_helper'

describe SearchApiConnection do
  it 'should respond to #get' do
    params = {affiliate: 'wh', index: 'web', query: 'obama'}
    SearchApiConnection.new('myapi', 'http://search.usa.gov').get('/api/search.json', params)
  end
end