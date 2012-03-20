class HelpLink < ActiveRecord::Base
  validates_presence_of :action_name, :help_page_url
end
