require 'spec_helper'

describe HelpLink do
  subject { described_class.new(request_path: 'a') }

  it { is_expected.to validate_uniqueness_of :request_path }
  it { is_expected.to validate_presence_of :request_path }
  it { is_expected.to validate_presence_of :help_page_url }
  it { is_expected.to allow_value('/sites/i14y_drawers/new').for(:request_path) }
  it { is_expected.not_to allow_value('notavalidpath').for(:request_path) }

  describe '.lookup(request, action_name)' do
    before do
      HelpLink.create!(request_path: '/sites', help_page_url: 'http://search.gov/sites/manual/site-overview.html')
      HelpLink.create!(request_path: '/sites/new', help_page_url: 'http://search.gov/sites/manual/add-site.html')
      HelpLink.create!(request_path: '/sites/edit', help_page_url: 'http://search.gov/sites/manual/edit-site.html')
    end

    it 'should lookup help link based on sanitized request path' do
      expect(HelpLink.lookup(double('Request', path: '/sites/12345', get?: true), 'show').help_page_url).to eq('http://search.gov/sites/manual/site-overview.html')
    end

    it 'should factor HTTP method into lookup' do
      expect(HelpLink.lookup(double('Request', path: '/sites', get?: false), 'create').help_page_url).to eq('http://search.gov/sites/manual/add-site.html')
      expect(HelpLink.lookup(double('Request', path: '/sites', get?: false), 'update').help_page_url).to eq('http://search.gov/sites/manual/edit-site.html')
    end
  end
end
