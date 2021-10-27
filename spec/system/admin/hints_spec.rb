# frozen_string_literal: true

describe 'Hints', :js do
  let(:url) { '/admin/hints' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Show], 'Hints'
end
