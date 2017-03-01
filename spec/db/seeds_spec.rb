require 'spec_helper'

describe 'db seeds' do
  before { Rails.env.stub(:development?).and_return(true) }

  # sanity check...
  it { expect { Rails.application.load_seed }.not_to raise_exception }
end
