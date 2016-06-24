require 'spec_helper'

describe HelpLink do
  it { should validate_uniqueness_of :request_path }
  it { should validate_presence_of :request_path }
  it { should validate_presence_of :help_page_url }
  it { should allow_value('/sites/i14y_drawers/new').for(:request_path) }
  it { should_not allow_value('notavalidpath').for(:request_path) }

  describe '.lookup(request, action_name)' do
    before do
      HelpLink.create!(request_path: '/sites', help_page_url: 'http://usasearch.howto.gov/sites/manual/site-overview.html')
      HelpLink.create!(request_path: '/sites/new', help_page_url: 'http://usasearch.howto.gov/sites/manual/add-site.html')
      HelpLink.create!(request_path: '/sites/edit', help_page_url: 'http://usasearch.howto.gov/sites/manual/edit-site.html')
    end

    it 'should lookup help link based on sanitized request path' do
      HelpLink.lookup(double("Request", path: '/sites/12345', get?: true), 'show').help_page_url.should == 'http://usasearch.howto.gov/sites/manual/site-overview.html'
    end

    it 'should factor HTTP method into lookup' do
      HelpLink.lookup(double("Request", path: '/sites', get?: false), 'create').help_page_url.should == 'http://usasearch.howto.gov/sites/manual/add-site.html'
      HelpLink.lookup(double("Request", path: '/sites', get?: false), 'update').help_page_url.should == 'http://usasearch.howto.gov/sites/manual/edit-site.html'
    end
  end
end
