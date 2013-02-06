require 'spec_helper'

describe HelpLink do
  it { should validate_uniqueness_of :request_path }
  it { should validate_presence_of :request_path }
  it { should validate_presence_of :help_page_url }
  it { should validate_format_of(:request_path).with('/affiliates/rss_feeds/edit') }
end
