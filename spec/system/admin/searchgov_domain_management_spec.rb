describe 'Searchgov Domain Management' do
  let(:url) { '/admin/searchgov_domains' }

  it_behaves_like 'a page restricted to super admins'

  describe 'reindexing a domain' do
    include_context 'log in super admin'

    let(:reindex) do
      visit url
      row= find(:xpath, '//tbody[@class="records"]/tr[1]')
      row.click_link('Reindex')
    end

    it 'triggers a reindex of the domain' do
       expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
         with(searchgov_domain: instance_of(SearchgovDomain))
    end
  end
end
