require 'spec_helper'

describe Admin::AdminController do
  describe 'includes the correct concerns' do
    it { expect(controller.class.ancestors.include?(Accountable)).to eq(true) }
  end
end
