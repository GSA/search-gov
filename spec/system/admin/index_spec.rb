describe 'Super Admin Landing Page' do
  let(:url) { '/admin' }

  it_behaves_like 'a page restricted to super admins'
end
