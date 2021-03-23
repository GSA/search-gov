require 'spec_helper'

describe QueryCount do
  it 'should initialize a new instance given valid attributes' do
    qc = described_class.new('foo', '30')
    expect(qc.query).to eq('foo')
    expect(qc.times).to eq(30)
  end
end
