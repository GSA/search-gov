require 'spec_helper'

describe MobileHelper do
  describe '#serp_attribution' do
    context 'when module_tag is GWEB' do
      it 'returns Powered by Google' do
        helper.serp_attribution('GWEB').should == 'Powered by Google'
      end
    end
  end
end
