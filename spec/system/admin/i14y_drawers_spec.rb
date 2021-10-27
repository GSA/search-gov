# frozen_string_literal: true

describe 'i14y Drawers', :js do
  let(:url) { '/admin/i14y_drawers' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'

  it_behaves_like 'an ActiveScaffold page',
                  %w[Edit Show],
                  'I14yDrawers'
end
