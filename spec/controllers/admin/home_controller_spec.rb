require 'spec_helper'

describe Admin::HomeController do
  before { activate_authlogic }

  describe 'includes the correct concerns' do
    it { expect(controller.class.ancestors.include?(Accountable)).to eq(true) }
  end
end