require 'spec/spec_helper'

describe HelpLink do
  it { should validate_presence_of :action_name }
  it { should validate_presence_of :help_page_url }
end
