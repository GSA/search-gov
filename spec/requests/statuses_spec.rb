require 'spec_helper'

describe '/status/outbound_rate_limit' do
  before do
    OutboundRateLimit.create!(limit: 500,
                              name: 'my_api')
    rl = ApiRateLimiter.new 'my_api'
    rl.redis.set rl.current_used_count_key, '100'
  end

  it 'returns used_percentage' do
    get '/status/outbound_rate_limit.txt', params: { name: 'my_api' }

    expect(response.status).to eq(200)
    expect(response.body).to eq('name:my_api;limit:500;used_count:100;used_percentage:20%')
  end
end
